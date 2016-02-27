require_relative './use_cases/basic_html_conversion_use_case'
require_relative './use_cases/erb/basic_conversion_use_case'
require_relative './use_cases/script/basic_conversion_use_case'

module HtmlToHaml
  class Converter
    def initialize(html)
      @html = html
    end

    def convert
      whitespace_free_html = remove_html_whitespace(html: @html)
      erb_converted_haml = Erb::BasicConversionUseCase.new(whitespace_free_html).convert
      haml = Script::BasicConversionUseCase.new(erb_converted_haml).convert
      BasicHtmlConversionUseCase.new(haml, remove_whitespace: false).convert
    end

    private

    def remove_html_whitespace(html:)
      html.gsub(/^\s*#{html_with_important_whitespace}|^\s*|\n/) do |matching_html|
        case matching_html
          when /#{html_with_important_whitespace}/
            initial_indentation = matching_html.match(/^\s*/).to_s
            matching_html.gsub(/#{initial_indentation}/, "\n")
          else
            ""
        end
      end
    end

    def html_with_important_whitespace
      "<#{Script::BasicConversionUseCase::HTML_TAG_NAME}.*?>(.|\n)*?<\/#{Script::BasicConversionUseCase::HTML_TAG_NAME}>"
    end
  end
end