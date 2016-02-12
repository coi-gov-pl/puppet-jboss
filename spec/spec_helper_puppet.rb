$executing_puppet = true

require 'spec_helper'
module Testing
  module JBoss end
end
require 'testing/jboss/shared_examples'

module Testing
  module RspecPuppet end
end
require 'testing/rspec_puppet/package'

at_exit { RSpec::Puppet::Coverage.report! }
