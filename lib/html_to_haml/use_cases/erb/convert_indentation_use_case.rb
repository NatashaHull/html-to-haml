require 'singleton'
require_relative '../conversion_use_case'
require_relative '../../tools/erb/indentation_tracker'
require_relative '../../tools/erb/control_flow_matcher'

module HtmlToHaml::Erb
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
      IndentationTracker.new(indentation_level: 0, case_statement_level: -1, indentation_amount: HtmlToHaml::INDENTATION_AMOUNT)
    end

    def control_flow_matcher
      ControlFlowMatcher.instance
    end
  end
end