# frozen_string_literal: true

namespace :guides do
  desc 'Generate guides (for authors), use ONLY=foo to process just "foo.md"'
  task generate: "generate:html"

  namespace :generate do
    desc "Generate HTML guides"
    task :html do
      ruby "-Eutf-8:utf-8", "rails_guides.rb"
    end
  end

  desc "Lint guides, using `mdl` and check for broken links"
  task lint: ["lint:check_links", "lint:mdl"]

  namespace :lint do
    desc "Check links in generated HTML guides"
    task :check_links do
      ENV["GUIDES_LINT"] = "1"
      ruby "-Eutf-8:utf-8", "rails_guides.rb"
    end

    desc "Run mdl to check Markdown files for style guide violations and lint errors"
    task :mdl do
      require "mdl"
      all = Dir.glob("#{__dir__}/source/*.md")
      files = all - Dir.glob("#{__dir__}/**/*_release_notes.md") # Ignore release notes
      MarkdownLint.run files
    end
  end

  # Validate guides -------------------------------------------------------------------------
  desc 'Validate guides, use ONLY=foo to process just "foo.html"'
  task :validate do
    ruby "w3c_validator.rb"
  end

  task :vendor_javascript do
    require "importmap-rails"
    require "importmap/packager"

    packager = Importmap::Packager.new(vendor_path: "assets/javascripts")
    imports = packager.import("@hotwired/turbo", from: "unpkg")
    imports.each do |package, url|
      umd_url = url.gsub("esm.js", "umd.js")
      puts %(Vendoring "#{package}" to #{packager.vendor_path}/#{package}.js via download from #{umd_url})
      packager.download(package, umd_url)
    end
  end

  desc "Show help"
  task :help do
    puts <<HELP

Markdown files are taken from the source directory, and the result goes into the
output directory. Assets are stored under files, and copied to output/files as
part of the generation process.

You can generate HTML using the `guides:generate` task.

All of these processes are handled via rake tasks, here's a full list of them:

#{%x[rake -T]}
Some arguments may be passed via environment variables:

  ALL=1
    Force generation of all guides.

  ONLY=name
    Useful if you want to generate only one or a set of guides.

    Generate only association_basics.html:
      ONLY=assoc

    Separate many using commas:
      ONLY=assoc,migrations

Examples:
  $ rake guides:generate ALL=1
  $ rake guides:generate ONLY=ruby_commandline
HELP
  end
end

task :test do
  templates = Dir.glob("bug_report_templates/*.rb")
  counter = templates.count do |file|
    puts "--- Running #{file}"
    Bundler.unbundled_system(Gem.ruby, "-w", file) ||
      puts("+++ 💥 FAILED (exit #{$?.exitstatus})")
  end
  puts "+++ #{counter} / #{templates.size} templates executed successfully"
  exit 1 if counter < templates.size
end

task default: "guides:help"
