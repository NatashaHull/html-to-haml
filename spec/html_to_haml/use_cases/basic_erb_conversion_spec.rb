require 'rspec'
require_relative '../../../lib/html_to_haml/use_cases/basic_erb_conversion'

describe HtmlToHaml::BasicErbConversionUseCase do
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
    it 'does not change newlines when they are outside of an erb statement' do
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
with random  newlines and <%= "spacing" -%>
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
  end

  context 'control flow' do
    context 'keywords being used as keywords' do
      it 'uses the correct haml indentation for dealing with blocks' do
        @erb = <<-ERB
<% sample_array.each do |arr_elem| %>
<%= arr_elem -%>
<% end %>
        ERB

        expected_haml = <<-HAML
- sample_array.each do |arr_elem|
  = arr_elem
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'uses the correct haml indentation for dealing with if/elsif/else statements' do
        @erb = <<-ERB
<% if statement1_is_truthy %>
<%= "some string" -%>
<% elsif statement2_is_truthy %>
<%= "a different string" -%>
<% else %>
<%= "catpicks are cool" -%>
<% end %>
        ERB

        expected_haml = <<-HAML
- if statement1_is_truthy
  = "some string"
- elsif statement2_is_truthy
  = "a different string"
- else
  = "catpicks are cool"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'uses the correct haml indentation for dealing with case statements' do
        @erb = <<-ERB
<% case true %>
<% when statement1_is_truthy %>
<%= "some string" -%>
<% when statement2_is_truthy %>
<%= "a different string" -%>
<% else %>
<%= "catpicks are cool" -%>
<% end %>
        ERB

        expected_haml = <<-HAML
- case true
- when statement1_is_truthy
  = "some string"
- when statement2_is_truthy
  = "a different string"
- else
  = "catpicks are cool"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'unindents when dealing with end statements' do
        @erb = <<-ERB
<% sample_array.each do |arr_elem| %>
<%= arr_elem -%>
<% end %>
<% randomly_delared_var = "dogs are awesome" %>
Random HTML string
        ERB

        expected_haml = <<-HAML
- sample_array.each do |arr_elem|
  = arr_elem
- randomly_delared_var = "dogs are awesome"
Random HTML string
        HAML

        expect(subject).to eq(expected_haml)
      end

      # TODO: implement the code for this. (It's not technically part of what I'm working on, but seems important.)
      xit 'raises a specific error if the erb tries to unindent beyond into negative numbers' do
        @erb = <<-ERB
<% when statement1_is_truthy %>
<%= "some string" -%>
<% when statement2_is_truthy %>
<%= "a different string" -%>
<% else %>
<%= "catpicks are cool" -%>
<% end %>
        ERB

        expect(subject).to raise_error(HtmlToHaml::ErbParseError)
      end
    end

    context 'control flow keywords outside erb' do
      it 'does not change indentation if it sees a control flow start keywords' do
        @erb = <<-ERB
Random HTML with the words if and do
<% "Some erb" %>
        ERB

        expected_haml = <<-HAML
Random HTML with the words if and do
- "Some erb"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'does not change indentation if it sees a control flow continuation keywords' do
        @erb = <<-ERB
<% if some_condition %>
Random HTML with the words elsif and else
<% elsif some_other_condition %>
        ERB

        expected_haml = <<-HAML
- if some_condition
  Random HTML with the words elsif and else
- elsif some_other_condition
        HAML

        expect(subject).to eq(expected_haml)
      end
    end

    context 'control flow keywords in erb strings' do
      it 'does not change indentation if it sees a control flow start keywords' do
        @erb = <<-ERB
<% "Random string with the words if and do in erb" %>
<% "Some erb" %>
        ERB

        expected_haml = <<-HAML
- "Random string with the words if and do in erb"
- "Some erb"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'does not change indentation if it sees a control flow continuation keywords' do
        @erb = <<-ERB
<% if some_condition %>
<% "Random string with the words elsif and else in erb" %>
<% elsif some_other_condition %>
        ERB

        expected_haml = <<-HAML
- if some_condition
  - "Random string with the words elsif and else in erb"
- elsif some_other_condition
        HAML

        expect(subject).to eq(expected_haml)
      end
    end
  end
end