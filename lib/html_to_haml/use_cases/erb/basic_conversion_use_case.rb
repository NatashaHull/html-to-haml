require_relative '../../html_to_haml'
require_relative '../../helpers/haml_whitespace_cleaner'
require_relative 'convert_indentation_use_case'

module HtmlToHaml::Erb
  class BasicConversionUseCase
    include HtmlToHaml::HamlWhitespaceCleaner

    def initialize(erb)
      @erb = erb
    end

    def convert
      sanitized_erb = remove_newlines_within_erb_statements(erb: @erb)
      erb = convert_syntax(erb: sanitized_erb)
      haml = convert_indentation(erb: erb)
      remove_haml_whitespace(haml: haml)
    end

    private

    def remove_newlines_within_erb_statements(erb:)
      erb.gsub(/<%(.*?)\n(.*?)%>/) do |erb_statement|
        erb_statement.gsub("\n", " ")
      end
    end

    def convert_syntax(erb:)
      erb.gsub(/\s*?\n?(<%=|<%-|<%)\s?/) do |erb_selector|
        erb_selector_index = erb_selector =~ /-|=/
        erb_selector_index ? "\n#{erb_selector[erb_selector_index]} " : "\n- "
      end.gsub(/\s?(-%>|%>)/, "\n")
    end

    def convert_indentation(erb:)
      ConvertIndentationUseCase.instance.convert_indentation(erb: erb)
    end
  end
end