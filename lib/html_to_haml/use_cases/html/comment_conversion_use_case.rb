require_relative '../../html_to_haml'

module HtmlToHaml::Html
  class CommentConversionUseCase
    HTML_COMMENT_REGEX = "<!--(.|\n)*?-->"
    HTML_USING_HAML_COMMENT_SYNTAX = "^\s*\/"

    def initialize(html)
      @html = html
    end

    def convert
      haml = @html.gsub(/#{HTML_COMMENT_REGEX}|#{HTML_USING_HAML_COMMENT_SYNTAX}/) do |comment|
        case comment
          when /#{HTML_COMMENT_REGEX}/
            "\n/ #{format_html_comment_for_haml(comment: comment)}\n"
          when /#{HTML_USING_HAML_COMMENT_SYNTAX}/
            escape_misleading_forward_slash(comment: comment)
        end
      end
      haml.gsub(/\n\s*\n/, "\n")
    end

    private

    def format_html_comment_for_haml(comment:)
      comment.gsub(/\n\s*/, "\n/ ")[4..-4].strip
    end

    def escape_misleading_forward_slash(comment:)
      comment.gsub(/^(\s*)\//, '\1\/')
    end
  end
end
