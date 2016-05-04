require 'rspec'
require_relative '../../../../lib/html_to_haml/tools/html/indentation_tracker'

describe HtmlToHaml::Html::IndentationTracker do
  let(:tracker) { described_class.new(indentation_amount:5) }

  describe '#start_html_tag' do
    subject { tracker.start_html_tag }

    context 'when not inside a self-closing tag' do
      it 'updates changes the indentation by the indentation amount' do
        expect{ subject }.to change{ tracker.indentation }.from("").to("     ")
      end
    end

    context 'when inside a self-closing tag' do
      before do
        tracker.start_self_closing_tag
      end

      it 'does not change the indentation level' do
        expect{ subject }.to change { tracker.indentation.length }.by(0)
      end

      it 'changes the indentation when run more than once' do
        tracker.start_html_tag

        expect {
          tracker.start_html_tag
        }.to change { tracker.indentation.length }.by(5)
      end
    end
  end

  describe '#start_self_closing_tag' do
    subject { tracker.start_self_closing_tag }

    it 'does not affect the indentation level' do
      expect{ subject }.to change { tracker.indentation.length }.by(0)
    end
  end

  describe '#close_html_tag' do
    subject { tracker.close_html_tag }

    it 'removes a level of indentation' do
      tracker.start_html_tag
      tracker.start_html_tag
      expect{ subject }.to change { tracker.indentation.length }.from(10).to(5)
    end
  end
end
