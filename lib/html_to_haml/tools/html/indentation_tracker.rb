require_relative '../../html_to_haml'

module HtmlToHaml::Html
  class IndentationTracker
    def initialize(indentation_amount:)
      @indentation_level = 0
      @inside_self_closing_tag = false
      @indentation_amount = indentation_amount
    end

    def start_html_tag
      @indentation_level += @indentation_amount unless @inside_self_closing_tag
      @inside_self_closing_tag = false
    end

    def start_self_closing_tag
      @inside_self_closing_tag = true
    end

    def close_html_tag
      @indentation_level -= @indentation_amount
      if @indentation_level < 0
        raise ParseError, 'The html is malformed and is attempting to close an html tag that was never started'
      end
    end

    def indentation
      " " * @indentation_level
    end
  end
end
