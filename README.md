# HTML-to-HAML ![Travis CI](https://travis-ci.org/NatashaHull/html-to-haml.svg?branch=master)
Conversion tool for turning html and html.erb files into haml

##Usage
Add the following line to your gemfile.
```ruby
gem 'html-to-haml'
```
Once you have run `bundle install`, you will need to `require 'html_to_haml/converter.rb'` wherever you intend to use the converter.

Call `HtmlToHaml::Converter.new(File.read('path/to/file.html.erb').convert` and get the text for a converted haml file.

##Examples
This gem is currently being used as part of this [html to haml web converter](http://html-to-haml.cfapps.io/).
You can see the code for the web interface [here](https://github.com/NatashaHull/html-to-haml-web)

###Travis CI
https://travis-ci.org/NatashaHull/html-to-haml

###License
--------------------------
This repository uses the Unlicense.
For more information, please refer to <http://unlicense.org>