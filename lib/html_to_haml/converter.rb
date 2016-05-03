require_relative './use_cases/html/conversion_use_case'
require_relative './use_cases/erb/basic_conversion_use_case'
require_relative './use_cases/non_html_selector_blocks/style_conversion_use_case'
require_relative './use_cases/non_html_selector_blocks/script_conversion_use_case'

module HtmlToHaml
  class Converter
    def initialize(html)
      @html = html
    end

    def convert
      whitespace_free_html = remove_html_whitespace(html: @html)
      erb_converted_haml = Erb::BasicConversionUseCase.new(whitespace_free_html).convert
      haml = NonHtmlSelectorBlocks::StyleConversionUseCase.new(erb_converted_haml).convert
      haml = NonHtmlSelectorBlocks::ScriptConversionUseCase.new(haml).convert
      Html::ConversionUseCase.new(haml, remove_whitespace: false).convert
    end

    private

    def remove_html_whitespace(html:)
      html.gsub(/#{html_with_important_whitespace}|^\s*|\n/) do |matching_html|
        case matching_html
          when /#{html_with_important_whitespace}/
            initial_indentation = matching_html.gsub("\n", '').match(/^\s*/).to_s
            matching_html.gsub(/^#{initial_indentation}/, "\n")
          else
            ""
        end
      end
    end

    def html_with_important_whitespace
      important_whitespace_classes.map do |klass|
        "^\\s*<#{klass::HTML_TAG_NAME}.*?>(.|\n)*?<\/#{klass::HTML_TAG_NAME}>"
      end.join("|")
    end

    def important_whitespace_classes
      [NonHtmlSelectorBlocks::ScriptConversionUseCase,
      NonHtmlSelectorBlocks::StyleConversionUseCase]
    end
  end
end