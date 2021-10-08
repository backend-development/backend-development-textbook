pwd = File.dirname(__FILE__)
$:.unshift pwd

# This is a predicate useful for the doc:guides task of applications.
def bundler?
  # Note that rake sets the cwd to the one that contains the Rakefile
  # being executed.
  File.exists?('Gemfile')
end

begin
  # Guides generation in the Rails repo.
  as_lib = File.join(pwd, "../activesupport/lib")
  ap_lib = File.join(pwd, "../actionpack/lib")

  $:.unshift as_lib if File.directory?(as_lib)
  $:.unshift ap_lib if File.directory?(ap_lib)
rescue LoadError
  # Guides generation from gems.
  gem "actionpack", '>= 3.0'
end
require 'redcarpet'
require 'rails_guides/markdown'
require "rails_guides/generator"
RailsGuides::Generator.new.generate
