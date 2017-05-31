# -*- ruby -*-

Numeric.class_eval do

  def ordinalize
    suffix = if (11..13).include?(self % 100)
      "th"
    else
      case self % 10
        when 1; "st"
        when 2; "nd"
        when 3; "rd"
        else    "th"
      end
    end
    "#{self}#{suffix}"
  end

  def as_time
    Time.at self
  end

  def to_pretty_time opts = {}
    as_time.pretty opts
  end
  alias_method :pretty, :to_pretty_time

  def one?
    !!( self == 1 )
  end

  def two?
    !!( self == 2 )
  end

  def three?
    !!( self == 3 )
  end

  def not_zero?
    !!( self > 0 )
  end
  alias_method :ok?, :not_zero?

  def as_phone
    to_s.as_phone_number
  end

end

Integer.class_eval do

  def to_d
    to_s.to_d
  end

  def format_seconds
    if self > 60
      "%.1f min" % to_d./(60)
    else
      "%.1f sec" % to_d
    end
  end
  alias_method :to_minutes, :format_seconds

end


String.class_eval do
  def remove pattern
    gsub pattern, ''
  end
  alias :cut :remove

  def dehumanize space_substitute = "-"
    if space_substitute.downcase.start_with?('camel')
      strip.downcase.cut(/[^a-z0-9\s]/).capitalize.gsub(/\s(.)/){$1.upcase}
    else
      strip.downcase.cut(/[^a-z0-9\s]/).gsub /\s/, space_substitute
    end
  end

  def as_time
    Time.at self.to_i
  end

  def numbers
    strip.remove(/\D/)
  end

  def phone_format
    numbers = strip.remove(/^\+?1/).remove(/\D/)
    if numbers.length > 10
      numbers.gsub(/^(\d{3})(\d{3})(\d{4})(\d*)/,'(\1) \2-\3 x\4')
    else
      numbers.gsub(/^(\d{3})(\d{3})(\d{4})/,'(\1) \2-\3')
    end
  end

  def find_and_replace hash
    gsub Regexp.union(hash.keys), hash
  end

end

Date.class_eval do
  def pretty opts = {}
    to_time.pretty opts
  end

  def self.days_in_month month, year = Date.today.year
    new(year, month, -1).day
  end

  def weekday?
    !weekend?
  end

  def weekend?
    !!( saturday? || sunday? )
  end

  def school_year
    if month > 6
      "#{year}-#{next_year.year.to_s[2..-1]}"
    else
      "#{last_year.year}-#{year.to_s[2..-1]}"
    end
  end

end

Time.class_eval do
  def pretty options = {}
    sep = options[:seperator] || ","
    pretty = self.strftime("%B ")
    pretty = self.strftime("%b ") if options[:month] == :short
    pretty<< self.strftime("%d").to_i.ordinalize
    pretty = self.strftime("%-m/%-d/%y") if options[:month] == :micro
    pretty<< self.strftime("#{sep} %Y") if options[:year] == true
    pretty<< self.strftime(" %y") if options[:year] == :short
    pretty<< self.strftime(" at %-l:%M%P") if options[:time] == true
    pretty<< self.strftime("#{sep} %-l:%M%P") if options[:time] == :short
    pretty<< self.strftime(" (%-l%P)") if options[:time] == :hour
    pretty.prepend self.strftime("%A#{sep} ") if options[:day] == true
    pretty.prepend self.strftime("%a#{sep} ") if options[:day] == :short
    pretty
  end

  def to_epoch
    to_i
  end

  def to_serial_string
    strftime('%m%d%y%H%M%S')
  end

  def weekday?
    !weekend?
  end

  def weekend?
    !!( saturday? || sunday? )
  end

end
