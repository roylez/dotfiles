#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

require 'time'
require 'toodledo'
require 'yaml'

class SyncWarrior < Toodledo
  def initialize(userid, password, taskfile, compfile, cachefile, user = nil)
    @task_file        = taskfile
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

    super(:userid => userid, :password => password, :user => user, :token => @token)

    check_changes
  end

  def sync
    sync_start = Time.now
    useful_fields = [:folder, :context, :tag, :duedate, :priority]

    ltasks = read_taskwarrior_file(@task_file)
    ctasks = read_taskwarrior_file(@comp_file)

    # upload new task to toodle
    # 

    # upload edited tasks
    #

    # download new tasks and edited tasks 
    #
    
    # download the list of deleted tasks
    #

    # write task information
    #

    # write cache for future reuse
    write_cache_file
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
  end

  # write cache data to cache file
  def write_cache_file
    open(@cache_file, 'w') do |f|
      f.puts({ 
        :userid => @userid,
        :token => @token,
        :account_info => @account_info,
        :remote_folders => @remote_folders,
        :remote_contexts => @remote_contexts
      }.to_yaml)
    end
  end

  # read taskwarrior file format
  def read_taskwarrior_file(file)
    tasks = []
    open(file).each_line do |l|
      t = l.scan( /\w+:".+?"/ ).collect{|i| 
        k, v = i.split(':', 2)
        [k.to_sym, v.gsub(/\A"|"\Z/,'')] 
      } 
      t[:tags] = t[:tags].strip.split(",")  if t[:tags]
      tasks << Hash[t]
    end
    tasks
  end

  # write to a taskwarrior file
  def write_taskwarrior_file(file, data)
  end

  # convert from TaskWarriror to Toodledo format
  def taskwarrior_to_toodle(task)
    toodletask = {}
    toodletask[:title]    = task[:description]
    toodletask[:id]       = task[:toodleid]   if task[:toodleid]
    toodletask[:duedate]  = task[:due].to_i   if task[:due]
    toodletask[:complete] = task[:entry].to_i if task[:entry]
    toodletask[:priority] = toodle_prioriy(task[:priority])  if task[:priority]
    toodletask[:folder]   = toodle_folder(task[:project])   if task[:project]
    if task[:tags]
      context = task[:tags].find{|i| i.start_with? '@' }.delete('@')
      if context
        toodletask[:context] = toodle_context(context)
        task[:tags] = task[:tags].select{|t| not t.start_with? '@'}
      end
      toodletask[:tag] = task[:tags].join(",")
    end
  end

  def toodle_prioriy(tw_priority)
    case tw_priority
    when 'L'; 1
    when 'M'; 2
    when 'H'; 3
    else; 0
    end
  end
  
  # convert from toodledo to TaskWarrior format
  def toodle_to_taskwarrior(task)
  end
end
