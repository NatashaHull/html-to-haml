module HtmlToHaml
  INDENTATION_AMOUNT = 2

  class BasicHtmlConversionUseCase
    def initialize(html)
      @html = html
    end

    def convert
      # Since Haml uses whitespace in a way html doesn't, this starts by stripping
      # whitespace to start the next gsub with a clean slate.
      stripped_html = remove_html_whitespace(html: @html)
      indentation_level = 0
      haml = stripped_html.gsub(/(<\/.*?>)|<|>/) do |matched_elem|
        case matched_elem
          when /<\/.*?>/
            indentation_level -= 2
            indentation = " " * indentation_level
            "\n#{indentation}"
          when "<"
            indentation = " " * indentation_level
            "\n#{indentation}%"
          when ">"
            indentation_level += 2
            indentation = " " * indentation_level
            "\n#{indentation}"
        end
      end
      remove_haml_whitespace(haml: haml)
    end

    private

    def remove_html_whitespace(html:)
      html.gsub(/^\s*/, "").delete("\n")
    end

    def remove_haml_whitespace(haml:)
      haml.sub("\n", "").gsub(/\n\s*\n/, "\n")
    end
  end
end