require_relative '../../html_to_haml'
require_relative '../../helpers/haml_whitespace_cleaner'
require_relative '../../tools/non_html_selector_blocks/indentation_tracker'

module HtmlToHaml
  module NonHtmlSelectorBlocks
    class BasicConversionUseCase
      include HtmlToHaml::HamlWhitespaceCleaner

      TAG_TYPE_REGEX = "type=('|\")(.*?)('|\")"
      TAG_TYPE_FROM_REGEX = '\2'

      def initialize(js_html)
        @js_html = js_html
      end

      def convert
        indentation_tracker = IndentationTracker.new(indented: false, adjust_whitespace: false)
        haml = @js_html.gsub(/<#{self.class::HTML_TAG_NAME}.*?>|<\/#{self.class::HTML_TAG_NAME}>|(\n\s*)/) do |tag|
          replace_tag_value(tag: tag, indentation_tracker: indentation_tracker)
        end
        remove_haml_whitespace(haml: haml)
      end

      private

      def replace_tag_value(tag:, indentation_tracker:)
        if opening_tag?(tag: tag, indented: indentation_tracker.indented)
          open_tag(tag: tag, indentation_tracker: indentation_tracker)
        elsif closing_tag?(tag: tag, indented: indentation_tracker.indented)
          close_tag(indentation_tracker: indentation_tracker)
        elsif adjust_whitespace?(tag: tag, indentation_tracker: indentation_tracker)
          "#{tag}#{indentation}"
        else
          tag
        end
      end

      def opening_tag?(tag:, indented:)
        !indented && tag =~ /<#{self.class::HTML_TAG_NAME}.*?>/
      end

      def open_tag(tag:, indentation_tracker:)
        indentation_tracker.indent
        opening_tag(tag: tag)
      end

      def opening_tag(tag:)
        ":#{tag_type(tag: tag)}\n#{indentation}"
      end

      def closing_tag?(tag:, indented:)
        indented && tag =~ /<\/#{self.class::HTML_TAG_NAME}>/
      end

      def close_tag(indentation_tracker:)
        indentation_tracker.outdent
        "\n"
      end

      def adjust_whitespace?(indentation_tracker:, tag:)
        tag_indented = tag.include?(indentation)
        tag =~ /\n/ && indentation_tracker.adjust_whitespace?(reset_value: !tag_indented)
      end

      def tag_type(tag:)
        specified_tag_type(tag: tag) || self.class::DEFAULT_TAG_TYPE
      end

      def specified_tag_type(tag:)
        type_match = tag.match(/#{self.class::TAG_TYPE_REGEX}/)
        type_match && type_match.to_s.gsub(/#{self.class::TAG_TYPE_REGEX}/, self.class::TAG_TYPE_FROM_REGEX).split('/').last
      end

      def indentation
        " " * HtmlToHaml::INDENTATION_AMOUNT
      end
    end
  end
end