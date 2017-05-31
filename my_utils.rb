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

usage "mate", "open NAME method in TextMate2 for editing"
def mate name
	begin
		method(name.to_sym).source_location
	end
	system 'mate', "#{file} -l #{line}"
end

usage "copy", "copy STRING to system clipboard"
def copy string
  IO.popen('pbcopy', 'w') { |pb| pb << string.to_s }
end

usage "paste", "paste from system clipboard"
def paste
  `pbpaste`
end

usage "copy_history", "copy current IRB session, line for line, to system clipboard"
def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("quit") || -1
  content = history[(index+1)..-2].join("\n")
  ap content
  copy content
end
