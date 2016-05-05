module HtmlToHaml
  module NonHtmlSelectorBlocks
    module TagTypeMatchers
      TAG_TYPE_REGEX = "type=('|\")(.*?)('|\")"
      TAG_TYPE_FROM_REGEX = '\2'

      private

      def opening_tag?(tag:, in_block:)
        !in_block && tag =~ /#{opening_tag_regex}/
      end

      def opening_tag_regex
        "<#{self.class::HTML_TAG_NAME}.*?>"
      end

      def closing_tag?(tag:, in_block:)
        in_block && tag =~ /#{closing_tag_regex}/
      end

      def closing_tag_regex
        "<\/#{self.class::HTML_TAG_NAME}>"
      end

      def tag_type(tag:)
        specified_tag_type(tag: tag) || self.class::DEFAULT_TAG_TYPE
      end

      def specified_tag_type(tag:)
        type_match = tag.match(/#{self.class::TAG_TYPE_REGEX}/)
        type_match && type_match.to_s.gsub(/#{self.class::TAG_TYPE_REGEX}/, self.class::TAG_TYPE_FROM_REGEX).split('/').last
      end
    end
  end
end
