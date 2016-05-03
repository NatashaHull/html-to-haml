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
      attributes_arr = []
      ids = []
      classes = []
      haml_without_attributes = haml.gsub(/\s*([a-zA-Z1-9]+?)=('|").*?('|")/) do |matched_elem|
        attr = escape_erb_attributes(attr: matched_elem)
        if use_id_syntax?(attr: attr)
          ids << extract_attribute_value(attr: attr)
        elsif use_class_syntax?(attr: attr)
          classes << extract_attribute_value(attr: attr)
        else
          attributes_arr << attr.strip.gsub(/=/, ': ')
        end
        ''
      end
      "#{haml_without_attributes}#{format_ids(ids: ids)}#{format_classes(classes: classes)}#{format_attributes(attributes_arr: attributes_arr)}"
    end

    def format_classes(classes:)
      classes.empty? ? '' : ".#{classes.join('.')}"
    end

    def use_class_syntax?(attr: attr)
      attr =~ /class="[^#\{]*"/
    end

    def format_attributes(attributes_arr:)
      attributes_arr.empty? ? '' : "{ #{attributes_arr.join(', ')} }"
    end

    def format_ids(ids:)
      ids.empty? ? '' : "##{ids.join('#')}"
    end

    def extract_attribute_value(attr:)
      attr.gsub(/.*="(.*)"/, '\1').strip
    end

    def use_id_syntax?(attr:)
      attr =~ /id="[^#\{]*"/
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