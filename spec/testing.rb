module Testing
  module Acceptance end
  module RspecPuppet end
  module Mock end
end

require_relative 'testing/acceptance/cleaner'
require_relative 'testing/acceptance/javaplatform'

require_relative 'testing/rspec_puppet/shared_facts'
require_relative 'testing/rspec_puppet/shared_examples'

require_relative 'testing/mock/mocked_execution_state_wrapper'
require_relative 'testing/mock/mocked_shell_executor'
