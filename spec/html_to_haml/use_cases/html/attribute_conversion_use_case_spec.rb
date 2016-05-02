require 'rspec'
require_relative '../../../../lib/html_to_haml/use_cases/html/attribute_conversion_use_case'

describe HtmlToHaml::Html::AttributeConversionUseCase do
  describe '#convert_attributes' do
    subject { described_class.instance.convert_attributes(html: @html) }

    it 'does nothing to haml without attributes' do
      @html = (<<-HTML).strip
%html
  Html content
      HTML

      expected_haml = (<<-HAML).strip
%html
  Html content
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'turns html attributes leftover in converted haml into an attributes hash' do
      @html = <<-HTML
%html attr1="attribute 1" attr2="attribute 2"
  Html content
      HTML

      expected_haml = <<-HAML
%html{ attr1: "attribute 1", attr2: "attribute 2" }
  Html content
      HAML

      expect(subject).to eq(expected_haml)
      end

    it 'handles formerly erb attributes that have partially gone through the converter' do
      @html = <<-HTML
%html attr1="attribute 1" attr2="
  =attribute2
"
  Html content
      HTML

      expected_haml = <<-HAML
%html{ attr1: "attribute 1", attr2: attribute2 }
  Html content
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'handles attributes that were set with non-erb and erb values' do
      @html = <<-HTML
%html attr1="attribute 1" attr2="attribute-first-value
  =attribute2
"
  Html content
      HTML

      expected_haml = <<-HAML
%html{ attr1: "attribute 1", attr2: "attribute-first-value \#{attribute2}" }
  Html content
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'correctly handles cases with erb attributes before other attributes' do
      @html = <<-HTML
%html attr1="attribute 1" attr2="attribute-first-value
  =attribute2
attr-third-value" attr3="attribute 3"
  Html content
      HTML

      expected_haml = <<-HAML
%html{ attr1: "attribute 1", attr2: "attribute-first-value \#{attribute2} attr-third-value", attr3: "attribute 3" }
  Html content
      HAML

      expect(subject).to eq(expected_haml)
    end
  end
end
