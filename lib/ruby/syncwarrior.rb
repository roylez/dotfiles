#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

require 'logger'
require 'time'
require 'yaml'
YAML::ENGINE.yamler = 'psych' # to use UTF-8 in yaml
require 'securerandom'
require_relative 'toodledo'

class SyncWarrior < Toodledo
  attr_reader   :userid

  def initialize(userid, password, taskfile, compfile, cachefile, user = nil)
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

    read_cache_file

    # must have userid till now
    super(:userid => userid, :password => password, :user => user, :token => @token)

    check_changes
  end

  def sync
    sync_start = Time.now.to_i
    useful_fields = [:folder, :context, :tag, :duedate, :priority]

    ltasks = read_taskwarrior_file(@task_file)
    ctasks = read_taskwarrior_file(@comp_file)

    update_remote_folders
    update_remote_contexts

    # upload new task to toodle
    # 
    ntasks = ltasks.select{|i| not i[:toodleid] }.collect{|i| [i[:uuid], taskwarrior_to_toodle(i)] }
    unless ntasks.empty?
      puts "Upload #{ntasks.size} new tasks to toodledo..."
      newids = Hash[[ntasks.map(&:first), add_tasks(ntasks.map(&:last))].transpose]
      ltasks.each do |t|
        t[:toodleid] = newids[t[:uuid]]   if newids.key? t[:uuid]
      end
    end

    # upload edited tasks
    #
    if @last_sync
      # new tasks
      edited_tasks = ltasks.select{|i| i[:entry] > @last_sync and i[:entry] < sync_start }
      # completed tasks
      completed_tasks = ctasks.select{|i| i[:entry] > @last_sync and i[:toodleid] and i[:entry] < sync_start }
      puts "Update #{edited_tasks.size} edited tasks and #{completed_tasks.size} completed tasks..."
      ntasks = (edited_tasks + completed_tasks).collect{|i| taskwarrior_to_toodle(i)}
      edit_tasks(ntasks)        unless ntasks.empty?
    end

    # download new tasks and edited tasks 
    #
    if not @last_sync or @remote_task_modified
      ntasks = []
      if @last_sync
        ntasks = get_tasks(:fields => useful_fields, :modafter => @last_sync)
      else
        ntasks = get_tasks(:fields => useful_fields, :comp => 0)
      end
      puts "Download #{ntasks.size} new tasks found on server"
      # toodledo ids in local tasks
      lids = ltasks.collect{|i| i[:toodleid]}
      # add new tasks
      ltasks.concat(ntasks.
                    select{|i| not lids.include?(i[:id])}.
                    collect{|i| toodle_to_taskwarrior(i)}
                   )
      # add edited tasks
      ntasks.select{|i| lids.include?(i[:id])}.each do |t|
        lindex = ltasks.find_index{|i| i[:toodleid] == t[:id] }
        ltasks[lindex] = toodle_to_taskwarrior(t)
      end
    end
    
    # download the list of deleted tasks
    #
    if @remote_task_deleted
      dtasks = get_deleted_tasks(@last_sync)
      # toodledo ids in local tasks
      lids = ltasks.collect{|i| i[:toodleid]}
      dtasks.select{|t| lids.include? t[:id] }.map(&:id).each do |id|
        ltasks.delete_if {|i| i[:toodleid] == id }
      end
    end

    # write task information
    #
    write_taskwarrior_file(ltasks)

    # write cache for future reuse
    write_cache_file

    true
  end

  # private
  def check_changes
    if @prev_account_info
      @remote_task_modified    = true  if has_new_info? :lastedit_task
      @remote_task_deleted     = true  if has_new_info? :lastdelete_task
      @remote_folder_modified  = true  if has_new_info? :lastedit_folder
      @remote_context_modified = true  if has_new_info? :lastedit_context
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
      tasks << t
    end
    tasks
  end

  # write to a taskwarrior file
  def write_taskwarrior_file(data)
    open(@task_file, 'w') do |f|
      data.each do |t|
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
    toodletask[:duedate]  = task[:due].to_i   if task[:due]
    toodletask[:complete] = task[:entry].to_i if task[:entry]
    toodletask[:priority] = tw_priority_to_toodle(task[:priority])  if task[:priority]
    toodletask[:folder]   = tw_project_to_toodle(task[:project])   if task[:project]
    if task[:tags]
      context = task[:tags].find{|i| i.start_with? '@' }.delete('@')
      if context
        toodletask[:context] = tw_context_to_toodle(context)
        task[:tags] = task[:tags].select{|t| not t.start_with? '@'}
      end
      toodletask[:tag] = task[:tags].join(",")
    end
    toodletask
  end

  def update_remote_folders
    if @remote_folder_modified.nil? or @remote_folder_modified
      @remote_folders = get_folders
      @remote_folder_modified =false
    end
  end

  def update_remote_contexts
    if @remote_context_modified.nil? or @remote_context_modified
      @remote_contexts = get_contexts
      @remote_context_modified = false
    end
  end

  # TW project => toodle folder
  def tw_project_to_toodle(project_name)
    folder = @remote_folders.find{|f| f[:name] == project_name}
    unless folder
      folder = add_folder(project_name)
      @remote_folders << folder
    end
    folder[:id]
  end

  # TW @tag => toodle context
  def tw_context_to_toodle(context_name)
    # remove prefixing '@'
    context_name = context[1..-1]
    context = @remote_contexts.find{|c| c[:name] == context_name}
    unless context
      context = add_context(context_name)
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

  # convert from toodledo to TaskWarrior format
  def toodle_to_taskwarrior(task)
    twtask = {}
    twtask[:toodleid] = task[:id]
    twtask[:description] = task[:title]
    twtask[:due] = task[:duedate].to_i  if task[:duedate]
    twtask[:tags] = task[:tag].split(",").map(&:strip)  if task[:tag]
    twtask[:project] = toodle_folder_to_tw(task[:folder])   if task[:folder]
    twtask[:priority] = toodle_priority_to_tw(task[:priority])   if task[:priority]
    twtask[:status] = task[:completed] ? "completed" : "pending"
    twtask[:uuid] = SecureRandom.uuid
    if task[:context]
      con = toodle_context_to_tw(task[:context])
      twtask[:tags] = twtask[:tags] ? twtask[:tags].concat([ con ]) : [con]
    end

    twtask
  end
end

# prompt user to input something
#
def question_prompt(field, default = nil)
    trap("INT") { exit 1 }
    begin
      print "Please input #{field}: "
      response = STDIN.gets.strip
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
    userid, password = YAML.load_file(CONFIG_FILE)
  rescue
    userid = password = nil
  end

  unless userid and password
    puts "It looks like this is your first time using this SyncWarrior."
    puts
    user = question_prompt("toodledo login name")
    password = question_prompt("toodledo password")
    w = SyncWarrior.new(nil, password, TASK_FILE, COMP_FILE, CACHE_FILE, user)
    res = w.sync
    if res
      open(CONFIG_FILE, 'w'){|f| f.puts( [w.userid, password].to_yaml )}
    else
      puts "Sync does not complete successfully, please check your login credentials."
    end
  else 
    w = SyncWarrior.new(userid, password, TASK_FILE, COMP_FILE, CACHE_FILE )
    w.sync
  end
end
