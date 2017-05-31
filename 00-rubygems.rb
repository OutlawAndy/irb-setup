#!/usr/bin/env ruby
# -*- ruby -*-

unless Object.const_defined?("HELP")
  Object.const_set("HELP", {})
end

def usage(method_name=nil, comment=nil)
  if method_name.nil?
    width = HELP.keys.max_by(&:length).length.to_i
    HELP.sort.each do |(name, desc)|
      printf "\e[36m%-#{width}s \e[35m--\e[33m %s\e[m\n", name, desc
    end
  elsif comment.nil?
    puts "Usage: usage 'method_name', 'comment'"
  else
    HELP[method_name] = comment
  end
  nil
end

usage "h", "Display help"
alias h usage


begin
  require 'date'
  require 'awesome_print'
  require 'pry'
  # require 'active_support'
  # require 'factory_girl'
  require 'redcarpet'
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

begin
  Pry.start
rescue
  puts "No Pry :-("
end


IRB.conf[:SAVE_HISTORY]  = 100_000
IRB.conf[:HISTORY_FILE]  = "#{ENV['HOME']}/.irb_history"
IRB.conf[:IGNORE_SIGINT] = true
IRB.conf[:USE_READLINE]  = nil
IRB.conf[:PROMPT_MODE]   = :SIMPLE

IRB.conf[:PROMPT][:SIMPLE] = {
  PROMPT_I: "\e[30m\(\e[31m%n\e[30m\)\e[m\e[30m>>\e[m ",
  PROMPT_S: " \e[35m%l\e[m \e[30m>>\e[m "
}

IRB.conf[:PROMPT_MODE]   = :SIMPLE