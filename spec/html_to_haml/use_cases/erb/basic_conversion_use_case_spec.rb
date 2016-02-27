require 'rspec'
require_relative '../../../../lib/html_to_haml/use_cases/erb/basic_conversion_use_case'

describe HtmlToHaml::Erb::BasicConversionUseCase do
  subject { described_class.new(@erb).convert }

  context 'converting erb symbols to haml' do
    it 'ignores html and plain text' do
      @erb = <<-ERB
<htmlstuff>Strings and stuff in html</htmlstuff>
      ERB

      expect(subject).to eq(@erb)
    end

    it 'turns <% into - where applicable' do
      @erb = <<-ERB
<% "Random string in ruby" %>
      ERB

      expect(subject).to eq("- \"Random string in ruby\"\n")
    end

    it 'turns <%- into - where applicable' do
      @erb = <<-ERB
<%- "Random string in ruby" -%>
      ERB

      expect(subject).to eq("- \"Random string in ruby\"\n")
    end

    it 'turns <%= into = where applicable' do
      @erb = <<-ERB
<%= "Random string in ruby" -%>
      ERB

      expect(subject).to eq("= \"Random string in ruby\"\n")
    end
  end

  context 'multi-line erb statements' do
    it 'does not change newlines or spacing when they are outside of an erb statement' do
      @erb = <<-ERB
<htmlStuff> Some text
  with random  newlines and
<%= "spacing" -%>
</htmlStuff>
      ERB

      expected_haml = <<-HAML
<htmlStuff> Some text
  with random  newlines and
= "spacing"
</htmlStuff>
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'removes newlines that interfere with creating good haml' do
      @erb = <<-ERB
<htmlStuff> Some text
with random  newlines and
<%= example_string =
"spacing" -%>
</htmlStuff>
      ERB

      expected_haml = <<-HAML
<htmlStuff> Some text
with random  newlines and
= example_string = "spacing"
</htmlStuff>
      HAML

      expect(subject).to eq(expected_haml)
    end

    it 'adds newlines when the erb needs to be moved onto its own line' do
      @erb = <<-ERB
<htmlStuff> Some text
with random  newlines and <%= "spacing" -%> and more
</htmlStuff>
      ERB

      expected_haml = <<-HAML
<htmlStuff> Some text
with random  newlines and
= "spacing"
 and more
</htmlStuff>
      HAML

      expect(subject).to eq(expected_haml)
    end
  end
end