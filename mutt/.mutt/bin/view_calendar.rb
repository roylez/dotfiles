#!/usr/bin/env ruby

require "icalendar" # gem install icalendar

begin
  cals = Icalendar::Calendar.parse($<)
  cals.each do |cal|
    cal.events.each do |event|
      puts "Organizer: #{event.organizer}"
      puts "Event:     #{event.summary}"
      puts "Starts:    #{event.dtstart.to_time.getlocal} local time"
      puts "Ends:      #{event.dtend.to_time.getlocal}"
      puts "Location:  #{event.location}"   if event.location
      puts "Contact:   #{event.contact}"    unless event.contact.empty?
      puts "Description:\n#{event.description}"   unless event.description.empty?
    end
  end
rescue
  puts "! FAILED TO PARSE CALENDAR EVENT !"
end
