#!/usr/bin/env ruby
# -*- ruby -*-

begin
	require 'rubygems'
	require 'irb/completion'
	require 'irb/ext/save-history'
	require 'awesome_print'
  # require 'active_support/number_helper'
  require 'active_support/core_ext'
  require 'terminal_table'
  require 'test/unit'
  require 'shoulda'
  require 'lustro'

rescue LoadError => e
	e.message
end

begin
	AwesomePrint.irb!
rescue
end