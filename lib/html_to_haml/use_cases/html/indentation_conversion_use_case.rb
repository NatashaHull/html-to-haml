require_relative '../../html_to_haml'
require_relative '../../helpers/haml_whitespace_cleaner'
require_relative '../../tools/html/indentation_tracker'

module HtmlToHaml::Html
  class IndentationConversionUseCase
    include HtmlToHaml::HamlWhitespaceCleaner

    ERB_LINE_REGEX = "\n\s*(-|=).*$"
    CLOSING_HTML_REGEX = "<\/.*?>"
    # For self-closing html tags that aren't self-closing by default
    SELF_CLOSING_HTML_REGEX = "\/>"
    SELF_CLOSING_TAGS = %w(area base br col command embed hr img input keygen link meta param source track wbr)

    def initialize(html, remove_whitespace: true)
      # Since Haml uses whitespace in a way html doesn't, this starts by stripping
      # whitespace to start the next gsub with a clean slate. Unless the caller opts
      # out.
      @html = if remove_whitespace
                remove_html_whitespace(html: html)
              else
                html
              end
    end

    def convert
      indentation_tracker = IndentationTracker.new(indentation_amount: HtmlToHaml::INDENTATION_AMOUNT)
      haml = @html.gsub(/#{ERB_LINE_REGEX}|#{CLOSING_HTML_REGEX}|#{SELF_CLOSING_HTML_REGEX}|#{self_closing_tag_regex}|<|>|\n/) do |matched_elem|
        adjust_indentation_level(html: matched_elem, indentation_tracker: indentation_tracker)
        start_of_line = "\n#{indentation_tracker.indentation}"
        case matched_elem
          when /#{ERB_LINE_REGEX}/
            "#{start_of_line}#{matched_elem[1..-1]}"
          when /#{self_closing_tag_regex}/
            "#{start_of_line}%#{matched_elem[1..-1]}"
          when "<"
            "#{start_of_line}%"
          else
            start_of_line
        end
      end
      remove_haml_whitespace(haml: haml)
    end

    def self_closing_tag_regex
      "<#{SELF_CLOSING_TAGS.join('|<')}\\s"
    end

    private

    def adjust_indentation_level(html:, indentation_tracker:)
      case html
        when /#{CLOSING_HTML_REGEX}/
          indentation_tracker.close_html_tag
        when /#{self_closing_tag_regex}/
          indentation_tracker.start_self_closing_tag
        when ">"
          indentation_tracker.start_html_tag
      end
    end

    def remove_html_whitespace(html:)
      html.gsub(/^\s*/, "").delete("\n")
    end

    def remove_haml_whitespace(haml:)
      haml.sub("\n", "").gsub(/(\n\s*)\n\s*%/, '\1%').gsub(/\n\s*\n/, "\n")
    end
  end
end