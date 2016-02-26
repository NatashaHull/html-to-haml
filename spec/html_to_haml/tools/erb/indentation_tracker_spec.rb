require 'rspec'
require_relative '../../../../lib/html_to_haml/tools/erb/indentation_tracker'

describe HtmlToHaml::Erb::IndentationTracker do
  let(:tracker) { described_class.new(indentation_level:0, case_statement_level:-1, indentation_amount:5) }

  describe '#begin_case_statement' do
    subject { tracker.begin_case_statement }

    it { change{ tracker.indentation_level }.by(10) }
    it { change{ tracker.case_statement_level }.to(tracker.indentation_level) }
  end

  describe '#add_indentation' do
    subject { tracker.begin_case_statement }

    it { change { tracker.indentation_level }.by(5) }
    it { change { tracker.case_statement_level }.by(0) }
  end

  describe '#end_block' do
    context 'not ending a case block' do
      it 'changes the indentation_level by the indentation_amount' do
        expect {
          tracker.end_block
        }.to change { tracker.indentation_level }.by(-1 * tracker.indentation_amount) &&
             change { tracker.case_statement_level }.by(0)
      end
    end

    context 'ending a case block' do
      let(:tracker) { described_class.new(indentation_level:10, case_statement_level:10, indentation_amount:5) }

      it 'changes the indentation_level by 2 indentation_amounts and resets the case_statement_level' do
        expect {
          tracker.end_block
        }.to change { tracker.indentation_level }.by(-2 * tracker.indentation_amount) &&
                 change { tracker.case_statement_level }.to(-1)
      end
    end
  end
end
