require './gemfiles/quirks/file'
require 'puppetlabs_spec_helper/rake_tasks'

tasks = [:spec]

if RUBY_VERSION >= '2.1'
  require 'puppet_blacksmith/rake_tasks'
  require 'puppet-lint/tasks/puppet-lint'
  require 'metadata-json-lint/rake_task'
  require 'rubocop/rake_task'

  PuppetLint.configuration.send('disable_80chars')
  PuppetLint.configuration.relative = true
  PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'pkg/**/*.pp']
  RuboCop::RakeTask.new

  tasks.unshift(:syntax)
  tasks.unshift(:lint)
  tasks.unshift(:metadata_lint)
  tasks.unshift(:rubocop)
end

desc 'Run rubocop, metadata_lint, lint, validate, and spec tests.'
task :test => tasks
