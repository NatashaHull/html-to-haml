require 'singleton'

module HtmlToHaml
  module Erb
    class ControlFlowMatcher
      include Singleton

      CONTROL_FLOW_MIDDLE_OF_LINE_KEYWORDS = ["do"]
      CONTROL_FLOW_BEGINNING_OF_LINE_KEYWORDS = ["if", "unless"]
      CONTROL_FLOW_CONTINUE_KEYWORDS = ["elsif", "else", "when"]

      def begin_case_statement?(erb:)
        matches_keywords_at_beginning_of_line?(erb: erb, keywords: ["case"])
      end

      def begin_indented_control_flow?(erb:)
        matches_keywords?(erb: erb, keywords: CONTROL_FLOW_MIDDLE_OF_LINE_KEYWORDS) ||
            matches_keywords_at_beginning_of_line?(erb: erb, keywords: CONTROL_FLOW_BEGINNING_OF_LINE_KEYWORDS)
      end

      def continue_indented_control_flow?(erb:)
        matches_keywords_at_beginning_of_line?(erb: erb, keywords: CONTROL_FLOW_CONTINUE_KEYWORDS)
      end

      def end_of_block?(erb:)
        erb_without_strings(erb: erb) =~ /\s*-\send/
      end

      private

      def matches_keywords_at_beginning_of_line?(erb:, keywords:)
        erb_without_strings(erb: erb) =~ /\s*(-|=)\s*(#{keywords.join("|")})(\s|$)/
      end

      def matches_keywords?(erb:, keywords:)
        erb_without_strings(erb: erb) =~ /\s*(-|=)(.*)\s+(#{keywords.join("|")})(\s|$)/
      end

      def erb_without_strings(erb:)
        erb.gsub(/".*?"/, '').gsub(/'.*?'/, '')
      end
    end
  end
end

