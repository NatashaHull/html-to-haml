require 'rspec'
require_relative '../../../../lib/html_to_haml/use_cases/html/comment_conversion_use_case'

describe HtmlToHaml::Html::CommentConversionUseCase do
  describe '#convert' do
    subject { described_class.new(@html).convert }
    it 'converts html comments into haml comments' do
      @html = <<-HTML
<!--Html comment-->
      HTML

      expected_haml = "\n/ Html comment\n"
      expect(subject).to eq(expected_haml)
    end

    it 'moves mutliple lines within a single comment to a multi-line haml comment' do
      @html = <<-HTML
<!--Multi-
    Line
    Html comment-->
      HTML

      expected_haml = <<-HAML

/ Multi-
/ Line
/ Html comment
      HAML
      expect(subject).to eq(expected_haml)
    end

    it 'ignores --> when it is not attached to an html comment' do
      @html = <<-HTML
<!--Multi-
    Line comment -->
    Extra text-->
      HTML

      expected_haml = <<-HAML

/ Multi-
/ Line comment
    Extra text-->
      HAML
      expect(subject).to eq(expected_haml)
    end

    it 'escapes any non-html comments using haml comment syntax' do
      @html = <<-HTML
      / html using haml comment syntax<!--Real comment-->
      / Still not a comment
      HTML

      expected_haml = <<-HAML
      \\/ html using haml comment syntax
/ Real comment
      \\/ Still not a comment
      HAML

      expect(subject).to eq(expected_haml)
    end
  end
end