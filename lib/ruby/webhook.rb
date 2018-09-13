#!/home/roy/.rbenv/shims/ruby
# encoding: utf-8

require 'json'
require 'gemoji-parser'

def get_status(params)
  `uptime`.strip
end

def toggle_weechat(params)
  state = system("pgrep weechat &>/dev/null") ? "online" : "offline"
  action = params.dig("weechat")
  return "You are good. Nothing to do." if state == action
  case action
  when "online"
    system("tmux send-keys -t 0:1 weechat ENTER") ? "You are now online!" : "Something wrong happens..."
  when "offline"
    system("tmux send-keys -t 0:1 /bye ENTER") ? "You are now offline!" : "Something wrong happens..."
  else
    "Don't you dare to play with me!"
  end
end

def get_ip(params)
  require 'socket'

  addresses = Socket.ip_address_list.map(&:ip_address).grep(/^(?!(127\.0.*)|(172\.*))/)

  if addresses.length == 1
    "My address is #{addresses.first}."
  else
    "My addresses are #{addresses.join(", ")}."
  end
end

def to_payload(msg)
  { fulfillmentText: EmojiParser.detokenize(":dog: " + msg) }.to_json
end

def get_params(payload)
  JSON.parse(payload)
end

if __FILE__ == $0
  params = JSON.parse(ARGV.first)
  intent = params.dig( *%w(queryResult intent displayName) )
  option = params.dig( *%w(queryResult parameters ) )
  resp   = self.class.private_method_defined?( intent ) ? \
    send(intent, option) : "I do not know this command"
  puts to_payload(resp)
end
