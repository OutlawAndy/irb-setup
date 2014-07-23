# -*- ruby -*-

class<<( Helper = self )
  begin
    include ::ActiveSupport::NumberHelper
  rescue
  end
end

TIME_PRETTIFIER = ->(obj, options){
  pretty = obj.strftime('%B ')
  pretty = obj.strftime('%b ') if options[:month] == :short
  pretty<< obj.instance_eval( "obj.strftime('%d').to_i.ordinalize" )
  pretty<< obj.strftime(', %Y') if options[:year] == true
  pretty<< obj.strftime(" '%y") if options[:year] == :short
  pretty<< obj.strftime(' at %-l:%M%P') if options[:time] == true
  pretty<< obj.strftime(', %-l:%M%P') if options[:time] == :short
  pretty<< obj.strftime(' (%-l%P)') if options[:time] == :hour
  pretty.prepend obj.strftime('%A, ') if options[:day] == true
  pretty.prepend obj.strftime('%a, ') if options[:day] == :short
  pretty
}

Numeric.class_eval do

  def to_money
    Helper.number_to_currency self
  end
  alias :money :to_money

  def to_dollars
    try(:/,100)
  end
  alias :to :to_dollars

  def to_cents
    try(:*,100).to_i
  end

  def as_time
    Time.at self
  end

  def to_pretty_time opts = {}
    self.as_time.pretty opts
  end
  alias :pretty :to_pretty_time

  def not_zero?
    !!( self > 0 )
  end
  alias :ok? :not_zero?

  def as_phone
    Helper.number_to_phone self, area_code: true
  end

end

Fixnum.class_eval do

  def to_d
    to_s.to_d
  end

  def to_money divisor=100
    to_d./(divisor).to_money
  end

  def to_dollar divisor=100
    to_d./(divisor)
  end
  alias :to_dollars :to_dollar

  def format_seconds
    if self > 60
      "%.1f min" % to_d./(60)
    else
      "%.1f sec" % to_d
    end
  end
  alias :to_minutes :format_seconds

end


String.class_eval do

  def as_time
    Time.at self.to_i
  end

  def to_cents
    to_d.to_cents
  end

  def to_number
    digits = self.sub!(/^\s*/,"") # remove leading spaces
    digits.sub!(/^\+?1/,"")       # remove country code, e.g. '+1' or '1'
    digits.gsub!(/[^\d]/,"")      # remove remaining fluff, leaving only the phone digits
    digits                        # return the new phone number string
  end

  def as_phone
    Helper.number_to_phone self.to_number, area_code: true
  end

  def as_phone_number
    self.to_number.as_phone
  end

  def render_as_html
    MD::Parser.render( self ).html_safe rescue nil
  end
end

Time.class_eval do
  def pretty opts = {}
    TIME_PRETTIFIER.( self, opts )
  end
end

Date.class_eval do
  def pretty opts = {}
    TIME_PRETTIFIER.( self, opts )
  end
end

Time.class_eval do
  usage "pretty", 'TIME.pretty [, month: :short][, year: true][, year: :short][, time: true][, day: true][, day: :short]'
  def pretty opts = {}
    TIME_PRETTIFIER.( self, opts )
  end

  def to_epoch
    self.to_i
  end

  def to_serial_string
    strftime('%m%d%y%H%M%S')
  end
end

Hash.class_eval do
  def to_query_string
    q = Rack::Utils.build_nested_query self
    # if self.map{|k,v| v.respond_to?( :to_hash ) || v.respond_to?( :to_a ) }
    #   Rack::Utils.build_nested_query self
    # else
    #   Rack::Utils.build_query self
    # end
  end
end