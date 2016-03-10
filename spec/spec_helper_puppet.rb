$executing_puppet = true

require 'spec_helper'
module Testing
  module RspecPuppet end
end
require 'testing/rspec_puppet/shared_facts'
require 'testing/rspec_puppet/shared_examples'

at_exit { RSpec::Puppet::Coverage.report! }
