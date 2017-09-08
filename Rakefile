require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'metadata-json-lint/rake_task'
require 'rake_performance'

if RUBY_VERSION >= '2.1'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.relative = true
PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'pkg/**/*.pp', 'vendor/**/*.pp']

test_tasks = %i[rubocop metadata_lint lint syntax spec]
if Gem::Requirement.new('~> 3').satisfied_by? Gem::Version.new(Puppet.version)
  test_tasks.delete(:rubocop)
end

desc 'Run rubocop, metadata_lint, lint, validate, and spec tests.'
task test: test_tasks
