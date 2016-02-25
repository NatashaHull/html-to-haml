require_relative '../../lib/html_to_haml/converter'

describe HtmlToHaml::Converter do
  describe '#convert' do
    subject { described_class.new(html).convert }
    let(:html) { File.read(File.expand_path('../../fixtures/example.html.erb', __FILE__)) }
    let(:expected_haml) { File.read(File.expand_path('../../fixtures/example.haml', __FILE__)) }

    it { should eq(expected_haml) }
  end
end