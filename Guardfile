# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
directories %w(assets source) \
  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard 'rake', :task => 'guides:generate' do
  watch(%r{^source/*.md})
  watch(%r{^source/*.html})
  watch(%r{^source/documents.yaml})
  watch(%r{^assets/images/*.png})
  watch(%r{^assets/images/*.jpg})
  watch(%r{^assets/images/*.svg})
end
