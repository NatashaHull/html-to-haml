# HTML-to-HAML ![Travis CI](https://travis-ci.org/NatashaHull/html-to-haml.svg?branch=master)
Conversion tool for turning html and html.erb files into haml

##Usage
Add the following line to your gemfile.
```ruby
gem 'html-to-haml'
```
Once you have run `bundle install`, you can simply call the converter directly.

Call `HtmlToHaml::Converter.new(File.read('path/to/file.html.erb').convert` and get the text for a converted haml file.

###Travis CI
https://travis-ci.org/NatashaHull/html-to-haml

###License
--------------------------
This repository uses the Unlicense.
For more information, please refer to <http://unlicense.org>