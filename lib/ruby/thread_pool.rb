#!/usr/bin/env ruby
# coding: utf-8
#Description: http://snippets.dzone.com/posts/show/3276

=begin usage
    pool = ThreadPool.new(10) # up to 10 threads
    email_addresses.each do |addr|
        pool.process {send_mail_to addr}
    end
    pool.join
=end 

require 'thread'
require 'observer'

Thread.abort_on_exception = true

class ThreadPool
    class Worker
        include Observable

        def initialize
            @thread = Thread.new do
                loop do
                    block = get_block
                    if block
                        block.call
                        @block = nil
                        changed     #job done, notify observer
                        notify_observers(self) 
                    end
                end
            end
        end
        def process(&block)
            @block = block
        end
        def get_block
            @block
        end
    end

    attr_accessor :max_size
    attr_reader :workers

    def initialize(max_size = 10)
        @mutex = Mutex.new
        @max_size = max_size
        @workers = Queue.new
        @max_size.times {|i| 
            worker = Worker.new
            @workers << worker
            worker.add_observer(self)
        }
    end

    def wait
        sleep 0.01 until @workers.size == @max_size
    end

    # callback from Observables
    def update(worker) 
        @workers << worker 
        puts "#{worker} back to work!"  if $DEBUG
    end

    def process(&block)
        worker = @workers.pop
        puts "#{@max_size - @workers.size} threads working..."  if $DEBUG
        worker.process(&block)
    end
end

