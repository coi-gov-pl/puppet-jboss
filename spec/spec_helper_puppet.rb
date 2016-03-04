$executing_puppet = true

require 'spec_helper'
module Testing
  module JBoss end
end
require 'testing/jboss/shared_facts'
require 'testing/jboss/shared_examples'

at_exit { RSpec::Puppet::Coverage.report! }
