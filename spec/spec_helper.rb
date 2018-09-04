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
  formatters = [SimpleCov::Formatter::HTMLFormatter]
  unless ENV['TRAVIS'].nil?
    if gem_present 'codecov'
      require 'codecov'
      formatters.push SimpleCov::Formatter::Codecov
    end
    if gem_present 'coveralls'
      require 'coveralls'
      formatters.push Coveralls::SimpleCov::Formatter
    end
  end
  SimpleCov.formatters = formatters
end

require 'pry' if gem_present 'pry'
require 'rspec/its'
require 'puppet'
require 'puppet_x/coi/jboss'
require 'testing'

RSpec.configure do |c|
  c.mock_with :rspec do |mock|
    mock.syntax = [:expect]
  end
  # Readable test descriptions
  c.formatter = :documentation
  c.order     = :rand
end
