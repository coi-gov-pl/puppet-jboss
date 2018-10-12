# A puppetx module
module PuppetX
  # A COI PuppetX module
  module Coi
    # Require relative kernel-like method
    def self.require_relative(relative_path, lvl = 0)
      stack = Kernel.caller
      files = stack.reject { |line| /`require_relative'/.match(line) }
      files = files.map { |line| /(.+):\d+(?:\:in `[^']*')?/.match(line)[1] }
      files = files.uniq
      file = files[lvl]
      file = './' if ['(eval)', '(pry)', ''].include?(file)
      file = File.dirname(file)
      path = File.expand_path(File.join(file, relative_path) + '.rb')
      path = Pathname.new(path).realpath.to_s
      Kernel.require(path)
    end

    # JBoss module
    module Jboss
      # JBoss type module
      module Type
      end
      # JBoss provider module
      module Provider
      end
      # Value object module
      module Value
      end
      # Module that contains internal classes
      module Internal
        # Executor module
        module Executor end
        # Module that contains states
        module State end
      end
    end
  end
end
# Ruby default kernel module
module Kernel
  define_method(:require_relative) { |rel| PuppetX::Coi.require_relative(rel) } unless Kernel.respond_to? :require_relative
end

require_relative 'jboss/hash'
require_relative 'jboss/tail'
require_relative 'jboss/checks'
require_relative 'jboss/constants'
require_relative 'jboss/buildins_utils'
require_relative 'jboss/configuration'
require_relative 'jboss/facts'
require_relative 'jboss/factsrefresher'

require_relative 'jboss/value/try'
require_relative 'jboss/value/command'

require_relative 'jboss/internal/execute_logic'
require_relative 'jboss/internal/executor/shell_executor'
require_relative 'jboss/provider/abstract_jboss_cli'
require_relative 'jboss/internal/sanitizer'
require_relative 'jboss/provider/securitydomain'
require_relative 'jboss/internal/logic_creator'
require_relative 'jboss/internal/execution_state_wrapper'
require_relative 'jboss/internal/cli_executor'
require_relative 'jboss/internal/securitydomain_auditor'
require_relative 'jboss/internal/command_compilator'
require_relative 'jboss/internal/state/execution_state'
require_relative 'jboss/internal/state/securitydomain_state'
require_relative 'jboss/internal/securitydomain_destroyer'

require_relative 'jboss/functions/version_parse'
require_relative 'jboss/functions/validate_method_parameters'
require_relative 'jboss/functions/hash_setvalue'
require_relative 'jboss/functions/member'
require_relative 'jboss/functions/required_java'
require_relative 'jboss/functions/basename'
require_relative 'jboss/functions/dirname'
require_relative 'jboss/functions/short_version'
require_relative 'jboss/functions/to_bool'
require_relative 'jboss/functions/to_i'
require_relative 'jboss/functions/to_s'
require_relative 'jboss/functions/inspect'
require_relative 'jboss/functions/type_version'

require_relative 'jboss/type/meta'
require_relative 'jboss/type/confignode'
require_relative 'jboss/type/datasource'
require_relative 'jboss/type/deploy'
require_relative 'jboss/type/jdbcdriver'
require_relative 'jboss/type/jmsqueue'
require_relative 'jboss/type/resourceadapter'
require_relative 'jboss/type/securitydomain'

require_relative 'jboss/provider/datasource'
require_relative 'jboss/provider/datasource/post_wildfly_provider'
require_relative 'jboss/provider/datasource/pre_wildfly_provider'
require_relative 'jboss/provider/datasource/static'
require_relative 'jboss/provider/confignode'
require_relative 'jboss/provider/resourceadapter'
require_relative 'jboss/provider/deploy'

require_relative 'jboss/provider/securitydomain/abstract_provider'
require_relative 'jboss/provider/securitydomain/post_wildfly_provider'
require_relative 'jboss/provider/securitydomain/pre_wildfly_provider'
require_relative 'jboss/provider/jmsqueue'
require_relative 'jboss/provider/jdbcdriver'
