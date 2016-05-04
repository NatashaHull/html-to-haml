require 'rspec'
require_relative '../../../../lib/html_to_haml/use_cases/erb/indentation_conversion_use_case'

describe HtmlToHaml::Erb::IndentationConversionUseCase do
  subject { described_class.instance.convert_indentation(erb: @erb) }

  context 'control flow' do
    context 'keywords being used as keywords' do
      it 'uses the correct haml indentation for dealing with blocks' do
        @erb = <<-ERB
- sample_array.each do |arr_elem|
= arr_elem
- end
        ERB

        expected_haml = <<-HAML
- sample_array.each do |arr_elem|
  = arr_elem
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'uses the correct haml indentation for dealing with if/elsif/else statements' do
        @erb = <<-ERB
- if statement1_is_truthy
= "some string"
- elsif statement2_is_truthy
= "a different string"
- else
= "catpicks are cool"
- end
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
- case true
- when statement1_is_truthy
= "some string"
- when statement2_is_truthy
= "a different string"
- else
= "catpicks are cool"
- end
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

      it 'properly unindents haml indentation for nested control flow in case statements' do
        @erb = <<-ERB
- case true
- when statement1_is_truthy
- if statement2_is_truthy
= "some string"
- else
= "a different string"
- end
- else
= "catpicks are cool"
- end
        ERB

        expected_haml = <<-HAML
- case true
  - when statement1_is_truthy
    - if statement2_is_truthy
      = "some string"
    - else
      = "a different string"
  - else
    = "catpicks are cool"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'properly indents nested case statements (even though this is a terrible terrible thing to do)' do
        @erb = <<-ERB
- case true
- when statement1_is_truthy
- case statement2_is_truthy
- when true
= "some string"
- else
= "a different string"
- end
- else
= "catpicks are cool"
- end
Plain text
        ERB

        expected_haml = <<-HAML
- case true
  - when statement1_is_truthy
    / It looks like this is the start of a nested case statement
    / Are you REALLY sure you want or need one? Really?
    / This converter will convert it for you below, but you should
    / seriously rethink your code right now.
    - case statement2_is_truthy
      - when true
        = "some string"
      - else
        = "a different string"
  - else
    = "catpicks are cool"
Plain text
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'uses the correct haml indentation for unless statements' do
        @erb = <<-ERB
- unless statement1_is_falsy
= "some string"
- end
        ERB

        expected_haml = <<-HAML
- unless statement1_is_falsy
  = "some string"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'uses the correct indentation for single line if/unless statements' do
        @erb = <<-ERB
- do_something if condition_is_truthy
- do_something unless condition_is_falsy
- "Erb-stuff"
        ERB

        expected_haml = <<-HAML
- do_something if condition_is_truthy
- do_something unless condition_is_falsy
- "Erb-stuff"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'unindents when dealing with end statements' do
        @erb = <<-ERB
- sample_array.each do |arr_elem|
= arr_elem
- end
- randomly_delared_var = "dogs are awesome"
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

      it 'raises a specific error if the erb tries to unindent into negative spaces' do
        @erb = <<-ERB
- when statement1_is_truthy
= "some string"
- when statement2_is_truthy
= "a different string"
- else
= "catpicks are cool"
- end
        ERB

        expect{ subject }.to raise_error(HtmlToHaml::Erb::ParseError)
      end
    end

    context 'control flow keywords outside erb' do
      it 'does not change indentation if it sees a control flow start keywords' do
        @erb = <<-ERB
Random HTML with the words if and do and end
- "Some erb"
        ERB

        expected_haml = <<-HAML
Random HTML with the words if and do and end
- "Some erb"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'does not change indentation if it sees a control flow continuation keywords' do
        @erb = <<-ERB
- if some_condition
Random HTML with the words elsif and else
- elsif some_other_condition
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
- "Random string with the words if and do in erb"
- "Some erb"
        ERB

        expected_haml = <<-HAML
- "Random string with the words if and do in erb"
- "Some erb"
        HAML

        expect(subject).to eq(expected_haml)
      end

      it 'does not change indentation if it sees a control flow continuation keywords' do
        @erb = <<-ERB
- if some_condition
- "Random string with the words elsif and else in erb"
- elsif some_other_condition
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