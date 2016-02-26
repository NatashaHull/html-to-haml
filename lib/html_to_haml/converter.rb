require_relative './use_cases/basic_html_conversion_use_case'
require_relative './use_cases/erb/basic_conversion_use_case'

module HtmlToHaml
  class Converter
    def initialize(html)
      @html = html
    end

    def convert
      whitespace_free_html = remove_html_whitespace(html: @html)
      haml = Erb::BasicConversionUseCase.new(whitespace_free_html).convert
      BasicHtmlConversionUseCase.new(haml, remove_whitespace: false).convert
    end

    private

    def remove_html_whitespace(html:)
      html.gsub(/^\s*/, "").delete("\n")
    end
  end
end