require 'rspec'
require_relative '../../../../lib/html_to_haml/tools/html/attribute_handler'

describe HtmlToHaml::Html::AttributeHandler do
  subject { described_class.new }

  context 'empty attributes' do
    it 'generates an empty string' do
      expect(subject.attributes_string).to eq('')
    end
  end

  context 'regular attributes' do
    it 'generates a string that puts regular attributes into a hash string' do
      subject.add_attribute(attr: 'attr1="attribute1"')
      expect(subject.attributes_string).to eq('{ attr1: "attribute1" }')
    end
  end

  context 'ids' do
    it 'generates a string using the # syntax for simple ids' do
      subject.add_attribute(attr: 'id="simple-id"')
      expect(subject.attributes_string).to eq('#simple-id')
    end

    it 'generates a regular attributes string for the id if it is not in quotes' do
      subject.add_attribute(attr: 'id=erb-id')
      expect(subject.attributes_string).to eq('{ id: erb-id }')
    end

    it 'generates a regular attributes string for the id if it has string interpolation in it' do
      subject.add_attribute(attr: 'id="simple-id #{erb-id}"')
      expect(subject.attributes_string).to eq('{ id: "simple-id #{erb-id}" }')
    end
  end

  context 'classes' do
    it 'generates a string using the . syntax for simple classes' do
      subject.add_attribute(attr: 'class="simple-class"')
      expect(subject.attributes_string).to eq('.simple-class')
    end

    it 'generates a regular attributes string for the class if it is not in quotes' do
      subject.add_attribute(attr: 'class=erb-class')
      expect(subject.attributes_string).to eq('{ class: erb-class }')
    end

    it 'generates a regular attributes string for the class if it has string interpolation in it' do
      subject.add_attribute(attr: 'class="simple-class #{erb-class}"')
      expect(subject.attributes_string).to eq('{ class: "simple-class #{erb-class}" }')
    end
  end

  context 'ids, classes and regular attributes' do
    it 'combines the ids, classes and regular attributes in that order' do
      subject.add_attribute(attr: 'id="simple-id"')
      subject.add_attribute(attr: 'class="simple-class"')
      subject.add_attribute(attr: 'attr1="attribute1"')
      expect(subject.attributes_string).to eq('#simple-id.simple-class{ attr1: "attribute1" }')
    end
  end
end