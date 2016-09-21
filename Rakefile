require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

# These two gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = [
  "spec/**/*.pp",
  "pkg/**/*.pp",
  "tests/**/*.pp",
  "vendor/**/*.pp"
]
PuppetLint.configuration.fail_on_warnings = true

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

Rake::Task[:spec_standalone].clear
desc "Run spec tests on an existing fixtures directory (for Puppet code)"
RSpec::Core::RakeTask.new(:spec_puppet) do |t|
  t.rspec_opts = ['--color --order rand']
  t.pattern = 'spec/{classes,defines}/**/*_spec.rb'
end
desc "Run spec tests on an existing fixtures directory (for Ruby code)"
RSpec::Core::RakeTask.new(:spec_ruby) do |t|
  t.rspec_opts = ['--color --order rand']
  t.verbose = true
  t.pattern = 'spec/{unit,functions,hosts,integration,types}/**/*_spec.rb'
end
desc 'Run spec tests on an existing fixtures directory'
task :spec_standalone => [
  :spec_puppet,
  :spec_ruby
]

task :spec_puppet_prepared => [
  :spec_prep,
  :spec_puppet
]

begin
  require 'beaker'
  desc "Run acceptance tests"
  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.pattern = 'spec/acceptance'
  end
rescue LoadError
  task :acceptance do
    $stderr.puts 'Beaker is not avialable, skipping acceptance tests'
  end
end

desc "Clean fixtures"
task :clean_fixtures do
  FileUtils.rmtree 'spec/fixtures/modules'
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :metadata_lint,
  :lint,
  :validate,
  :clean_fixtures,
  :spec,
]
