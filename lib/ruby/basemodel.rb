#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 

require 'ostruct'
require 'forwardable'

class DotHash < OpenStruct
    extend Forwardable

    def []= (key, value)
        @table[key.to_sym] = value
    end

    alias :store  :[]=

    def merge(hash)
        h = clone
        hash.each do |k, v|
            h[k.to_sym] = v
        end
        h
    end

    def merge! hash
        hash.each { |k, v| h[k.to_sym] = v }
    end

    def_delegators :@table, :keys, :key?, :values, :[], :to_a, :to_hash, :each, :each_key, :each_value, :clear, :empty?, :fetch, :size, :value?, :values_at, :delete, :delete_if

end
