require 'spec_helper'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

at_exit { RSpec::Puppet::Coverage.report! }

shared_context :unsupported do
  if gem_present 'rspec-puppet-facts-unsupported'
    require 'rspec-puppet-facts-unsupported'

    include RspecPuppetFactsUnsupported
    on_unsupported_os.each do |os, facts|
      context "on unsupported OS '#{os}'" do
        let(:facts) { facts }
        it { is_expected.to compile.and_raise_error(/Unsupported operating system/) }
      end
    end
  end
end

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
