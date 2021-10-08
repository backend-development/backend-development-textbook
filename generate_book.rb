pwd = __dir__
# $LOAD_PATH.unshift pwd
# $LOAD_PATH.unshift "#{pwd}/vendor/bundle"
# $LOAD_PATH.unshift "/home/runner/work/backend-development-textbook/backend-development-textbook/vendor/bundle"


# gems = Dir.glob('/home/runner/work/backend-development-textbook/backend-development-textbook/vendor/bundle/*')
# puts "the gems are:"
# gems.each {|g| puts g }

# puts "/gems"

# This is a predicate useful for the doc:guides task of applications.
def bundler?
  # Note that rake sets the cwd to the one that contains the Rakefile
  # being executed.
  File.exist?('Gemfile')
end

puts "I will require stuff from the LOAD PATH #{$LOAD_PATH}"

require 'rails_guides/markdown'
require 'rails_guides/generator'
RailsGuides::Generator.new.generate
