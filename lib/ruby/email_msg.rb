#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)
#Description: 发送一封邮件
require 'fileutils'

def email_message(address, msg, opts = {})
  opts = {:subject => "Attention", :from => 'Ether <ether@void.com>'}.merge( opts )
  tmpfile = "/tmp/mutt_msg.tmp"

  open(tmpfile, 'w') do |f|
    f.puts "Subject: #{opts[:subject]}"
    f.puts "From: #{opts[:from]}"
    f.puts "To: #{opts[:to]}"
    f.puts msg
    if opts[:attach]
      f.puts(IO.popen("cat #{opts[:attach]}|uuencode #{opts[:attach]}").read)
    end
  end
  sendmail_cmd = opts[:sendmail] || 'sendmail'

  sendmail = "#{sendmail_cmd} -f #{opts[:from]} #{opts[:to]} < #{tmpfile}"

  #sendmail = "mutt " << "-s '#{opts[:subject]}' " \
                    #<< "-e'set from=\"#{opts[:from]}\"' " \
                    #<< (opts[:attach] ? ("-a " + opts[:attach] + ' ') : '') \
                    #<< "#{address} " << " < #{tmpfile}"

  #open(tmpfile, 'w') {|f| f.puts msg}

  system sendmail

  FileUtils.rm(tmpfile)
end

if __FILE__==$0
  require 'optparse'
  options = {}
  OptionParser.new {|opts|
    opts.banner = <<-EOS
      Usage: #{$0} [options] [arguments] ABC@DEF.com 'MESSAGE BODY'

        Message will be sent in UTF-8, and east Asian characters in body are supported.

    EOS

    opts.on("-s","--subject SUBJECT", "Email subject") do |sub|
      options[:subject] = sub
    end
    options[:from] = 'bender <bender@unknown.com>'
    opts.on("-f","--from EMAIL_ADDRESS", "Email sender address") do |from|
      options[:from] = from
    end
    opts.on("-t","--to EMAIL_ADDRESS", "Email receiver address") do |to|
      options[:to] = to
    end
    opts.on("-a","--attach ATTACHMENT", "Attachment to be enveloped") do |file|
      raise "File not found" unless File.file? file
      options[:attach] = file
    end
    opts.on("--sendmail SENDMAIL", "Specify sendmail program") do |sendmail|
      options[:sendmail] = sendmail
    end
    opts.on("-h","--help", "Print this help") do
      puts opts
      exit
    end
  }.parse!

  abort "Error: invalid recipient address!"  unless options[:to] =~ /\w+@(\w+\.)+\w+/

  msg = ARGV.empty? ? ARGF.read.strip : ARGV.join(" ")

  exit if msg.empty?

  $stderr.puts "Warning: Message body empty!"  if msg.empty?

  email_message(options[:to], msg, options)
end
