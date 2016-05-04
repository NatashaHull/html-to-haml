require 'rspec'
require_relative '../../../../lib/html_to_haml/use_cases/html/indentation_conversion_use_case'

describe HtmlToHaml::Html::IndentationConversionUseCase do
  describe '#convert' do
    subject { described_class.new(@html).convert }

    context 'plain text' do
      it 'does not change plain text' do
        @html = 'Plain text html with rand\nom ne\nwlines'
        expect(subject).to eq(@html)
      end

      it 'corrects the indentation of plain text nested under html' do
        @html = <<-HTML
<html-stuff>
Plainy plain text
</html-stuff>
        HTML

        expected_haml = <<-HAML
%html-stuff
  Plainy plain text
        HAML

        expect(subject).to eq(expected_haml)
      end
    end

    context 'the html string has haml converted erb in it' do
      it 'does not change haml strings' do
        @html = '- "Haml string here"'
        expect(subject).to eq(@html)
      end

      it 'corrects the indentation of haml strings nested under html' do
        @html = <<-HTML
<html-stuff>
- "Some haml code"
</html-stuff>
        HTML

        expected_haml = <<-HAML
%html-stuff
  - "Some haml code"
        HAML

        expect(subject).to eq(expected_haml)
      end
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

    context 'self-closing html tags' do
      it 'does not change the indentation for pre-defined self-closing html tags' do
        @html = (<<-HTML).strip
<img src="example source" alt="sample alt">
Some random text that shouldn't be indented
        HTML

        expected_haml = (<<-HAML).strip
%img src=\"example source\" alt=\"sample alt\"
Some random text that shouldn't be indented
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'does not change the indentation for html tags that are self closing using the /> syntax' do
        @html = <<-HTML
<html-stuff/>
Plainy plain text
        HTML

        expected_haml = (<<-HAML).strip
%html-stuff
Plainy plain text
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'works for html tags that are self-closing by default and that have the /> syntax' do
        @html = (<<-HTML).strip
<img src="example source" alt="sample alt"/>
Some random text that shouldn't be indented
        HTML

        expected_haml = (<<-HAML).strip
%img src=\"example source\" alt=\"sample alt\"
Some random text that shouldn't be indented
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

        it 'returns the haml for one-line nested html with the correct indentation levels' do
          @html = "<htmlTag1>Some content here<nestedHtmlTag>Some nested content there</nestedHtmlTag></htmlTag1>"

          expected_haml = <<-HAML
%htmlTag1
  Some content here
  %nestedHtmlTag
    Some nested content there
          HAML

          expect(subject).to eq(expected_haml)
        end

        it 'raises a specific error if the html tries to unindent into negative spaces' do
          @html = (<<-HTML).strip
<htmlTag1>
  Some content here
  <nestedHtmlTag>
    Some nested content there
  </nestedHtmlTag>
</htmlTag1>
</htmlTagClosingWithoutOpening>
          HTML

          expect{ subject }.to raise_error(HtmlToHaml::Html::ParseError)
        end
      end
    end
  end
end