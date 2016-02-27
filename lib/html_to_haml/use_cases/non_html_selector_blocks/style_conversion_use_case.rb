require_relative 'basic_conversion_use_case'

module HtmlToHaml
  module NonHtmlSelectorBlocks
    class StyleConversionUseCase < BasicConversionUseCase
      HTML_TAG_NAME = "style"
      DEFAULT_TAG_TYPE = "css"
    end
  end
end