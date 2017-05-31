#!/usr/bin/env ruby

module Lustro
  PublicMethods  = lambda { |cls| cls.public_instance_methods(false).sort }
  PrivateMethods = lambda { |cls| cls.private_instance_methods(false).sort }
  AllMethods     = lambda { |cls|
    (cls.public_instance_methods(false) +
      cls.private_instance_methods(false)).uniq.sort
  }

  def self.formatter
    @formatter ||= ColorFormatter.new
  end

  def self.formatter=(new_formatter)
    @formatter = new_formatter
  end

  def self.methods_for_class(cls,  getter=PublicMethods)
    cls.ancestors.map { |ruby_class|
      [ruby_class, normalize(getter[ruby_class])]
    }
  end

  def self.methods_for_object(obj, getter=PublicMethods)
    result = methods_for_class(obj.class, getter)
    left_overs = obj.methods - obj.class.public_instance_methods
    result.unshift([:singleton, normalize(left_overs)]) unless left_overs.empty?
    result
  end

  def self.format_help
    puts "\e[1mUsage:\e[m m obj[, options]"
    puts
    puts "\e[1mOptions:\e[m"
    puts "\e[32m  <int>                 \e[35m--\e[33m Include only the first <int> ancestors.\e[m"
    puts "\e[32m  <-int>                \e[35m--\e[33m Omit the last <int> ancestors.\e[m"
    puts "\e[31m  /re/                  \e[35m--\e[33m Include only methods matching re.\e[m"
    puts "\e[30m  <class>               \e[35m--\e[33m Include only methods from class.\e[m"
    puts "\e[34m  :deep                 \e[35m--\e[33m Include Object and its ancestors.\e[m"
    puts "\e[34m  :omit\e[33m, \e[30m<class> \e[36m(:o)   \e[35m--\e[33m Exclude <class> and its ancestors.\e[m"
    puts "\e[34m  :instance      \e[36m(:i)   \e[35m--\e[33m Instance methods when obj is a class.\e[m"
    puts "\e[34m  :class         \e[36m(:c)   \e[35m--\e[33m Class methods from an instance.\e[m"
    puts "\e[34m  :public        \e[36m(:pub) \e[35m--\e[33m Public methods only (default).\e[m"
    puts "\e[34m  :private       \e[36m(:p)   \e[35m--\e[33m Private methods only.\e[m"
    puts "\e[34m  :all                  \e[35m--\e[33m Public and private methods.\e[m"
    puts "\e[34m  :ancestors     \e[36m(:a)   \e[35m--\e[33m Display Ancestors.\e[m"
    puts "\e[34m  :singleton     \e[36m(:s)   \e[35m--\e[33m Include only singleton methods.\e[m"
    puts "\e[34m  :flat          \e[36m(:f)   \e[35m--\e[33m Flatten the display into a single list of methods.\e[m"
    puts "\e[34m  :full                 \e[35m--\e[33m List all ancestors, even if method list is empty.\e[m"
    puts "\e[34m  :noalpha       \e[36m(:na)  \e[35m--\e[33m Disable alphabetic bin sorting.\e[m"
    puts "\e[34m  :nocolor       \e[36m(:nc)  \e[35m--\e[33m Display without color.\e[m"
  end

  def self.format(*args)
    if args.empty?
      format_help
      return
    end
    obj = args.shift
    fmt = formatter

    format_opts = {}
    methods = methods_for_object(obj)
    args << :omit << Object unless args.any? { |arg|
      arg.is_a?(Integer) ||
      arg.is_a?(Module) ||
      arg == :singleton || arg == :s ||
      arg == :deep || arg == :d
    }
    args.each do |arg|
      if format_opts[:omit] == :omit
        fail "'#{arg}' should be a class" unless arg.is_a?(Class)
        format_opts[:omit] = arg
        next
      end

      case arg
      when Regexp
        methods = filter(methods, arg)
      when Integer
        if arg < 0
          methods = methods[0 .. arg-1]
        elsif arg > 0
          methods = methods[0,arg]
        else
          # do nothing
        end
      when Module, Class
        methods = [methods.assoc(arg) || ["<#{arg} not found>", []]]
      when :deep, :d
        # do nothing
      when :singleton, :s
        methods = [methods.assoc(:singleton) || ["<:singleton not found>", []]]
      when :instance, :i
        fail ":instance requires a class object" unless obj.is_a?(Module)
        methods = methods_for_class(obj)
      when :class, :c
        methods = methods_for_object(obj.class)
      when :full
        format_opts[:full] = true
      when :private, :priv, :p
        methods = methods_for_object(obj, PrivateMethods)
        if methods.first.first == :singleton
          methods.shift
        end
        format_opts[:label] = "private"
      when :public, :pub
        methods = methods_for_object(obj, PublicMethods)
      when :all
        methods = methods_for_object(obj, AllMethods)
        format_opts[:label] = "all"
      when :omit, :o
        format_opts[:omit] = :omit
      when :flat, :f
        format_opts[:flat] = true
      when :noalpha, :na
        format_opts[:noalpha] = true
      when :nocolor, :nc
        fmt = Formatter.new
      when :ancestors, :a
        fmt.display_method_list(obj.class.ancestors)
        return
      else
        puts "Unrecognized option: #{arg.inspect}"
        return
      end
    end
    fmt.display(methods, format_opts)
    nil
  end

  def self.filter(methods, re)
    methods.map { |rc, ms|
      list = ms.grep(re)
      [rc, list]
    }
  end

  def self.normalize(list)
    list.map { |it| it.to_s }.sort
  end

  class Formatter
    attr_reader :options

    def emit(string)
      puts string
    end

    def display(methods, opts)
      @options = opts
      if options[:flat]
        list = methods.map { |rc, ms| ms }.flatten.sort
        the_class = methods.map { |m| m.first }.detect { |m| ! m.is_a?(Symbol) }
        display_scope(["#{the_class} (flat)", list])
      else
        methods.each do |scope|
          break if scope.first == options[:omit]
          display_scope(scope)
        end
      end
      @options = {}
    end

    def display_break
      emit
    end

    def display_class(ruby_class, method_list)
      string = ruby_class.to_s
      string << "/#{options[:label]}" if options[:label]
      string << " (#{method_list.size})"
      emit string
    end

    def display_scope(scope)
      ruby_class, method_list = scope
      if ! method_list.empty? || options[:full]
        display_class(ruby_class, method_list)
        display_methods(method_list)
        display_break
      end
    end

    def display_methods(methods)
      if options[:noalpha]
        display_method_list(methods)
      else
        categories = categorize_methods(methods)
        display_categories(categories)
      end
    end

    def display_categories(categories)
      categories.keys.sort.each do |k|
        display_method_list(categories[k])
      end
    end

    def display_method_list(method_list)
      emit "  #{method_list.join(' ')}"
    end

    def categorize_methods(methods)
      result = Hash.new { |h,k| h[k] = [] }
      methods.sort.each do |m|
        if m =~ /^[a-zA-Z]/
          result[m[0,1]] << m
        else
          result["@"] << m
        end
      end
      result
    end
  end

  module Color
    #shamelessly stolen (and modified) from redgreen
    COLORS = {
      :clear   => 0,  :black   => 30, :red   => 31,
      :green   => 32, :yellow  => 33, :blue  => 34,
      :magenta => 35, :cyan    => 36,
    }

    module_function

    COLORS.each do |color, value|
      module_eval "def #{color}(string); colorize(string, #{value}); end"
      module_function color
    end

    def colorize(string, color_value)
      if ENV['NO_COLOR']
        string
      else
        color(color_value) + string.to_s + color(COLORS[:clear])
      end
    end

    def color(color_value)
      "\e[#{color_value}m"
    end
  end

  class ColorFormatter < Formatter
    include Color

    def emit(str="")
      if @color
        puts @color[str]
      else
        puts str
      end
    end

    def c(color)
      @color = lambda { |s| send(color, s) }
      yield
    ensure
      @color = nil
    end

    def display_class(*args)
      c(:yellow) { super }
    end

    def display_method_list(*args)
      c(:cyan) { super }
    end
  end

  self.formatter = ColorFormatter.new
end

usage "m", "Methods for an object ('m' with no args for details)"
def m(*args)
  Lustro.format(*args)
  nil
end
