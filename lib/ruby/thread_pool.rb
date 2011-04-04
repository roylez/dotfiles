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
            @thread = Thread.new { } 
        end

        def process(&block)
            @thread = Thread.new do
                block.call
                changed
                notify_observers self
            end
        end

        def join
            @thread.join
        end
    end

    attr_accessor :max_size
    attr_reader :workers

    def initialize(max_size = 10)
        @mutex = Mutex.new
        @max_size = max_size
        @workers = Queue.new
        @working_workers = [ ]
        @max_size.times {|i| 
            worker = Worker.new
            @workers << worker
            worker.add_observer(self)
        }
    end

    def wait
        @working_workers.each { |w| w.join }
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
        @working_workers << worker
    end
end

