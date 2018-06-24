require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks' if RUBY_VERSION >= '2.0'
require 'puppet-lint/tasks/puppet-lint'
require 'metadata-json-lint/rake_task'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.relative = true
PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'pkg/**/*.pp']

test_tasks = [:metadata_lint, :lint, :syntax, :spec]
if RUBY_VERSION >= '2.1'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  test_tasks.unshift(:rubocop)
end

desc 'Run rubocop, metadata_lint, lint, validate, and spec tests.'
task :test => test_tasks
