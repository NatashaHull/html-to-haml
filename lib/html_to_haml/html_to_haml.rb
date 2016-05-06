module HtmlToHaml
  INDENTATION_AMOUNT = 2

  class ParseError < RuntimeError
  end

  module Html
    class ParseError < HtmlToHaml::ParseError
    end
  end

  module Erb
    class ParseError < HtmlToHaml::ParseError
    end
  end
end