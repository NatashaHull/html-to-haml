module HtmlToHaml
  module NonHtmlSelectorBlocks
    class IndentationTracker
      attr_reader :indented, :adjust_whitespace

      def initialize(indented:, adjust_whitespace:)
        @indented = indented
        @reset_adjust_whitespace = false
        @adjust_whitespace = adjust_whitespace
      end

      def indent
        return if indented
        @indented = true
        @reset_adjust_whitespace = true
      end

      def outdent
        return unless indented
        @indented = false
        @adjust_whitespace = false
        @reset_adjust_whitespace = false
      end

      def adjust_whitespace?(reset_value: adjust_whitespace)
        if @reset_adjust_whitespace
          @reset_adjust_whitespace = false
          @adjust_whitespace = reset_value
        else
          @adjust_whitespace
        end
      end
    end
  end
end