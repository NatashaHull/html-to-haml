module HtmlToHaml
  INDENTATION_AMOUNT = 2

  module Html
    class ParseError < RuntimeError
    end
  end

  module Erb
    class ParseError < RuntimeError
    end
  end
end