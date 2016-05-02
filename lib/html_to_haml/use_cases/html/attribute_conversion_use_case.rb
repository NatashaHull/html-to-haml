require_relative '../../html_to_haml'

module HtmlToHaml::Html
  class AttributeConversionUseCase
    def initialize(html)
      @html = html
    end

    def convert
      erb_converted_html = fix_erb_attributes(html: @html)
      erb_converted_html.gsub(/^\s*%(.*)$/) do |matched_elem|
        haml_with_replaced_attributes(haml: matched_elem)
      end
    end

    def haml_with_replaced_attributes(haml:)
      attributes_hash = []
      haml_without_attributes = haml.gsub(/\s+([a-zA-Z1-9]+?)=('|").*?('|")/) do |matched_elem|
        attr = handle_erb_attributes(attr: matched_elem)
        attributes_hash << attr.strip.gsub(/=/, ': ')
        ''
      end
      attributes_hash.empty? ? haml_without_attributes : "#{haml_without_attributes}{ #{attributes_hash.join(', ')} }"
    end

    def fix_erb_attributes(html:)
      # Erb attributes may be malformed to have their own line and a '=' in front
      # This changes them back into something that can be updated above
      html.gsub(/^\s*%.*[a-zA-Z1-9]+?=('|")[^'"]*\s*\n\s*=.*\n\s*[^'"]*("|')/) do |erb_attr|
        erb_attr.gsub(/\n\s*(=|.*?'|.*?")/, ' \1')
      end
    end

    def handle_erb_attributes(attr:)
      attr.gsub(/=('|")(.*?)\s*=\s*([^\s]*)(\s*.*)('|")/, '=\1\2 #{\3}\4\5') # put erb text inside #{} globally
          .gsub(/('|")\s*#\{(.*)\}\s*('|")/, '\2') # Remove strings and #{} around simple erb expressions (with no non-erb)
          .gsub(/\s('|")$/, '\1')  # Get rid of any extra whitespace.
    end
  end
end