module HtmlToHaml
  INDENTATION_AMOUNT = 2

  class BasicErbConversionUseCase
    CONTROL_FLOW_START_KEYWORDS = ["do", "if", "case"]
    CONTROL_FLOW_CONTINUE_KEYWORDS = ["elsif", "else", "when"]

    def initialize(erb)
      @erb = erb
    end

    def convert
      sanitized_erb = remove_newlines_within_erb_statements(erb: @erb)
      erb = convert_syntax(erb: sanitized_erb)
      haml = convert_indentation(erb: erb)
      remove_starting_whitespace(haml: haml)
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
      end.gsub(/\s?(-%>|%>)/, "")
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
      if matches_kewyords?(erb: erb, keywords: CONTROL_FLOW_CONTINUE_KEYWORDS)
        indentation_level - 2
      else
        indentation_level
      end
    end

    def indentation_adjustment(erb:)
      if matches_kewyords?(erb: erb, keywords: CONTROL_FLOW_START_KEYWORDS)
        INDENTATION_AMOUNT
      elsif end_of_block?(erb: erb)
        -1 * INDENTATION_AMOUNT
      else
        0
      end
    end

    def matches_kewyords?(erb:, keywords:)
      erb_without_strings(erb: erb) =~ /\s*(-|=)(.*)\s+(#{keywords.join("|")})(\s|$)/
    end

    def erb_without_strings(erb:)
      erb.gsub(/".*?"/, '').gsub(/'.*?'/, '')
    end

    def end_of_block?(erb:)
      erb =~ /\s*-\send/
    end

    def remove_starting_whitespace(haml:)
      haml.lstrip
    end
  end
end