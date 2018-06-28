module Testing
  module Acceptance end
  module RspecPuppet end
  module Mock end
end

require 'testing/acceptance/cleaner'
require 'testing/acceptance/javaplatform'

require 'testing/rspec_puppet/shared_facts'
require 'testing/rspec_puppet/shared_examples'

require 'testing/mock/mocked_execution_state_wrapper'
require 'testing/mock/mocked_shell_executor'
