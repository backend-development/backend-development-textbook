pwd = __dir__
$LOAD_PATH.unshift pwd
# $LOAD_PATH.unshift "#{pwd}/vendor/bundle"
# $LOAD_PATH.unshift "/home/runner/work/backend-development-textbook/backend-development-textbook/vendor/bundle"

puts "I will require stuff from the LOAD PATH #{$LOAD_PATH}"

require 'rails_guides/markdown'
require 'rails_guides/generator'
RailsGuides::Generator.new.generate
