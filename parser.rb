module Md
  module Parser

  	def self.parser
  		@parser ||= Redcarpet::Markdown.new( CustomRenderer, extensions )
  	end

  	def self.render markdown_string
  		parser.render markdown_string
  	end

  private

  	def self.extensions
  		{
  			autolink: true,
  			space_after_headers: true,
  			no_intra_emphasis: true,
  			tables: true,
  			fenced_code_blocks: true,
  			disable_indented_code_blocks: true,
  			strikethrough:true,
  			lax_spacing: true,
  			superscript: true,
  			underline: true
  		}
  	end

  	class CustomRenderer < Redcarpet::Render::HTML
  		def initialize(options={})
  			super options.merge( hard_wrap: true, prettify: true )
  		end

  		def emphasis text
  			"<b class=\"ss-icon ss-block ss-social\" style=\"color:#bbb;\">#{text}</b>"
  		end

  		def header text, header_level
  			text.gsub!(/\(([^\)]*?)\)/,'<small>\1</small>')
  			"<h#{header_level}>#{text}</h#{header_level}>"
  		end
  	end
  end
end