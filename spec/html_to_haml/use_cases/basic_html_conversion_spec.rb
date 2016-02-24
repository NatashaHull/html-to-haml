require 'rspec'
require_relative '../../../lib/html_to_haml/use_cases/basic_html_conversion'

describe HtmlToHaml::BasicHtmlConversionUseCase do
  describe '#convert' do
    subject { described_class.new(@html).convert }

    context 'Plain text is just rendered' do
      before do
        @html = 'Plain text html with rand\nom ne\nwlines'
      end

      it { should eq(@html) }
    end

    context 'There is only one tag' do
      it 'returns the tag with just the tag name when there is no content' do
        @html = (<<-HTML).strip
        <html></html>
        HTML
        expect(subject).to eq("%html\n")
      end

      it 'returns the tag with a newline separating the content if there is content' do
        @html = (<<-HTML).strip
        <html>Html content</html>
        HTML

        expected_haml = <<-HAML
%html
  Html content
        HAML

        expect(subject).to eq(expected_haml)
      end
    end

    context 'There are multiple html tags' do
      it 'returns both tags with a newline if there is no content' do
        @html = (<<-HTML).strip
        <htmlTag1></htmlTag1>
        <htmlTag2></htmlTag2>
        HTML

        expect(subject).to eq("%htmlTag1\n%htmlTag2\n")
      end

      it 'returns both tags and their content separated with newlines' do
        @html = (<<-HTML).strip
        <htmlTag1>Some content here</htmlTag1>
        <htmlTag2>Some content there</htmlTag2>
        HTML
        expected_haml = <<-HAML
%htmlTag1
  Some content here
%htmlTag2
  Some content there
        HAML

        expect(subject).to eq(expected_haml)
      end

      context 'Nested html tags' do
        it 'returns haml for nested html with the correct indentation levels' do
          @html = (<<-HTML).strip
        <htmlTag1>
          Some content here
          <nestedHtmlTag>
            Some nested content there
          </nestedHtmlTag>
        </htmlTag1>
        <htmlTag2>Some non-nested content there</htmlTag2>
          HTML
          expected_haml = <<-HAML
%htmlTag1
  Some content here
  %nestedHtmlTag
    Some nested content there
%htmlTag2
  Some non-nested content there
          HAML

          expect(subject).to eq(expected_haml)
        end
      end
    end
  end
end