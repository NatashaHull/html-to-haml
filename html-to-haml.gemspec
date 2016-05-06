Gem::Specification.new do |s|
  s.name        = 'html-to-haml'
  s.version     = '0.0.1'
  s.date        = '2016-05-06'
  s.summary     = 'A program that turns html.erb code into haml code.'
  s.description = 'This app takes in html and erb code and turns it into haml. It supports script and style tags
                   and html comments as well.'
  s.required_ruby_version = '>= 2.0'
  s.authors     = ['Natasha Hull-Richter']
  s.email       = 'nhull-richter@pivotal.io'
  s.files       = Dir.glob('lib/**/**')
  s.homepage    =
      'https://github.com/NatashaHull/html-to-haml.git'
  s.license       = 'Unlicense'
end