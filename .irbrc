#!/usr/bin/env ruby
require 'rubygems' unless RUBY_VERSION > '1.9'
%w(wirble pp irb/completion).each {|m| require m}

ARGV << ' --readline'
# start wirble (with color)

Wirble.init(:skip_prompt => true, :skip_history => true)
Wirble.colorize

#IRB.conf.merge! \
    #:PROMPT_MODE => :INF_RUBY,
    #:AUTO_INDENT => true,
    #:SAVE_HISTORY => 10000,
    #:HISTORY_FILE => "#{ENV['HOME']}/.irb-save-history"

def history(how_many = 50)
    return false unless how_many.class == Fixnum
    history_size = Readline::HISTORY.size

    # no lines, get out of here
    puts "No history" and return if history_size == 0

    start_index = 0

    # not enough lines, only show what we have
    if history_size <= how_many
        how_many  = history_size - 1
        end_index = how_many
    else
        end_index = history_size - 1 # -1 to adjust for array offset
        start_index = end_index - how_many 
    end

    start_index.upto(end_index) {|i| print_line i}
    nil
end
#alias :h  :history

# -2 because -1 is ourself
def history_do(lines = (Readline::HISTORY.size - 2))
    irb_eval lines
    #nil
end 
#alias :h! :history_do

def history_write(filename, lines)
    file = File.open(filename, 'w')

    get_lines(lines).each do |l|
        file << "#{l}\n"
    end

    file.close
end
#alias :hw :history_write

module Kernel
    { :h => :history,
        :h! => :history_do,
        :hw => :history_write,
        :r => :require,
        :x => :exit
    }.each { |n,o| alias_method n, o }
end

private
def get_line(line_number)
    Readline::HISTORY[line_number]
end

def get_lines(lines = [])
    return [get_line(lines)] if lines.is_a? Fixnum

    out = []

    lines = lines.to_a if lines.is_a? Range

    lines.each do |l|
        out << Readline::HISTORY[l]
    end

    return out
end

def print_line(line_number, show_line_numbers = true)
    print "[%04d] " % line_number if show_line_numbers
    puts get_line(line_number)
end

def irb_eval(lines)
    to_eval = get_lines(lines)
    to_eval.each {|l| Readline::HISTORY << l}
    puts to_eval
    eval to_eval.join("\n")
end

if $0 =~ /.*irb/
    HISTFILE    = "#{ENV['HOME']}/.irb_history"
    MAXHISTSIZE = 3000

    if defined? Readline::HISTORY
      histfile = File::expand_path( HISTFILE )
      if File::exists?( histfile )
        lines = IO::readlines( histfile ).collect {|line| line.chomp}
        puts "Read %d saved history commands from %s." %
          [ lines.size, histfile ] if $DEBUG || $VERBOSE
        Readline::HISTORY.push( *lines )
      else
        puts "History file '%s' was empty or non-existant." %
          histfile if $DEBUG || $VERBOSE
        touch histfile
      end
 
      Kernel::at_exit {
        lines = Readline::HISTORY.to_a.reverse.uniq.reverse
        lines = lines[ -MAXHISTSIZE, MAXHISTSIZE ] if lines.length > MAXHISTSIZE
        $stderr.puts "Saving %d history lines to %s." % [ lines.length, histfile ] if $VERBOSE || $DEBUG
        File::open( histfile, File::WRONLY|File::CREAT|File::TRUNC ) {|ofh|
          lines.each {|line| ofh.puts line }
        }
      }
    end
end
