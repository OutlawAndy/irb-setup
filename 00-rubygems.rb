#!/usr/bin/env ruby
# -*- ruby -*-

begin
	require 'rubygems'
	require 'irb/completion'
	require 'irb/ext/save-history'
	require 'awesome_print'
  require 'active_support'
  require 'terminal-table'
  require 'minitest/autorun'
  require 'shoulda'
  require 'lustro'

rescue LoadError => e
	puts ">> #{e.message}"
end

begin
	AwesomePrint.irb!
rescue Exception => e
	puts ">> #{e.message}"
end