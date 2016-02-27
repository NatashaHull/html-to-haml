require 'rspec'
require_relative '../../../lib/html_to_haml/use_cases/basic_script_conversion_use_case'

describe HtmlToHaml::BasicScriptConversionUseCase do
  subject { described_class.new(@js_html).convert }

  context 'syntax' do
    it 'turns script tags without a type into haml javascript tags' do
      @js_html = "<script></script>"

      expect(subject).to eq(":javascript\n")
    end

    it 'turns script tags with a type into haml tags with that type' do
      @js_html = '<script type="randomType"></script>'

      expect(subject).to eq(":randomType\n")
    end
  end

  context 'stuff outside the tag' do
    it 'does not change things outside of a script tag' do
      @js_html = <<-HTML
<html-stuff>Some text here</html-stuff>
<%= "erb syntax stuff" %>
- haml_erb_stuff
Random\nnew\nline Plain text
      HTML

      expect(subject).to eq(@js_html)
    end
  end

  context 'indentation' do
    it 'indents everything inside the script tag a level further' do
      @js_html = <<-HTML
<script>var someJsVar = 42;</script>
      HTML

      expected_haml = <<-HAML
:javascript
  var someJsVar = 42;
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'indents everything inside script tags across multiple lines' do
      @js_html = <<-HTML
<script>
var someJsVar = 42;
"A javascript string";
</script>
      HTML

      expected_haml = <<-HAML
:javascript
  var someJsVar = 42;
  "A javascript string";
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'indents everything by extra two spaces if it needs indenting' do
      @js_html = <<-HTML
<script>
var someJsVar = 42;
  "A javascript string";
</script>
      HTML

      expected_haml = <<-HAML
:javascript
  var someJsVar = 42;
    "A javascript string";
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'leaves the text inside script tags alone if it is already indented' do
      @js_html = <<-HTML
<script>
  var someJsVar = 42;
    "A javascript string";
</script>
      HTML

      expected_haml = <<-HAML
:javascript
  var someJsVar = 42;
    "A javascript string";
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'unindents after closing the script tag' do
      @js_html = <<-HTML
<script></script>
<html-stuff>Some text here</html-stuff>
<%= "erb syntax stuff" %>
- haml_erb_stuff
Random\nnew\nline Plain text
      HTML

      expected_haml = <<-HAML
:javascript
<html-stuff>Some text here</html-stuff>
<%= "erb syntax stuff" %>
- haml_erb_stuff
Random\nnew\nline Plain text
      HAML
      expect(subject).to eq(expected_haml)
    end

    it 'unindents things after closing the script tag for things initially on the same line' do
      @js_html = <<-HTML
<script></script><html-stuff>Some text here</html-stuff>
<%= "erb syntax stuff" %>
- haml_erb_stuff
Random\nnew\nline Plain text
      HTML

      expected_haml = <<-HAML
:javascript
<html-stuff>Some text here</html-stuff>
<%= "erb syntax stuff" %>
- haml_erb_stuff
Random\nnew\nline Plain text
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'ignores nested script tags' do
      @js_html = <<-HTML
<script>"outerScriptTag";<script> "text after ignored script tag";</script>
<script>
"Outer script tag using newlines";
<script>
"Text after ignored script tag html";
</script>
<htmlTag>
      HTML

      expected_haml = <<-HAML
:javascript
  "outerScriptTag";<script> "text after ignored script tag";
:javascript
  "Outer script tag using newlines";
  <script>
  "Text after ignored script tag html";
<htmlTag>
      HAML

      expect(subject).to eq(expected_haml)
    end
  end
end