#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: Sync taskwarrior task to toodledo

require 'logger'
require 'time'
require 'yaml'
require 'io/console'
YAML::ENGINE.yamler = 'psych' # to use UTF-8 in yaml
require 'securerandom'
require_relative 'toodledo'
require_relative 'taskwarrior'

require 'logger'

module Logger::Severity
  NEW    = 6
  EDIT   = 7
  DELETE = 8
end

class ScreenLogger < Logger
  def initialize
    super(STDOUT)
    @level = INFO
    @formatter = proc do |severity, time, progname, msg|
      "#{time.strftime("%Y-%m-%d %H:%M:%S")} [#{severity}]: #{msg}\n"
    end
  end

  alias :add_orig :add 
  SEVS = %w(DEBUG INFO WARN ERROR FATAL UNKNOWN NEW EDIT DELETE)
  LEVEL_COLOR = { 
    INFO => nil,
    DEBUG => nil,
    WARN => "\e[1;33m",
    ERROR => "\e[1;31m",
    FATAL => "\e[1;35m",
    NEW => "\e[1;32m",
    EDIT => "\e[1;33m",
    DELETE => "\e[1;31m",
  }

  [:NEW, :EDIT, :DELETE].each do |tag|
    define_method(tag.to_s.downcase.gsub(/\W+/, '_').to_sym) do |progname, &block|
      add(ScreenLogger.const_get(tag), nil, progname, &block)
    end 
  end

  def format_severity(severity)
    SEVS[severity] || 'ANY'
  end

  def add(severity, message = nil, progname = nil, &block)
    severity ||= UNKNOWN
    if @logdev.nil? or severity < @level
      return true
    end
    progname ||= @progname
    if message.nil?
      if block_given?
        message = yield
      else
        message = progname
        progname = @progname
      end
    end
    #severity = "#{LEVEL_COLOR[severity]}#{severity}\e[m"    if LEVEL_COLOR[severity]
    @logdev.write( format_message("#{LEVEL_COLOR[severity]}#{format_severity(severity)}\e[m", Time.now, progname, message))
    true
  end
end

class TaskCollection
  def new_task_ids
    select{|i| not i.toodleid }.collect(&:uuid)
  end
end

