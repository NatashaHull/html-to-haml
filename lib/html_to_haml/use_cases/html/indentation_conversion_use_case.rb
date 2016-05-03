require_relative '../../html_to_haml'
require_relative '../../helpers/haml_whitespace_cleaner'

module HtmlToHaml::Html
  class IndentationConversionUseCase
    include HtmlToHaml::HamlWhitespaceCleaner

    ERB_LINE_REGEX = "\n\s*(-|=).*$"
    CLOSING_HTML_REGEX = "<\/.*?>"
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
      indentation_level = 0
      self_closing_tag = false
      haml = @html.gsub(/#{ERB_LINE_REGEX}|#{CLOSING_HTML_REGEX}|#{SELF_CLOSING_HTML_REGEX}|#{self_closing_tag_regex}|<|>|\n/) do |matched_elem|
        indentation_level = adjusted_indentation_level(html: matched_elem, indentation_level: indentation_level, self_closing_tag: self_closing_tag)
        indentation = " " * indentation_level
        case matched_elem
          when /#{ERB_LINE_REGEX}/
            "\n#{indentation}#{matched_elem[1..-1]}"
          when /#{self_closing_tag_regex}/
            self_closing_tag = true
            "\n#{indentation}%#{matched_elem[1..-1]}"
          when "<"
            "\n#{indentation}%"
          when ">"
            self_closing_tag = false
            "\n#{indentation}"
          else
            "\n#{indentation}"
        end
      end
      remove_haml_whitespace(haml: haml)
    end

    def self_closing_tag_regex
      "<#{SELF_CLOSING_TAGS.join('|<')}\\s"
    end

    private

    def adjusted_indentation_level(html:, indentation_level:, self_closing_tag: false)
      case html
        when /#{CLOSING_HTML_REGEX}/
          indentation_level - HtmlToHaml::INDENTATION_AMOUNT
        when ">"
          return indentation_level + HtmlToHaml::INDENTATION_AMOUNT unless self_closing_tag
          indentation_level
        else
          indentation_level
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