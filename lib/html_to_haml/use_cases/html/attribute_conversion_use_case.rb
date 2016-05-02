require 'singleton'
require_relative '../../html_to_haml'

module HtmlToHaml::Html
  class AttributeConversionUseCase
    include Singleton

    HAML_TAG_LINES = "^\s*%(.*)$"
    MULTILINE_ERB_ATTRIBUTES_REGEX = /^\s*%.*[a-zA-Z1-9]+?=('|")[^'"]*\s*\n\s*=.*\n\s*[^'"]*("|')/

    def convert_attributes(html:)
      erb_converted_html = remove_erb_newlines(html: html)
      erb_converted_html.gsub(/#{HAML_TAG_LINES}/) do |matched_elem|
        haml_with_replaced_attributes(haml: matched_elem)
      end
    end

    private

    def haml_with_replaced_attributes(haml:)
      attributes_hash = []
      haml_without_attributes = haml.gsub(/\s*([a-zA-Z1-9]+?)=('|").*?('|")/) do |matched_elem|
        attr = escape_erb_attributes(attr: matched_elem)
        attributes_hash << attr.strip.gsub(/=/, ': ')
        ''
      end
      attributes_hash.empty? ? haml_without_attributes : "#{haml_without_attributes}{ #{attributes_hash.join(', ')} }"
    end

    def remove_erb_newlines(html:)
      # Erb attributes may be malformed to have their own line and a '=' in front
      # (if the html already went through the erb converter)
      # This changes them back into something that can be updated above
      html.gsub(MULTILINE_ERB_ATTRIBUTES_REGEX) do |erb_attr|
        erb_attr.gsub(/\n\s*(=|.*?'|.*?")/, ' \1')
      end
    end

    def escape_erb_attributes(attr:)
      attr.gsub(/=('|")(.*?)\s*=\s*([^\s]*)(\s*.*)('|")/, '=\1\2 #{\3}\4\5') # put erb text inside #{} globally
          .gsub(/('|")\s*#\{(.*)\}\s*('|")/, '\2') # Remove strings and #{} around simple erb expressions (with no non-erb)
          .gsub(/\s('|")$/, '\1')  # Get rid of any extra whitespace.
    end
  end
end