require_relative '../../html_to_haml'
require_relative './attribute_conversion_use_case'
require_relative './indentation_conversion_use_case'

module HtmlToHaml::Html
  class ConversionUseCase
    def initialize(html, remove_whitespace: true)
      @html = html
      @remove_whitespace = remove_whitespace
    end

    def convert
      haml = IndentationConversionUseCase.new(@html, remove_whitespace: @remove_whitespace).convert
      AttributeConversionUseCase.new(haml).convert
    end
  end
end
