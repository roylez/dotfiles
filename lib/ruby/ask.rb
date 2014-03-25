#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: I have no idea what this does

# accept the following options
#   :default        default value when input is empty
#   :prompt         a list of selections
def ask_variable(variable, opts={}, &block)
    res = nil
    while res.to_s.empty?
        print "Please input \e[32;1m" + variable.to_s + \
            (opts[:default] ? "\e[m (#{opts[:default].to_s}): " : "\e[m: ")
        if opts[:prompt] and opts[:prompt].is_a? Array and not opts[:prompt].empty?
            puts; puts
            opts[:prompt].each.with_index do |o, i|
                puts "\t[ #{i} ]  #{o}"
            end
            puts; print "Your choice is: "
        end
        begin
            res = STDIN.gets.chomp
            res = opts[:default]    if res.empty? and opts[:default]
        rescue Interrupt
            puts; puts; puts "Canceled, bye."
            exit
        end
        if opts[:prompt]
            res = res.split.map(&:to_i)
            res = nil  if res.any?{|i| i.to_i >= opts[:prompt].size}
        end
        res = nil   if block_given? and ! yield res
    end
    if res
      return ( opts[:output_value] ? res.map{|i| opts[:prompt][i] } : res )
    end
    nil
end

if __FILE__ == $0
    ask_variable(ARGV[0], :default => 1, :prompt => ["something", "blahblah"])
end
