require 'spec_helper'
require 'rspec-puppet-facts'
require 'rspec-puppet-facts-unsupported'

include RspecPuppetFacts
include RspecPuppetFactsUnsupported

$executing_puppet = true

module Testing
  module RspecPuppet end
end

require 'testing/rspec_puppet/shared_facts'
require 'testing/rspec_puppet/shared_examples'

at_exit { RSpec::Puppet::Coverage.report! }

shared_context :unsupported do
  on_unsupported_os.each do |os, facts|
    context "on unsupported OS '#{os}'" do
      let(:facts) { facts }
      it { is_expected.to compile.and_raise_error(/Unsupported operating system/) }
    end
  end
end

RSpec.configure do |c|
  c.hiera_config = File.expand_path(File.join(__FILE__, '../hiera/hiera.yaml'))
end
