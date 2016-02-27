module HtmlToHaml
  module HamlWhitespaceCleaner
    private

    def remove_haml_whitespace(haml:)
      haml.lstrip.gsub(/\n\s*\n/, "\n")
    end
  end
end