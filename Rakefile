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
    end
  end

  # Validate guides -------------------------------------------------------------------------
  desc 'Validate guides, use ONLY=foo to process just "foo.html"'
  task :validate do
    ruby "w3c_validator.rb"
  end

end

task :default => 'guides:generate'
