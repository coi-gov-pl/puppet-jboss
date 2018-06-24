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

require 'pry' if gem_present 'pry'
require 'rspec/its'
require 'puppet'
require 'puppet_x/coi/jboss'

RSpec.configure do |c|
  c.mock_with :rspec do |mock|
    mock.syntax = [:expect]
  end
  # Readable test descriptions
  c.formatter = :documentation
end
