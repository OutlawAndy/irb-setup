#!/usr/bin/env ruby
# -*- ruby -*-

unless Object.const_defined?("HELP")
  Object.const_set("HELP", [])
end

def usage(method_name=nil, comment=nil)
  if method_name.nil?
    width = HELP.collect { |pair| pair[0].size }.max
    HELP.sort.each do |name, desc|
      printf "%-#{width}s -- %s\n", name, desc
    end
  elsif comment.nil?
    puts "Usage: usage 'method_name', 'comment'"
  else
    HELP << [method_name, comment]
  end
  nil
end

usage "h", "Display help"
alias h usage


begin
  require 'rubygems'
  require 'awesome_print'
  require 'active_support'
  require 'factory_girl'
  require 'redcarpet'
  require 'terminal-table'
  require 'irb/completion'
  require 'irb/ext/save-history'
rescue LoadError => e
  puts ">> #{e.message}"
end

begin
  AwesomePrint.irb!
rescue
  puts "No AwesomePrint...\n   Not Awesome!!"
end


IRB.conf[:SAVE_HISTORY]  = 10_000
IRB.conf[:HISTORY_FILE]  = "#{ENV['HOME']}/.irb_history"
IRB.conf[:IGNORE_SIGINT] = true
IRB.conf[:USE_READLINE]  = nil
IRB.conf[:PROMPT_MODE]   = :SIMPLE
IRB.conf[:AUTO_INDENT]   = true
