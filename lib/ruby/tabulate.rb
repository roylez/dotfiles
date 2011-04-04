#!/usr/bin/env ruby
# coding: utf-8
# author:       zuole@cn.ibm.com

$template = { 
    "simple" => { 
        :rs => '', :fs => ' | ',  :cross => '+',
        :lframe => '', :rframe => '' ,
        :hlframe => "\e[1;2m", :hrframe => "\e[m" ,
        :padding => 0,
    },
    "legacy" => {
        :rs => '', :fs => '|', :cross => '+',
        :lframe => '|', :rframe => '|',
        :hlframe => "|", :hrframe => "|",
        :tframe => "-", :bframe => "-",
        :hs => "=", :padding => 1,
    },
    'plain' => {
        :rs => '', :fs => ' ', :cross => '+',
        :lframe => '', :rframe => '',
        :hlframe => "", :hrframe => "",
        :padding => 0, 
    },
    'sqlite' => {
        :rs => '', :fs => '  ', :cross => '  ',
        :lframe => '', :rframe => '',
        :hlframe => "", :hrframe => "",
        :padding => 0, :hs => '-'
    },
    'plain2' => {
        :rs => '', :fs => ':', :cross => '+',
        :lframe => '', :rframe => '',
        :hlframe => "", :hrframe => "",
        :hs => "-", :padding => 1,
    },
    'plain_alt' => {
        :rs => '', :fs => ' ', :cross => '+',
        :lframe => '', :rframe => '',
        :hlframe => "", :hrframe => "",
        :hs => "-", :padding => 1,
    },
    'fancy' => {
        :rs => '', :fs => '|', :cross => '+',
        :lframe => '', :rframe => '',
        :hlframe => "\e[1;7m", :hrframe => "\e[m",
        :padding => 1,
    },
}
            
# tabulate arrays, style can be simple/legacy
# data may come in in a format like
#   [   [a, b, c],  [d, e, [f, g]] .... ]
#   [ a, b, c] will be used as a single row
#   and [d, e,[f,g]] will be used as two rows
def tabulate(labels, data, indent = 0,style="simple" )
    raise "Invalid table style!"    unless  $template.keys.include? style
    raise 'Label and data do not have equal columns!' unless labels.size == data.transpose.size

    data = data.inject([]){|rs, r| rs += r.to_rows }
    data = data.unshift(labels).transpose
    padding = $template[style][:padding] 
    data = data.collect {|c| 
        c.collect {|e|  ' ' * padding + e.to_s + ' ' * padding } 
    }
    widths = data.collect {|c| c.collect {|a| a.width}.max } 
    newdata = []
    data.each_with_index {|c,i|
        newdata << c.collect { |e| e + ' '*(widths[i] - e.width) }
    }
    data = newdata
    data = data.transpose
    data = [ $template[style][:hlframe] + data[0].join($template[style][:fs]) + $template[style][:hrframe] ] + \
        data[1..-1].collect {|l| $template[style][:lframe] + l.join($template[style][:fs]) + $template[style][:rframe] }
    lines = []

    #add top frame
    if !$template[style][:tframe].to_s.empty?
        lines << $template[style][:cross] + widths.collect{|n| $template[style][:tframe] *n }.join($template[style][:cross]) + $template[style][:cross]
    end

    #add title 
    lines << data[0]

    #add title ruler
    if !$template[style][:hs].to_s.empty? and !$template[style][:lframe].to_s.empty?
        lines << $template[style][:cross] + widths.collect{|n| $template[style][:hs] *n }.join($template[style][:cross]) + $template[style][:cross]
    elsif !$template[style][:hs].to_s.empty?
        lines << widths.collect{|n| $template[style][:hs] *n }.join($template[style][:cross])
    end

    #add data
    data[1..-2].each{ |line|
        lines << line
        if !$template[style][:rs].to_s.empty?
            lines << $template[style][:cross] + widths.collect{|n| $template[style][:rs] *n }.join($template[style][:cross]) + $template[style][:cross]
        end
    }

    #add last record and bottom frame
    lines << data[-1]
    if !$template[style][:bframe].to_s.empty?
        lines << $template[style][:cross] + widths.collect{|n| $template[style][:bframe] *n }.join($template[style][:cross]) + $template[style][:cross]
    end

    #add indent
    lines.collect {|l| ' '*indent + l}.join("\n")
end

def assert(*msg)
    raise "Assertion failed! #{msg}" unless yield #if $DEBUG
end

class Array
    def to_rows
        a = collect{|i| i.is_a?(Array) ? i : [ i ]}
        nr = a.collect{|i| i.size}.max
        rows = []
        0.upto( nr-1 ) {|j| rows << a.collect{|i| i[j] ? i[j] : ''} }
        rows 
    end
end

class String
    if RUBY_VERSION >= '1.9'
        def contains_cjk?               # Oniguruma regex !!!
            (self =~ /\p{Han}|\p{Katakana}|\p{Hiragana}\p{Hangul}/)
        end
        def width
            gsub(/(\e|\033|\33)\[[;0-9]*\D/,'').split(//).inject( 0 ) do |s, i|
                s += i.contains_cjk? ? 2 : 1
                s 
            end
        end
    else
        def width
            gsub(/(\e|\033|\33)\[[;0-9]*\D/,'').size
        end
    end
end

if __FILE__ == $0
    source = [["\e[31maht\e[m",3],[4,"\e[33m你好\e[m"],['s',['abc','de']]]
    labels = ["a",'b']
    #formater = TableFormatter.new
    #formater.source = source 
    #formater.labels = labels
    #puts formater.display
    puts "Available themes: #{$template.keys.inspect}"
    $template.keys.each do |k|
        puts "#{k} :"
        puts tabulate(labels, source, 4, k)
        puts 
    end
end
