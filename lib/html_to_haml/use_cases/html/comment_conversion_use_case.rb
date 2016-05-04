require_relative '../../html_to_haml'
require_relative '../../helpers/haml_whitespace_cleaner'

module HtmlToHaml::Html
  class CommentConversionUseCase
    include HtmlToHaml::HamlWhitespaceCleaner

    HTML_COMMENT_REGEX = "<!--(.|\n)*?-->"

    def initialize(html)
      @html = html
    end

    def convert
      haml = @html.gsub(/#{HTML_COMMENT_REGEX}|^\s*\//) do |comment|
        case comment
          when /#{HTML_COMMENT_REGEX}/
            "\n/ #{comment.gsub(/\n\s*/, "\n/ ")[4..-4].strip}\n"
          else
            comment.gsub(/^(\s*)\//, '\1\/')
        end
      end
      haml.gsub(/\n\s*\n/, "\n")
    end
  end
end


