module HtmlToHaml
  module Html
    class AttributeHandler
      def initialize
        @ids = []
        @classes = []
        @plain_attributes = []
      end

      def add_attribute(attr:)
        if use_id_syntax?(attr: attr)
          @ids << extract_attribute_value(attr: attr)
        elsif use_class_syntax?(attr: attr)
          @classes << extract_attribute_value(attr: attr)
        else
          @plain_attributes << attr.strip.gsub(/=/, ': ')
        end
      end

      def attributes_string
        "#{format_ids}#{format_classes}#{format_attributes}"
      end

      private

      def use_id_syntax?(attr:)
        attr =~ /id="[^#\{]*"/
      end

      def use_class_syntax?(attr:)
        attr =~ /class="[^#\{]*"/
      end

      def extract_attribute_value(attr:)
        attr.gsub(/.*="(.*)"/, '\1').strip
      end

      def format_attributes
       @plain_attributes.empty? ? '' : "{ #{@plain_attributes.join(', ')} }"
      end

      def format_ids
        @ids.empty? ? '' : "##{@ids.join('#')}"
      end

      def format_classes
        @classes.empty? ? '' : ".#{@classes.join('.')}"
      end
    end
  end
end