namespace :guides do

  desc 'Generate guides (for authors), use ONLY=foo to process just "foo.md"'
  task :generate => 'generate:html'

  desc 'Delete html files'
  task :clean do
    sh 'rm -f output/*.html'
    sh 'rm -f slides/*.html'
  end

  namespace :generate do

    desc "Generate HTML guides"
    task :html do
      ENV["WARN_BROKEN_LINKS"] = "1" # authors can't disable this
      ruby "generate_book.rb"
      FileList['source/*.html'].each do |source_file|
        cp source_file, 'output/', :verbose => true
      end
      cp 'README.md', 'output/', :verbose => true
      sh './deploy.sh'
    end

    desc "Generate .mobi file. The kindlegen executable must be in your PATH. You can get it for free from http://www.amazon.com/kindlepublishing"
    task :kindle do
      unless `kindlerb -v 2> /dev/null` =~ /kindlerb 0.1.1/  
        abort "Please `gem install kindlerb`"
      end
      unless `convert` =~ /convert/  
        abort "Please install ImageMagick`"
      end
      ENV['KINDLE'] = '1'
      Rake::Task['guides:generate:html'].invoke
    end
  end

  # Validate guides -------------------------------------------------------------------------
  desc 'Validate guides, use ONLY=foo to process just "foo.html"'
  task :validate do
    ruby "w3c_validator.rb"
  end

  desc "Show help"
  task :help do
    puts <<-help

Guides are taken from the source directory, and the resulting HTML goes into the
output directory. Assets are stored under files, and copied to output/files as
part of the generation process.

All this process is handled via rake tasks, here's a full list of them:

#{%x[rake -T]}
Some arguments may be passed via environment variables:

  WARNINGS=1
    Internal links (anchors) are checked, also detects duplicated IDs.

  ALL=1
    Force generation of all guides.

  ONLY=name
    Useful if you want to generate only one or a set of guides.

    Generate only association_basics.html:
      ONLY=assoc

    Separate many using commas:
      ONLY=assoc,migrations

  GUIDES_LANGUAGE
    Use it when you want to generate translated guides in
    source/<GUIDES_LANGUAGE> folder (such as source/es)

Examples:
  $ rake guides:generate ALL=1
  $ rake guides:generate:kindle
  $ rake guides:generate GUIDES_LANGUAGE=de
    help
  end
end

task :default => 'guides:generate'
