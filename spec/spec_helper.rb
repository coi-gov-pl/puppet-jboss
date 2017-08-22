def gem_present(name)
  !Bundler.rubygems.find_name(name).empty?
end

if gem_present 'simplecov'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/.vendor/'
    add_filter '/vendor/'
    add_filter '/gems/'
  end
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec/its'
require 'pry' if gem_present 'pry'

RSpec.configure do |c|
  c.mock_with :rspec do |mock|
    mock.syntax = %i[expect should]
  end
  c.include PuppetlabsSpec::Files

  # Readable test descriptions
  c.formatter = :documentation
  c.order     = :random

  c.before :each do
    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables] = true
    end
  end

  c.after :each do
    PuppetlabsSpec::Files.cleanup
  end

  c.hiera_config = File.expand_path(File.join(__FILE__, '../hiera/hiera.yaml'))
end

# Convenience helper for returning parameters for a type from the
# catalogue.
def param(type, title, param)
  param_value(catalogue, type, title, param)
end
