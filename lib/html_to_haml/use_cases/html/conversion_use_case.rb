require_relative '../../html_to_haml'
require_relative './attribute_conversion_use_case'
require_relative './comment_conversion_use_case'
require_relative './default_conversion_use_case'

module HtmlToHaml::Html
  class ConversionUseCase
    def initialize(html, remove_whitespace: true)
      @html = html
      @remove_whitespace = remove_whitespace
    end

    def convert
      html_with_haml_comments = CommentConversionUseCase.new(@html).convert
      haml = DefaultConversionUseCase.new(html_with_haml_comments, remove_whitespace: @remove_whitespace).convert
      AttributeConversionUseCase.instance.convert_attributes(html: haml)
    end
  end
end
