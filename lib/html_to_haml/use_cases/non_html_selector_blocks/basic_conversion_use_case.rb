require_relative '../../html_to_haml'
require_relative '../../helpers/haml_whitespace_cleaner'
require_relative '../../tools/non_html_selector_blocks/indentation_tracker'
require_relative '../../tools/non_html_selector_blocks/tag_type_matchers'

module HtmlToHaml
  module NonHtmlSelectorBlocks
    class BasicConversionUseCase
      include HtmlToHaml::HamlWhitespaceCleaner
      include TagTypeMatchers

      RUBY_HAML_REGEX = "\n\s*=.*\n"

      def initialize(special_html)
        @special_html = special_html
      end

      def convert
        indentation_tracker = IndentationTracker.new(indented: false, adjust_whitespace: false)
        haml = @special_html.gsub(/#{opening_tag_regex}|#{closing_tag_regex}|#{RUBY_HAML_REGEX}|(\n\s*)/) do |tag|
          replace_tag_value(tag: tag, indentation_tracker: indentation_tracker)
        end
        remove_haml_whitespace(haml: haml)
      end

      private

      def replace_tag_value(tag:, indentation_tracker:)
        if opening_tag?(tag: tag, in_block: indentation_tracker.indented)
          open_tag(tag: tag, indentation_tracker: indentation_tracker)
        elsif closing_tag?(tag: tag, in_block: indentation_tracker.indented)
          close_tag(indentation_tracker: indentation_tracker)
        elsif use_string_interpolation?(tag: tag, in_block: indentation_tracker.indented)
          string_interpolated_ruby(tag: tag)
        elsif adjust_whitespace?(tag: tag, indentation_tracker: indentation_tracker)
          "#{tag}#{indentation}"
        else
          tag
        end
      end

      def open_tag(tag:, indentation_tracker:)
        indentation_tracker.indent
        opening_tag(tag: tag)
      end

      def opening_tag(tag:)
        ":#{tag_type(tag: tag)}\n#{indentation}"
      end

      def close_tag(indentation_tracker:)
        indentation_tracker.outdent
        "\n"
      end

      def use_string_interpolation?(tag:, in_block:)
        in_block && tag =~ /#{RUBY_HAML_REGEX}/
      end

      def string_interpolated_ruby(tag:)
        "\#{#{tag.strip[1..-1].strip}}"
      end

      def adjust_whitespace?(indentation_tracker:, tag:)
        tag_indented = tag.include?(indentation)
        tag =~ /\n/ && indentation_tracker.adjust_whitespace?(reset_value: !tag_indented)
      end

      def indentation
        " " * HtmlToHaml::INDENTATION_AMOUNT
      end
    end
  end
end