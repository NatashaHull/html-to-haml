require_relative 'basic_conversion_use_case'

module HtmlToHaml
  module NonHtmlSelectorBlocks
    class ScriptConversionUseCase < BasicConversionUseCase
      HTML_TAG_NAME = "script"
      DEFAULT_TAG_TYPE = "javascript"
    end
  end
end