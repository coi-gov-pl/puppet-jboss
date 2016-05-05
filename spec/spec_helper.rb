require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec/its'

unless $executing_puppet
  begin
  gem 'simplecov'
    require 'simplecov'
    formatters = []
    formatters << SimpleCov::Formatter::HTMLFormatter

    begin
      gem 'coveralls'
      require 'coveralls'
      formatters << Coveralls::SimpleCov::Formatter if ENV['TRAVIS']
    rescue Gem::LoadError
      # do nothing
    end

    begin
      gem 'codeclimate-test-reporter'
      require 'codeclimate-test-reporter'
      formatters << CodeClimate::TestReporter::Formatter if (ENV['TRAVIS'] and ENV['CODECLIMATE_REPO_TOKEN'])
    rescue Gem::LoadError
      # do nothing
    end
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
    SimpleCov.start do
      add_filter "/spec/"
      add_filter "/.vendor/"
      add_filter "/vendor/"
      add_filter "/gems/"
      minimum_coverage 76
      refuse_coverage_drop
    end
  rescue Gem::LoadError
    # do nothing
  end
end

begin
  gem 'pry'
  require 'pry'
rescue Gem::LoadError
  # do nothing
end

module Testing
  module Mock end
end

require 'puppet_x/coi/jboss'
require "testing/mock/mocked_command_executor"

require 'rspec-puppet'

RSpec.configure do |c|
  c.tty = true unless ENV['JENKINS_URL'].nil?
  c.mock_with :rspec do |mock|
    mock.syntax = [:expect, :should]
  end
  c.include PuppetlabsSpec::Files

  c.before :each do
    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables]=true
    end
  end

  c.after :each do
    PuppetlabsSpec::Files.cleanup
  end
end
