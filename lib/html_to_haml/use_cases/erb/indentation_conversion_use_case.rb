require 'singleton'
require 'forwardable'
require_relative '../../html_to_haml'
require_relative '../../tools/erb/indentation_tracker'
require_relative '../../tools/erb/control_flow_matcher'

module HtmlToHaml::Erb
  class IndentationConversionUseCase
    include Singleton
    extend ::Forwardable

    SNARKY_COMMENT_FOR_HAVING_NESTED_CASE_STATEMENTS = <<-HAML
/ It looks like this is the start of a nested case statement
/ Are you REALLY sure you want or need one? Really?
/ This converter will convert it for you below, but you should
/ seriously rethink your code right now.
    HAML

    def convert_indentation(erb:)
      indentation_converter = new_indentation_converter
      erb.split("\n").map do |erb_line|
        indentation = indentation_for_line_or_error(erb: erb_line, indentation_level: indentation_converter.indentation_level)
        adjust_indentation_level(erb: erb_line, indentation_converter: indentation_converter)
        construct_haml_line(erb: erb_line, indentation: indentation, indentation_converter: indentation_converter)
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

    def indentation_for_line_or_error(erb:, indentation_level:)
      adjusted_indentation_level = adjusted_indentation_level_for_line(erb: erb, indentation_level: indentation_level)
      if adjusted_indentation_level < 0
        raise ParseError, 'The erb is malformed. Please make sure you have the correct number of "end" statements'
      else
        " " * adjusted_indentation_level
      end
    end

    def adjusted_indentation_level_for_line(erb:, indentation_level:)
      if continue_indented_control_flow?(erb: erb)
        indentation_level - HtmlToHaml::INDENTATION_AMOUNT
      else
        indentation_level
      end
    end

    def construct_haml_line(erb:, indentation:, indentation_converter:)
      indentation_adjusted_haml_line = "#{indentation}"
      if begin_nested_case_statement?(erb: erb, indentation_converter: indentation_converter)
        indentation_adjusted_haml_line << nested_case_statement_commentary(indentation: indentation)
      end
      indentation_adjusted_haml_line << "#{erb}\n" unless end_of_block?(erb: erb)
    end

    def begin_nested_case_statement?(erb:, indentation_converter:)
      begin_case_statement?(erb: erb) && indentation_converter.nested_case_statement?
    end

    def nested_case_statement_commentary(indentation:)
      SNARKY_COMMENT_FOR_HAVING_NESTED_CASE_STATEMENTS.gsub("\n", "\n#{indentation}")
    end

    def new_indentation_converter
      IndentationTracker.new(indentation_level: 0, indentation_amount: HtmlToHaml::INDENTATION_AMOUNT)
    end

    def control_flow_matcher
      ControlFlowMatcher.instance
    end
  end
end