class SyncWarrior < Toodledo
  attr_reader   :userid

  def initialize(userid, password, taskfile, compfile, cachefile, opts = {})
    @task_file         = taskfile
    @comp_file         = compfile
    @cache_file        = cachefile

    @task_warrior      = TaskCollection.from_task_file(@task_file, @comp_file)

    @remote_folders    = []
    @remote_contexts   = []

    @token             = nil
    @prev_account_info = nil
    @last_sync         = nil
    @userid            = userid

    @appid             = 'syncwarrior'
    @apptoken          = 'api512ab65a08df3'

    #@repeat_from       = opts[:repeat_from] || 1

    # things to be merged with remote
    @push              = {:add => [], :edit => []}
    @pull              = {:add => [], :edit => [], :delete  => []}
    
    @logger            = ScreenLogger.new

    read_cache_file

    # must have userid till now
    super(:userid => userid, :password => password, :user => opts[:user], :token => @token)

    check_changes
  end

  def sync_folders
    if @remote_folder_modified.nil? or @remote_folder_modified
      @remote_folders = get_folders
      @remote_folder_modified =false
    end
  end

  def sync_contexts
    if @remote_context_modified.nil? or @remote_context_modified
      @remote_contexts = get_contexts
      @remote_context_modified = false
    end
  end

  #def sync_start
    #@sync_start ||= Time.now.to_i
  #end

  def sync_tasks
    # if we first upload, and in the case that a task is modified locally and
    # completed remotely, the modification would be uploaded to server, and it
    # remains completed on server. Depending implementation of sync, there could
    # have been two situations: 1. it could not be marked as completed locally;
    # 2. it could be marked complete, but all merges done remotely should be
    # download again.
    #
    # If we first download, we could make the merge locally and upload anything
    # that worth uploading; and next time when sync starts, we only needs to
    # shift @last_sync a few seconds later to avoid double downloads.
    #
    # The flow of syncing ....
    #   download -> local merge -> upload -> ( remote merge )
    #
    #   1. calculate local changes, keep **uuid** in @push
    #   2. download remote changes, keep changed tasks in @pull
    #   3. locally merge @pull into @task_warrior
    #   4. push local changes according to @push
    #
    log.info "#{@task_warrior.size} tasks in local repository(completed: #{@task_warrior.completed.size}, pending: #{@task_warrior.pending.size})"

    update_task_changes

    update_toodle_changes

    local_merge

    %Q{Ready to commit changes: 
      Upload:     NEW:#{@push[:add].size}    EDIT:#{@push[:edit].size}
      Download:   EDIT:#{@pull[:edit].size}   DELETE:#{@pull[:delete].size}
    }.strip.split("\n").each{|l| log.info l }

    commit_changes

    log.info "Commit completed. "

    log.info "#{@task_warrior.size} tasks in local repository(completed: #{@task_warrior.completed.size}, pending: #{@task_warrior.pending.size})"
  end

  def local_merge
    @pull[:add].each    {|t| changes = toodle_to_taskwarrior(t); @task_warrior.add_task(changes) }
    @pull[:edit].each   {|t| changes = toodle_to_taskwarrior(t); @task_warrior.edit_task(t[:id], changes) }
    @pull[:delete].each {|t| @task_warrior.delete_task(t[:id]) }
  end

  def log
    @logger
  end

  def update_task_changes
    # upload new tasks
    new_ids = @task_warrior.new_task_ids
    new_ids.each { |uuid| @push[:add] << uuid }

    # upload modified
    if @last_sync
      @task_warrior.modified_after(@last_sync).collect(&:uuid).each do |uuid|
        next if new_ids.include?(uuid)  # avoid double upload
        @push[:edit] << uuid
      end
    end

    #TODO: deleted tasks are added as edited
    #

    @push.each do |k,v|
      v.each do |uuid|
        key = (k == :add) ? :new : k
        log.send(key, "<= #{@task_warrior[uuid].to_h}")
      end
    end
  end

  def update_toodle_changes
    useful_fields = [:folder, :context, :tag, :duedate, :priority, :added]

    # download new tasks and edited tasks 
    #
    ntasks = []
    if first_sync?
      #ntasks = get_tasks(:fields => useful_fields, :comp => 0)
      ntasks = get_tasks(:fields => useful_fields)
    elsif @remote_task_modified
      ntasks = get_tasks(:fields => useful_fields, :modafter => @last_sync )
    end
    ntasks.each do |t|
      unless id = t[:id] and @task_warrior[id]
        @pull[:add] << t
        log.new("=> #{t}")
      else
        @pull[:edit] << t
        log.edit("=> #{t}")
      end
    end

    # download the list of deleted tasks
    #
    if @remote_task_deleted
      dtasks = get_deleted_tasks(@last_sync)
      # toodledo ids in local tasks
      @pull[:delete] = dtasks.select{|i| i[:id]}
    end

    @pull[:delete].each do |t|
      log.delete "=> #{t}"
    end
  end

  def sync

    sync_folders

    sync_contexts

    sync_tasks

    true
  end

  def commit_changes

    commit_remote_changes

    commit_local_changes

    write_cache_file
  end

  private

  def first_sync?
    not @last_sync or @task_warrior.size.zero?
  end

  def check_changes
    if @prev_account_info
      @remote_task_modified    = has_new_info? :lastedit_task
      @remote_task_deleted     = has_new_info? :lastdelete_task
      @remote_folder_modified  = has_new_info? :lastedit_folder
      @remote_context_modified = has_new_info? :lastedit_context
    end
  end

  def commit_local_changes
    @task_warrior.to_file(@task_file, @comp_file)
  end

  def commit_remote_changes
    @push.each do |k, v|
      next if v.empty?
      res = send("#{k}_tasks".to_sym, v.collect{|uuid| taskwarrior_to_toodle(@task_warrior[uuid])})
      if k == :add  # append remote toodleid to local
        ids = Hash[ [v, res].transpose ]
        ids.each { |uuid, t| @task_warrior[uuid].toodleid = t[:id] }
      end
    end
  end

  # has new value in account_info?
  def has_new_info?(field)
    @account_info[field] > @prev_account_info[field]
  end

  # read from previous sync stats, if it contains information....
  def read_cache_file
    return nil unless File.file? @cache_file

    cache = YAML.load_file(@cache_file)

    return nil unless cache.is_a? Hash
    return nil unless cache[:userid] == @userid

    @token             = cache[:token]
    @prev_account_info = cache[:account_info]
    @remote_folders    = cache[:remote_folders]
    @remote_contexts   = cache[:remote_contexts]
    @last_sync         = cache[:last_sync]
  end

  # write cache data to cache file
  def write_cache_file
    open(@cache_file, 'w') do |f|
      f.puts({ 
        :userid => @userid,
        :token => @token,
        :account_info => @account_info,
        :remote_folders => @remote_folders,
        :remote_contexts => @remote_contexts,
        :last_sync => Time.now.to_i ,
      }.to_yaml)
    end
  end

  # convert from TaskWarriror to Toodledo format
  def taskwarrior_to_toodle(task)
    task = task.dup
    toodletask = {}
    toodletask[:title]    = task[:description]
    toodletask[:id]       = task[:toodleid]                         if task[:toodleid]
    toodletask[:duedate]  = to_toodle_date(task[:due].to_i)         if task[:due]
    toodletask[:completed]= to_toodle_date(task[:end].to_i)         if task[:end]
    toodletask[:priority] = tw_priority_to_toodle(task[:priority])  if task[:priority]
    toodletask[:folder]   = tw_project_to_toodle(task[:project])    if task[:project]
    if task[:tags]
      context = task[:tags].find{|i| i.start_with? '@' }
      if context
        toodletask[:context] = tw_context_to_toodle(context)
        task[:tags] = task[:tags].select{|t| not t.start_with? '@'}
      end
      toodletask[:tag] = task[:tags].join(",")
    end
    toodletask
  end

  # TW project => toodle folder
  def tw_project_to_toodle(project_name)
    folder = @remote_folders.find{|f| f[:name] == project_name}
    unless folder
      folder = add_folder(project_name).first
      @remote_folders << folder
    end
    folder[:id]
  end

  # TW @tag => toodle context
  def tw_context_to_toodle(context_name)
    # remove prefixing '@'
    context_name = context_name.delete("@")
    context = @remote_contexts.find{|c| c[:name] == context_name}
    unless context
      context = add_context(context_name).first
      @remote_contexts << context
    end
    context[:id]
  end

  # toodle folder => TW project
  def toodle_folder_to_tw(folderid)
    @remote_folders.find{|f| f[:id] == folderid}[:name]
  end

  def toodle_context_to_tw(contextid)
    '@' + @remote_contexts.find{|c| c[:id] == contextid}[:name]
  end
  
  def toodle_priority_to_tw(priority)
    case priority.to_i
    when 1; 'L'
    when 2; 'M'
    when 3; 'H'
    else; nil
    end
  end

  def tw_priority_to_toodle(tw_priority)
    case tw_priority
    when 'L'; 1
    when 'M'; 2
    when 'H'; 3
    else; 0
    end
  end

  # toodle use GMT, all timestamps for date will be adjust to GMT noon
  #
  def to_toodle_date(secs, noon = true)
    t = Time.at(secs).
      strftime("%Y-%m-%d #{noon ? '12:00:00' : '%H:%M:%S'} UTC")
    Time.parse(t).to_i
  end

  def from_toodle_date(secs)
    t = Time.at(secs).utc.strftime("%Y-%m-%d 00:00:00")
    Time.parse(t).to_i
  end

  # convert from toodledo to TaskWarrior format as a hash
  def toodle_to_taskwarrior(task)
    twtask = {}
    twtask[:toodleid]    = task[:id]
    twtask[:description] = task[:title]
    twtask[:due]         = from_toodle_date(task[:duedate].to_i)  if task[:duedate]
    twtask[:tags]        = task[:tag].split(",").map(&:strip)     if task[:tag]
    twtask[:project]     = toodle_folder_to_tw(task[:folder])     if task[:folder]
    twtask[:priority]    = toodle_priority_to_tw(task[:priority]) if task[:priority]
    twtask[:status]      = task[:completed] ? "completed" : "pending"
    twtask[:uuid]        = SecureRandom.uuid
    twtask[:entry]       = from_toodle_date(task[:added])
    twtask[:end]         = from_toodle_date(task[:completed])     if task[:completed]
    twtask[:modified]    = from_toodle_date(task[:modified])      if task[:modified]
    #twtask[:recur]       = toodle_repeat_to_tw(task[:repeat])     if task[:repeat]
    if task[:context]
      con = toodle_context_to_tw(task[:context])
      twtask[:tags] = twtask[:tags] ? twtask[:tags].concat([ con ]) : [con]
    end

    twtask
  end
