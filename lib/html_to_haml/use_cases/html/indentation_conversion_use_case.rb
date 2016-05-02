require_relative '../../html_to_haml'
require_relative '../../helpers/haml_whitespace_cleaner'

module HtmlToHaml::Html
  class IndentationConversionUseCase
    include HtmlToHaml::HamlWhitespaceCleaner

    ERB_LINE_REGEX = "\n\s*(-|=).*$"
    CLOSING_HTML_REGEX = "<\/.*?>"

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
      haml = @html.gsub(/#{ERB_LINE_REGEX}|#{CLOSING_HTML_REGEX}|<|>|\n/) do |matched_elem|
        indentation_level = adjusted_indentation_level(html: matched_elem, indentation_level: indentation_level)
        indentation = " " * indentation_level
        case matched_elem
          when /#{ERB_LINE_REGEX}/
            "\n#{indentation}#{matched_elem[1..-1]}"
          when "<"
            "\n#{indentation}%"
          else
            "\n#{indentation}"
        end
      end
      remove_haml_whitespace(haml: haml)
    end

    private

    def adjusted_indentation_level(html:, indentation_level:)
      case html
        when /#{CLOSING_HTML_REGEX}/
          indentation_level - HtmlToHaml::INDENTATION_AMOUNT
        when ">"
          indentation_level + HtmlToHaml::INDENTATION_AMOUNT
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