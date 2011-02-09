#!/usr/bin/env ruby
# coding: utf-8
# Description: Tabulate arrays
#

def tabulate(labels, data, indent = 0)
    assert { labels.size == data.transpose.size }
    data = data.unshift(labels).transpose
    data = data.collect {|c| c.collect {|e| e.to_s } }
    widths = data.collect {|c| c.collect {|a| a.width}.max } 
    newdata = []
    data.each_with_index {|c,i|
        newdata << c.collect { |e| "%-#{widths[i]-e.n_wide_char}s" %e }
    }
    data = newdata
    data = data.transpose.collect {|l|
        '| ' + l.join(' | ') + ' |'
    }
    ruler1 = '+' + '-'*(data[0].width - 2) + '+'
    ruler2 = '+=' + widths.collect {|n| '='*n}.join('=+=') + '=+'
    lines = [ruler1, data[0], ruler2] + data[1..-1] + [ ruler1]
    lines.collect {|l| ' '*indent + l}.join("\n")
end

def assert(*msg)
    raise "Assertion failed! #{msg}" unless yield #if $DEBUG
end

class String
    def n_wide_char
        (bytesize - size ) / 2
    end
    def width
        size + n_wide_char 
    end
end

if __FILE__ == $0
    source = [['aht',3],[4,'5'],['s','s']]
    labels = ['a','b']
    #formater = TableFormatter.new
    #formater.source = source 
    #formater.labels = labels
    #puts formater.display
    puts tabulate(labels, source, 5)
end
