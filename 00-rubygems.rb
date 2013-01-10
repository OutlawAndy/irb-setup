#!/usr/bin/env ruby
# -*- ruby -*-

begin
	require 'rubygems'
	require 'irb/completion'
	require 'irb/ext/save-history'
rescue LoadError => e
	puts e.message
end