end

# prompt user to input something
#
def question_prompt(field, opts = {})
    trap("INT") { exit 1 }
    begin
      print "Please input #{field}: "
      response = opts[:password] ? STDIN.noecho(&:gets).strip : STDIN.gets.strip
    end until not response.empty?
    response
end

if __FILE__ == $0
  TASK_BASE_DIR = File.join(ENV['HOME'], '.task')
  TASK_FILE     = File.join(TASK_BASE_DIR, 'pending.data')
  COMP_FILE     = File.join(TASK_BASE_DIR, 'completed.data')
  CACHE_FILE    = File.join(TASK_BASE_DIR, 'syncwarrior_cache.yml')
  CONFIG_FILE   = File.join(TASK_BASE_DIR, 'syncwarrior_conf.yml')

  begin
    $config = YAML.load_file(CONFIG_FILE)
  rescue
    $config = {}
  end

  unless $config[:userid] and $config[:password]
    puts "It looks like this is your first time using this SyncWarrior."
    puts
    first_run = true
    $config[:userid] = nil
    $config[:user] = question_prompt("toodledo login name")
    $config[:password] = question_prompt("toodledo password", :password => true)
    puts
  end

  begin
    w = SyncWarrior.new($config[:userid], $config[:password], 
                        TASK_FILE, COMP_FILE, CACHE_FILE, 
                        $config.reject{|k,_| [:userid, :password].include? k}
                       )
    res = w.sync
  rescue RemoteAPIError => e
    puts "API Error: #{e.message}"
    exit 1
  rescue Exception => e
    puts "Error: #{e}"
    puts e.backtrace  if $DEBUG
    exit 1
  end

  if res and first_run
    open(CONFIG_FILE, 'w'){|f| f.puts( $config.merge(:userid => w.userid).to_yaml )}
  elsif not res
    puts "Sync does not complete successfully, please check your login credentials."
  end
end
