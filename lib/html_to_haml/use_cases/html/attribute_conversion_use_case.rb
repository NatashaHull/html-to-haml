require_relative '../../html_to_haml'

module HtmlToHaml::Html
  class AttributeConversionUseCase
    def initialize(html)
      @html = html
    end

    def convert
      haml = fix_erb_attributes(haml: @html)
      haml.gsub(/^\s*%(.*)$/) do |matched_elem|
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

    def fix_erb_attributes(haml:)
      # Erb attributes may be malformed to have their own line and a '=' in front
      # This changes them back into something that can be updated above
      haml.gsub(/^\s*%.*[a-zA-Z1-9]+?=('|")\n\s*=.*\n\s*("|')/) do |match|
        match.gsub(/\n\s*(=|'|")/, '\1')
      end
    end

    def handle_erb_attributes(attr:)
      attr.gsub(/=('|")=\s*(.*)('|")/, '=\2')
    end
  end
end