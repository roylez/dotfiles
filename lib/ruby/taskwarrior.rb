#!/usr/bin/env ruby
# coding: utf-8
#Description: Ruby Model for taskwarrior
require 'time'
require 'ostruct'

class TaskCollection
  include Enumerable

  def self.from_task_file(pending_file, completed_file)
    pending = read_taskwarrior_file(pending_file)
    completed = read_taskwarrior_file(completed_file)
    long_time_ago = Time.parse('2009-07-31 16:00').to_i
    completed.each { |t| t.end = long_time_ago   unless t.end }
    #TaskCollection.new( pending + completed ).dedup
    TaskCollection.new( pending + completed )
  end

  def size
    @tasks.size
  end

  def each
    @tasks.each{|i| yield i}
  end

  def initialize(tasks)
    @tasks = tasks
  end

  def pending
    select{|t| not t.end }
  end

  def completed
    select(&:end)
  end

  # get task by either uuid or toodleid
  # when using toodleid, only child task is returned
  def [](id)
    find{|i| i.uuid == id.to_s } || find{|i| i.toodleid and i.toodleid == id.to_s and i.status != 'recurring' }
  end

  def find_children(parent_uuid)
    select{|i| i.parent && i.parent == parent_uuid }
  end

  # permanently remove a task!
  def delete_by_id(id)
    item = self[id]
    if item
      @tasks.delete_at(index(id))
    end
  end

  def add_task(hash)
    t = Task.new(hash)
    @tasks << t
    t[:uuid]
  end
  alias :<< :add_task

  def edit_task(id, info)
    item = self[id]
    return nil unless item
    #delete_by_id id
    info.is_a?(Task) ? item.merge(info) : item.modify(info)
    item
  end
  alias :[]= :edit_task

  def delete_task(id, time=nil)
    edit_task(id, :end => time || Time.now.to_i, :status => 'deleted')
  end

  def modified_after(time)
    time = time.to_i
    select{|i| i.modified > time }
  end

  def inspect
    "#<TaskCollection:#{object_id} PENDING: #{pending.size} COMPLETED: #{completed.size}>"
  end

  def to_file(pending_file, completed_file)
    #dedup
    write_taskwarrior_file(pending_file, pending)
    write_taskwarrior_file(completed_file, completed)
  end

  # remove duplications
  # ones that has the same toodleid
  def dedup
    new_tasks = []
    old_tasks = {}
    @tasks.each do |t|
      if not t.toodleid
        new_tasks << t
      elsif old_tasks.key?(t.toodleid)
        # retain only the last update
        old_tasks[t.toodleid] = [old_tasks[t.toodleid], t].max
      else
        old_tasks[t.toodleid] = t
      end
    end
    @tasks = new_tasks + old_tasks.values
    self
  end

  def index(id)
    @tasks.index{|i| i.uuid == id.to_s || (i.toodleid and i.toodleid == id.to_s) }
  end

  private
  # read taskwarrior file format
  def self.read_taskwarrior_file(file)
    tasks = []
    IO.readlines(file).each do |l|
      l = l.encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => 'X')
      t = l.scan( /\w+:".*?"/ ).collect{|i| 
        k, v = i.split(':', 2)
        [k.to_sym, v.gsub(/\A"|"\Z/,'')] 
      } 
      t = Hash[t]
      t[:tags] = t[:tags].strip.split(",")  if t[:tags]
      t[:entry] = t[:entry].to_i
      t[:end] = t[:end].to_i  if t[:end]
      t[:modified] = t[:modified].to_i  if t[:modified]
      tasks << Task.new(t)
    end if File.file? file
    tasks
  end

  # write to a taskwarrior file
  def write_taskwarrior_file(file, tasks)
    open(file, 'w') do |f|
      tasks.sort_by(&:toodleid).each do |t|
        t.tags = t.tags.join(",")   if not t.tags.to_s.empty?
        f.puts('[' + t.to_h.collect{|k, v| %Q{#{k}:"#{v}"} }.join(" ") + ']')
      end
    end
  end
end

class Task < OpenStruct
  include Comparable

  # modified field was added since 2.2, here we work around pre 2.2 versions
  def modified
    super || self.end || self.entry
  end

  # compare modified time stamp to decide who would be overriden
  def merge(t)
    changes = ( self > t ) ? t.to_h.merge(to_h) : to_h.merge(t.to_h)
    modify(changes)
  end

  def <=>(t)
    modified <=> t.modified
  end

  def modify(changes)
    changes.each { |k, v| send("#{k}=".to_sym, v) }
  end
end
