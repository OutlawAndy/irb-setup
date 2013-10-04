# -*- ruby -*-
require 'active_support/number_helper'
require 'active_support/core_ext'

class<<( Helper = self )
	include ActiveSupport::NumberHelper
end

Float.class_eval do

	def to_money
		Helper.number_to_currency self
	end
	alias money to_money

	def to_dollar
		try(:/,100)
	end
	alias to to_dollar


	def to_cents
		try(:*,100).to_i
	end

end


Fixnum.class_eval do

	def as_time
		Time.at self
	end

	def to_d
		to_f
	end

	def to_money divisor=100
		to_d./(divisor).to_money
	end

	def to_dollar divisor=100
		to_d./(divisor)
	end

	def format_seconds
		if self > 60
			"%.1f min" % to_d./(60)
		else
			"%.1f sec" % to_d
		end
	end
	alias to_minutes format_seconds

end

Numeric.class_eval do

	def to_phone
		Helper.number_to_phone self, area_code: true
	end

end

String.class_eval do

	def as_time
		Time.at self.to_i
	end

	def to_cents
		to_f.to_cents
	end

	def to_number
		digits = self.sub!(/^\s*/,"") # remove leading spaces
		digits.sub!(/^\+?1/,"")       # remove country code, e.g. '+1' or '1'
		digits.gsub!(/[^\d]/,"")      # remove remaining fluff, leaving only the phone digits
		digits.to_i                   # return digits
	end

	def to_phone
		Helper.number_to_phone self.to_number, area_code: true
	end

	def render_as_html
		MD::Parser.render( self ).html_safe
	end
end

DateTime.class_eval do

	def to_epoch
		strftime('%s').to_i
	end

end

Time.class_eval do
	def prettify options = {}
		pretty = self.strftime('%B ')
		pretty = self.strftime('%b ') if options[:month] == :short
		pretty<< self.instance_eval( "self.strftime('%d').to_i.ordinalize" )
		pretty<< self.strftime(', %Y') if options[:year] == true
		pretty<< self.strftime(" '%y") if options[:year] == :short
		pretty<< self.strftime(' at %-l:%M%P') if options[:time] == true
		pretty.prepend self.strftime('%A, ') if options[:day] == true
		pretty.prepend self.strftime('%a, ') if options[:day] == :short
		pretty
	end
end