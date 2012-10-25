#!/usr/bin/env ruby
Pry.config.theme = 'pry-modern'

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
