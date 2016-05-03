require 'rspec'
require_relative '../../../../lib/html_to_haml/use_cases/non_html_selector_blocks/script_conversion_use_case'

describe HtmlToHaml::NonHtmlSelectorBlocks::ScriptConversionUseCase do
  subject { described_class.new(@js_html).convert }

  context 'syntax' do
    it 'turns script tags without a src attribute into haml javascript tags' do
      @js_html = "<script></script>"

      expect(subject).to eq(":javascript\n")
    end

    it 'does not change with a src attribute' do
      @js_html = "<script src='js-source.example.com'></script>"

      expect(subject).to eq(@js_html)
    end
  end
end