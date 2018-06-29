require 'spec_helper'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |c|
  c.include PuppetlabsSpec::Files
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
