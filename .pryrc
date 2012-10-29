#!/usr/bin/env ruby
Pry.config.theme = 'pry-modern'

Pry.config.prompt = [
  proc { |target_self, nest_level, pry|
  "[\e[34;1m#{pry.input_array.size}\e[m] \e[31;1;7m #{Pry.view_clip(target_self)} \e[m#{":#{nest_level}" unless nest_level.zero?}> "
  },
  proc { |target_self, nest_level, pry|
  "[\e[34;1m#{pry.input_array.size}\e[m] \e[32;1;7m #{Pry.view_clip(target_self)} \e[m#{":#{nest_level}" unless nest_level.zero?}* "
  },
]


module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end

  { :r => :require,
    :x => :exit,
  }.each { |n,o| 
    define_method(n) {|*arg| 
      suppress_warnings{send(o,*arg) } 
    }
  }
end
