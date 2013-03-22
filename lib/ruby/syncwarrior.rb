#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

require 'logger'
require 'time'
require 'yaml'
require 'io/console'
YAML::ENGINE.yamler = 'psych' # to use UTF-8 in yaml
require 'securerandom'
require_relative 'toodledo'

class SyncWarrior < Toodledo
  attr_reader   :userid

  def initialize(userid, password, taskfile, compfile, cachefile, opts = {})
    @task_file         = taskfile
    @comp_file         = compfile
    @cache_file        = cachefile

    @remote_folders    = []
    @remote_contexts   = []

    @token             = nil
    @prev_account_info = nil
    @last_sync         = nil
    @userid            = userid

    @appid             = 'syncwarrior'
    @apptoken          = 'api512ab65a08df3'

    @due_field         = opts[:scheduled_is_due] ? :scheduled : :due

    read_cache_file

    # must have userid till now
    super(:userid => userid, :password => password, :user => opts[:user], :token => @token)

    check_changes
  end

  def upload_new
    # upload new task to toodle
    # 
    ntasks = local_tasks.select{|i| not i[:toodleid] }.collect{|i| [i[:uuid], taskwarrior_to_toodle(i)] }
    unless ntasks.empty?
      puts "Upload #{ntasks.size} new tasks to toodledo..."
      newids = Hash[[ntasks.map(&:first), add_tasks(ntasks.map(&:last))].transpose]
      newids.each do |uuid, task|
        puts "[NEW]<= #{task}, UUID: #{uuid}"
      end
      local_tasks.each do |t|
        t[:toodleid] = newids[t[:uuid]][:id]   if newids.key? t[:uuid]
      end
    end
  end

  def upload_edited
    # upload edited tasks
    #
    return unless @last_sync
    # edited tasks
    edited_tasks = old_local_tasks.select{|i| i[:entry] > @last_sync and i[:entry] < sync_start }
    # completed tasks
    completed_tasks = local_complete_tasks.select{|i| i[:end] and i[:end] > @last_sync and i[:toodleid]}  
    if (edited_tasks.size + completed_tasks.size) > 0
      puts "Update #{edited_tasks.size} edited tasks and #{completed_tasks.size} completed tasks..."
      ntasks = (edited_tasks + completed_tasks).collect{|i| taskwarrior_to_toodle(i)}
      ntasks.each do |t|
        puts "[UPDATE]<= #{t}"
      end
      edit_tasks(ntasks)        unless ntasks.empty?
    end
  end

  def download_new_and_edited
    useful_fields = [:folder, :context, :tag, :duedate, :priority]

    # download new tasks and edited tasks 
    #
    if not @last_sync or @remote_task_modified
      ntasks = []
      if @last_sync
        ntasks = get_tasks(:fields => useful_fields, :modafter => @last_sync)
      else
        ntasks = get_tasks(:fields => useful_fields, :comp => 0)
      end
      ntasks.each do |t|
        puts "[UPDATE]=> #{t}"
      end
      # toodledo ids in local tasks
      lids = local_tasks.collect{|i| i[:toodleid]}
      # add new tasks
      local_tasks.concat(ntasks.
                    select{|i| not lids.include?(i[:id])}.
                    collect{|i| toodle_to_taskwarrior(i)}
                   )
      # add edited tasks
      ntasks.select{|i| lids.include?(i[:id])}.each do |t|
        lindex = local_tasks.find_index{|i| i[:toodleid] == t[:id] }
        local_tasks[lindex] = toodle_to_taskwarrior(t)
      end
    end
  end

  def download_deleted
    # download the list of deleted tasks
    #
    if @remote_task_deleted
      dtasks = get_deleted_tasks(@last_sync)
      # toodledo ids in local tasks
      lids = local_tasks.collect{|i| i[:toodleid]}
      dtasks.select{|t| lids.include? t[:id] }.collect{|i| i[:id]}.each do |id|
        local_tasks.delete_if {|i| i[:toodleid] == id }
      end
    end
  end

  def local_tasks
    @local_tasks ||= read_taskwarrior_file(@task_file)
  end

  def old_local_tasks
    @old_local_tasks ||= read_taskwarrior_file(@task_file)
  end

  def local_complete_tasks
    @completed_tasks ||= read_taskwarrior_file(@comp_file)
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

  def sync_start
    @sync_start ||= Time.now.to_i
  end

  def sync

    sync_folders

    sync_contexts

    # first download, very important
    download_new_and_edited

    download_deleted
    
    upload_new

    upload_edited

    write_taskwarrior_file

    write_cache_file

    true
  end

  # private
  def check_changes
    if @prev_account_info
      @remote_task_modified    = has_new_info? :lastedit_task
      @remote_task_deleted     = has_new_info? :lastdelete_task
      @remote_folder_modified  = has_new_info? :lastedit_folder
      @remote_context_modified = has_new_info? :lastedit_context
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

  # read taskwarrior file format
  def read_taskwarrior_file(file)
    tasks = []
    open(file).each_line do |l|
      l = l.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => 'X')
      t = l.scan( /\w+:".+?"/ ).collect{|i| 
        k, v = i.split(':', 2)
        [k.to_sym, v.gsub(/\A"|"\Z/,'')] 
      } 
      t = Hash[t]
      t[:tags] = t[:tags].strip.split(",")  if t[:tags]
      t[:entry] = t[:entry].to_i
      t[:end] = t[:end].to_i  if t[:end]
      tasks << t
    end if File.file? file
    tasks
  end

  # write to a taskwarrior file
  def write_taskwarrior_file
    open(@task_file, 'w') do |f|
      local_tasks.each do |t|
        t[:tags] = t[:tags].join(",")   if t[:tags]
        f.puts('[' + t.collect{|k, v| %Q{#{k}:"#{v}"} }.join(" ") + ']')
      end
    end
  end

  # convert from TaskWarriror to Toodledo format
  def taskwarrior_to_toodle(task)
    toodletask = {}
    toodletask[:title]    = task[:description]
    toodletask[:id]       = task[:toodleid]   if task[:toodleid]
    toodletask[:duedate]  = to_toodle_date(task[@due_field].to_i)   if task[@due_field]
    toodletask[:completed] = to_toodle_date(task[:end].to_i) if task[:end]
    toodletask[:priority] = tw_priority_to_toodle(task[:priority])  if task[:priority]
    toodletask[:folder]   = tw_project_to_toodle(task[:project])   if task[:project]
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
  def to_toodle_date(secs)
    t = Time.at(secs).strftime("%Y-%m-%d 12:00:00 UTC")
    Time.parse(t).to_i
  end

  def from_toodle_date(secs)
    t = Time.at(secs).utc.strftime("%Y-%m-%d 00:00:00")
    Time.parse(t).to_i
  end

  # convert from toodledo to TaskWarrior format
  def toodle_to_taskwarrior(task)
    twtask = {}
    twtask[:toodleid] = task[:id]
    twtask[:description] = task[:title]
    twtask[@due_field] = from_toodle_date(task[:duedate].to_i)  if task[:duedate]
    twtask[:tags] = task[:tag].split(",").map(&:strip)  if task[:tag]
    twtask[:project] = toodle_folder_to_tw(task[:folder])   if task[:folder]
    twtask[:priority] = toodle_priority_to_tw(task[:priority])   if task[:priority]
    twtask[:status] = task[:completed] ? "completed" : "pending"
    twtask[:uuid] = SecureRandom.uuid
    twtask[:entry] = Time.now.to_i
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
                        { :user => $config[:user], :scheduled_is_due => $config[:scheduled_is_due]}
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
