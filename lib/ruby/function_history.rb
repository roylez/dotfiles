#!/usr/bin/env ruby
# coding: utf-8
#Description: Save command in a DB file for later

require 'sequel'
require 'yaml'

FUNCTION_HIST_DB_FILE = File.join( ENV['PWD'], '.func_hist.db' )
FUNCTION_HIST_DB = Sequel.connect "sqlite://#{FUNCTION_HIST_DB_FILE}"

FUNCTION_HIST_DB.create_table?(:function) do
  String :name, :null => false
  String :input, :null => false
  String :output
  index [:name, :opts, :kwds], :unique => true
end

class FunctionHistory < Sequel::Model
  set_dataset FUNCTION_HIST_DB[:function]

  def self.run(func, *opts)
    res = find_or_create(:name => func.to_s, :input => opts.to_yaml) do |a|
      a.output = Kernel.send(func, *opts).to_yaml
    end.output
    res = yield
    YAML.load(res)
  end

  class << self
    alias_method :[] , :run
  end

end

begin
  require 'memcached'
  MEMCACHED_CACHE = Memcached.new('localhost:11211')
  FunctionHistory.plugin :caching, MEMCACHED_CACHE, :ignore_exceptions=>true
rescue
  nil
end

if __FILE__ == $0
  def apb(a, b)
    p 'in function'
    a + b
  end

  p FunctionHistory[:apb, 1, 2]
end
