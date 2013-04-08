#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: a simple toodledo API 

require 'net/http'
require 'json'
require 'digest'

class InformationError < Exception; end

class RemoteAPIError < Exception; end

class Toodledo
  def initialize(opts = {})
    @appid ||= 'example'
    @apptoken ||= 'example'
    @token_max_age = 60 * 60 * 4

    @password = opts[:password]
    @token = opts[:token]
    @userid = opts[:userid] || get_userid(opts[:user])

    raise(InformationError, "User or Userid") unless @userid

    @account_info = get_account
  end

  def get_userid(user)
    call_account_api('lookup', 
                     :appid => @appid,
                     :email => user,
                     :pass => @password,
                     :sig => get_sig(user)
                    )[:userid]
  end

  def get_tasks(opts = {})
    if opts.key? :fields and opts[:fields].is_a? Array
      opts[:fields] = opts[:fields].map(&:to_s).join(',')
    end
    tasks = call_task_api(:get, opts)[1..-1]
    tasks.each do |t|
      t.delete(:completed)  unless t[:completed] and t[:completed] > 0
      t.delete(:duedate)    unless t[:duedate] and t[:duedate] > 0
      t.delete(:tag)        if t[:tag] and t[:tag].strip == ''
      t.delete(:repeat)     if t[:repeat] and t[:repeat].strip == ''
      #t.delete(:folder)     if t[:folder] and t[:folder] == '0'
      #t.delete(:context)    if t[:context] and t[:context] == '0'
      t.each_key{|key| t.delete(key) unless t[key] != '0'}
    end
    tasks
  end

  def get_deleted_tasks(after = nil)
    call_task_api(:deleted, :after => after)
  end

  def get_contexts
    call_context_api(:get)
  end

  def get_folders
    call_folder_api(:get)
  end

  def get_account
    call_account_api(:get, :key => key)
  end

  def add_context(name)
    call_context_api(:add, :name => name)
  end

  def add_folder(name)
    call_folder_api(:add, :name => name)
  end

  def add_tasks(tasks)
    call_task_api(:add, :tasks => JSON.dump(tasks))
  end

  def edit_tasks(tasks)
    call_task_api(:edit, :tasks => JSON.dump(tasks))
  end

  def delete_tasks(tasks)
    call_task_api(:edit, :tasks => JSON.dump(tasks.collect{|t| t[:id]}))
  end

  def delete_context(context_id)
    call_context_api(:delete, :id => context_id)
  end

  def delete_folder(folder_id)
    call_folder_api(:delete, :id => folder_id)
  end

  private

  def token
    if token_expired?
      res = call_account_api('token', :userid => @userid, :appid => @appid, :sig => get_sig(@userid))
      @token = [res[:token], Time.now]
    end
    @token.first
  end

  def token_expired?
    not @token or ( Time.now - @token.last > @token_max_age )
  end

  def get_sig(element)
    Digest::MD5.hexdigest(element + @apptoken)
  end

  # generate authentication key
  def key
    if not @key or token_expired?
      @key = Digest::MD5.hexdigest(Digest::MD5.hexdigest(@password) + @apptoken + token)
    end
    @key
  end

  def api_call(category, call_name, opts = {})
    url = URI.parse "http://api.toodledo.com/2/#{category}/#{call_name}.php"

    response = Net::HTTP.post_form(url, opts)
    res = JSON.parse(response.body, :symbolize_names => true)

    if res.is_a? Hash and res.key? :errorCode
      raise RemoteAPIError, res[:errorDesc]
    end

    res
  end

  def call_task_api(call_name, opts = {})
    api_call('tasks', call_name, opts.merge(:key => key))
  end

  def call_folder_api(call_name, opts = {})
    api_call('folders', call_name, opts.merge(:key => key))
  end

  def call_context_api(call_name, opts = {})
    api_call('contexts', call_name, opts.merge(:key => key))
  end

  def call_account_api(call_name, opts = {})
    api_call('account', call_name, opts)
  end
end


