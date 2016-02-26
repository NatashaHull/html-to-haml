require 'rspec'
require_relative '../../../../lib/html_to_haml/tools/erb/control_flow_matcher'

describe HtmlToHaml::Erb::ControlFlowMatcher do
  describe '#begin_case_statement?' do
    subject { described_class.instance.begin_case_statement?(erb: @erb) }

    it 'returns true if it looks like an erb case statement declaration' do
      @erb = '- case string'
      expect(subject).to be_truthy
    end

    it 'returns false if it does not look like an erb case statement declaration' do
      @erb = 'case string'
      expect(subject).to be_falsey
    end

    it 'returns false if there the word case is used inside of quotes' do
      @erb = '- "case" in quotes string'
      expect(subject).to be_falsey
    end

    it 'returns false if there the word case is not at the start of the string' do
      @erb = '- Some string with the word case in it'
      expect(subject).to be_falsey
    end

    it 'returns false if the word case is not used' do
      @erb = '- Some string'
      expect(subject).to be_falsey
    end
  end

  describe '#begin_indented_control_flow?' do
    subject { described_class.instance.begin_indented_control_flow?(erb: @erb) }

    it 'returns true for a do statement in the middle of erb' do
      @erb = '- some_var do |something|'
      expect(subject).to be_truthy
    end

    it 'returns true for an if statement at the start of an erb line' do
      @erb = '- if random_var'
      expect(subject).to be_truthy
    end

    it 'returns false for an if statement in the middle of erb line' do
      @erb = '- some_var if true_var'
      expect(subject).to be_falsey
    end

    it 'returns false for non-erb text' do
      @erb = 'some_var do |something|'
      expect(subject).to be_falsey
    end
  end

  describe '#continue_indented_control_flow?' do
    subject { described_class.instance.continue_indented_control_flow?(erb: @erb) }

    it 'returns true for an else clause at the beginning of an erb line' do
      @erb = '- else'
      expect(subject).to be_truthy
    end

    it 'returns false for an else statement in the middle of erb line' do
      @erb = '- some_var else'
      expect(subject).to be_falsey
    end

    it 'returns false for non-erb text' do
      @erb = 'else non-erb text'
      expect(subject).to be_falsey
    end
  end

  describe '#end_of_block?' do
    subject { described_class.instance.end_of_block?(erb: @erb) }

    it 'returns true for an erb end statement' do
      @erb = '- end'
      expect(subject).to be_truthy
    end

    it 'returns false for strings with the word end in them' do
      @erb = 'string with end in it'
      expect(subject).to be_falsey
    end

    it 'returns false for erb statements with end in quotes' do
      @erb = '- "end"'
      expect(subject).to be_falsey
    end

    it 'returns false if end is not part of the statement' do
      @erb = 'random erb'
      expect(subject).to be_falsey
    end
  end
end