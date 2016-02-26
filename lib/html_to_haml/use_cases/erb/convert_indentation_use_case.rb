require 'singleton'
require_relative '../conversion_use_case'

module HtmlToHaml::Erb
  class IndentationConverter
    attr_accessor :indentation_level, :case_statement_level, :indentation_amount
    def initialize(indentation_level:, case_statement_level:, indentation_amount:)
      @indentation_level = indentation_level
      @case_statement_level = case_statement_level
      @indentation_amount = indentation_amount
    end

    def begin_case_statement
      self.indentation_level += indentation_amount * 2
      self.case_statement_level = indentation_level
    end

    def add_indentation
      self.indentation_level += indentation_amount
    end

    def end_block
      if indentation_level == case_statement_level
        self.case_statement_level = -1
        self.indentation_level -= indentation_amount * 2
      else
        self.indentation_level -= indentation_amount
      end
    end
  end

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
      matches_keywords?(erb: erb, keywords: CONTROL_FLOW_CONTINUE_KEYWORDS)
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

    def end_of_block?(erb:)
      erb =~ /\s*-\send/
    end
  end

  class ConvertIndentationUseCase
    include Singleton
    extend Forwardable

    def convert_indentation(erb:)
      indentation_converter = new_indentation_converter
      erb.split("\n").map do |erb_line|
        indentation = " " * adjusted_indentation_level_for_line(erb: erb_line, indentation_level: indentation_converter.indentation_level)
        adjust_indentation_level(erb: erb_line, indentation_converter: indentation_converter)
        "#{indentation}#{erb_line}\n" unless end_of_block?(erb: erb_line)
      end.join
    end

    private

    def_delegators :control_flow_matcher, :begin_case_statement?,
                   :begin_indented_control_flow?, :end_of_block?,
                   :continue_indented_control_flow?

    def adjust_indentation_level(erb:, indentation_converter:)
      if begin_case_statement?(erb: erb)
        indentation_converter.begin_case_statement
      elsif begin_indented_control_flow?(erb: erb)
        indentation_converter.add_indentation
      elsif end_of_block?(erb: erb)
        indentation_converter.end_block
      end
    end

    def adjusted_indentation_level_for_line(erb:, indentation_level:)
      if continue_indented_control_flow?(erb: erb)
        indentation_level - HtmlToHaml::INDENTATION_AMOUNT
      else
        indentation_level
      end
    end

    def new_indentation_converter
      IndentationConverter.new(indentation_level: 0, case_statement_level: -1, indentation_amount: HtmlToHaml::INDENTATION_AMOUNT)
    end

    def control_flow_matcher
      ControlFlowMatcher.instance
    end
  end
end