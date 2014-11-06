#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: I have no idea what this does

# accept the following options
#   :default        default value when input is empty
#   :prompt         a list of selections
def ask_for_selection(question, opts={}, &block)
    res = nil
    while res.to_s.empty?
        print "\e[1;32m#{question}\e[m:"
        if opts[:prompt] and opts[:prompt].is_a? Array and not opts[:prompt].empty?
            puts; puts
            opts[:prompt].each.with_index do |o, i|
                puts "\t[ #{i} ]  #{o}"
            end
            puts; print "\e[1;33mYour choice is [\e[m#{opts[:default]}\e[1;33m]:\e[m "
        end
        begin
            res = STDIN.gets.chomp
            res = opts[:default]    if res.empty? and opts[:default]
        rescue Interrupt
            puts; puts; puts "Canceled, bye."
            exit
        end
        res = res.split.map(&:to_i).compact   if res.is_a? String
        res = nil  if res.is_a? Array and res.any?{|i| i.to_i >= opts[:prompt].size}
        res = nil  if block_given? and ! yield res
        res = res.first   if res.is_a? Array and res.size == 1
        print "\e[31mInvalid Selection, please re-enter.\e[m\n\n" unless res
    end
    if res
      return ( opts[:output_value] ? res.map{|i| opts[:prompt][i] } : res )
    end
    nil
end

if __FILE__ == $0
    p ask_for_selection(ARGV.join("\n"), :default => 1, :prompt => ["something", "blahblah"])
end
