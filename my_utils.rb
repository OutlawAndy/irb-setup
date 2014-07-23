#!/usr/bin/env ruby
# -*- ruby -*-

def local_methods obj = self
  (obj.methods - obj.class.superclass.instance_methods).sort
end

def ri method = nil
  unless method && method =~ /^[A-Z]/ # if class isn't specified
    klass = self.kind_of?(Class) ? name : self.class.name
    method = [klass, method].compact.join('#')
  end
  system 'ri', method.to_s
end

def mate name
	begin
		method(name.to_sym).source_location
	end
	system 'mate', "#{file} -l #{line}"
end

def copy string
  IO.popen('pbcopy', 'w') { |pb| pb << string.to_s }
end

def paste
  `pbpaste`
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("quit") || -1
  content = history[(index+1)..-2].join("\n")
  ap content
  copy content
end
