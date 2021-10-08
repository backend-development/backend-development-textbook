pwd = File.dirname(__FILE__)
$LOAD_PATH.unshift pwd

# This is a predicate useful for the doc:guides task of applications.
def bundler?
  # Note that rake sets the cwd to the one that contains the Rakefile
  # being executed.
  File.exist?('Gemfile')
end


require 'rails_guides/markdown'
require 'rails_guides/generator'
RailsGuides::Generator.new.generate
