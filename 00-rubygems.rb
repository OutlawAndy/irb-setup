#!/usr/bin/env ruby
# -*- ruby -*-

begin
	require 'rubygems'
	require 'irb/completion'
	require 'irb/ext/save-history'
	require 'awesome_print'
rescue LoadError => e
	e.message
end

begin
	AwesomePrint.irb!
rescue
end