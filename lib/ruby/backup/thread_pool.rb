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

class ThreadPool
    class Worker
        def initialize
            @mutex = Mutex.new
            @thread = Thread.new do
                while true
                    block = get_block
                    if block
                        block.call
                        reset_block
                    end
                end
            end
        end

        def get_block
            @mutex.synchronize {@block}
        end

        def set_block(block)
            #@mutex.synchronize do
            raise RuntimeError, "Thread already busy." if @block
            @block = block
            #end
        end

        def reset_block
            @mutex.synchronize {@block = nil}
        end

        def busy?
            @mutex.synchronize {!@block.nil?}
        end
    end

    attr_accessor :max_size
    attr_reader :workers

    def initialize(max_size = 10)
        @max_size = max_size
        @workers = []
        @mutex = Mutex.new
    end

    def size
        @mutex.synchronize {@workers.size}
    end

    def busy?
        @mutex.synchronize {@workers.any? {|w| w.busy?}}
    end

    def join
        sleep 0.01 while busy?
    end

    def process(&block)
        wait_for_worker.set_block(block)
    end

    def wait_for_worker
        while true
            worker = find_available_worker
            return worker if worker
            sleep 0.01
        end
    end

    def find_available_worker
        #@mutex.synchronize {free_worker || create_worker}
        free_worker || create_worker
    end

    def free_worker
        @workers.each {|w| return w unless w.busy?}; nil
    end

    def create_worker
        return nil if @workers.size >= @max_size
        worker = Worker.new
        @workers << worker
        worker
    end
end

