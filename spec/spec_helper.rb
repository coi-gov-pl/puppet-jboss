require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec/its'

begin
  gem 'simplecov'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/.vendor/"
    add_filter "/vendor/"
    add_filter "/gems/"
  end
rescue Gem::LoadError
  # do nothing
end

begin
  gem 'coveralls'
  require 'coveralls'  
  if ENV['TRAVIS']
    Coveralls.wear!
  end
rescue Gem::LoadError
  # do nothing
end

begin
  gem 'pry'
  require 'pry'
rescue Gem::LoadError
  # do nothing
end

require 'rspec-puppet'

RSpec.configure do |c|
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

# Convenience helper for returning parameters for a type from the
# catalogue.
def param(type, title, param)
  param_value(catalogue, type, title, param)
end