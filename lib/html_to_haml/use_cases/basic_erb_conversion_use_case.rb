require_relative 'conversion_use_case'

module HtmlToHaml
  class BasicErbConversionUseCase < ConversionUseCase
    CONTROL_FLOW_MIDDLE_OF_LINE_KEYWORDS = ["do"]
    CONTROL_FLOW_BEGINNING_OF_LINE_KEYWORDS = ["if", "case", "unless"]
    CONTROL_FLOW_CONTINUE_KEYWORDS = ["elsif", "else", "when"]

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
      indentation_level = 0
      erb.split("\n").map do |erb_line|
        indentation = " " * adjusted_indentation_level(erb: erb_line, indentation_level: indentation_level)
        indentation_level += indentation_adjustment(erb: erb_line)
        "#{indentation}#{erb_line}\n" unless end_of_block?(erb: erb_line)
      end.join
    end

    def adjusted_indentation_level(erb:, indentation_level:)
      if matches_keywords?(erb: erb, keywords: CONTROL_FLOW_CONTINUE_KEYWORDS)
        indentation_level - INDENTATION_AMOUNT
      else
        indentation_level
      end
    end

    def indentation_adjustment(erb:)
      if begin_indented_control_flow?(erb: erb)
        INDENTATION_AMOUNT
      elsif end_of_block?(erb: erb)
        -1 * INDENTATION_AMOUNT
      else
        0
      end
    end

    def begin_indented_control_flow?(erb:)
      matches_keywords?(erb: erb, keywords: CONTROL_FLOW_MIDDLE_OF_LINE_KEYWORDS) ||
          matches_keywords_at_beginning_of_line?(erb: erb, keywords: CONTROL_FLOW_BEGINNING_OF_LINE_KEYWORDS)
    end

    def matches_keywords_at_beginning_of_line?(erb:, keywords:)
      erb_without_strings(erb: erb) =~ /\s*(-|=)\s*(#{keywords.join("|")})(\s|$)/
    end

    def matches_keywords?(erb:, keywords:)
      erb_without_strings(erb: erb) =~ /\s*(-|=)(.*)\s+(#{keywords.join("|")})(\s|$)/
    end

    def erb_without_strings(erb:)
      erb.gsub(/".*?"/, '').gsub(/'.*?'/, '')
    end

    def end_of_block?(erb:)
      erb =~ /\s*-\send/
    end
  end
end