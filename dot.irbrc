#!/usr/bin/env ruby
# -*- ruby -*-

Dir["~/.irb.d/**/*.rb"].sort.each do |fn|
  next if fn =~ /_test.rb$/
  load fn
end