require_relative '../html_to_haml'

module HtmlToHaml
  class HtmlAttributeConversionUseCase
    def initialize(html)
      @html = html
    end

    def convert
      @html.gsub(/^\s*%(.*)$/) do |matched_elem|
        haml_with_replaced_attributes(haml: matched_elem)
      end
    end

    def haml_with_replaced_attributes(haml:)
      attributes_hash = []
      haml_without_attributes = haml.gsub(/\s+([a-zA-Z1-9]+?)=('|").*?('|")/) do |matched_elem|
        attributes_hash << matched_elem.strip.gsub(/=/, ': ')
        ''
      end
      attributes_hash.empty? ? haml_without_attributes : "#{haml_without_attributes}{ #{attributes_hash.join(', ')} }"
    end
  end
end