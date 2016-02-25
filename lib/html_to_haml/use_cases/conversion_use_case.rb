module HtmlToHaml
  INDENTATION_AMOUNT = 2

  class ConversionUseCase
    def initialize(html)
      @html = html
    end

    def convert
      Raise "implement me"
    end

    private

    def remove_haml_whitespace(haml:)
      haml.lstrip.gsub(/\n\s*\n/, "\n")
    end
  end
end