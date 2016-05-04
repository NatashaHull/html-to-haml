module HtmlToHaml
  module Erb
    class IndentationTracker
      attr_accessor :indentation_level
      attr_reader :indentation_amount
      def initialize(indentation_level:, indentation_amount:)
        @indentation_level = indentation_level
        @indentation_amount = indentation_amount
        @case_statement_level = []
      end

      def begin_case_statement
        self.indentation_level += indentation_amount * 2
        @case_statement_level << indentation_level
      end

      def add_indentation
        self.indentation_level += indentation_amount
      end

      def end_block
        if indentation_level == @case_statement_level.last
          @case_statement_level.pop
          self.indentation_level -= indentation_amount * 2
        else
          self.indentation_level -= indentation_amount
        end
      end
    end
  end
end