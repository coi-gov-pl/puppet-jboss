# A puppet x module
module Puppet_X
  # A COI puppet_x module
  module Coi
    # Require relative kernel-like method
    def self.require_relative(relative_path, lvl = 0)
      stack = Kernel.caller
      file = stack[lvl].split(/:\d/,2).first
      file = './' if ['(eval)', '(pry)', ''].include?(file)
      file = File.dirname(file)
      path = File.expand_path(File.join(file, relative_path))
      Kernel.require(path)
    end

    # JBoss module
    module Jboss
      # JBoss provider module
      module Provider

      end
      # Module that contains internal classes
      module Internal

        module Executor end

        module State end

      end

    end
  end
end

# Ruby default kernel module
module Kernel
  define_method(:require_relative) { |rel| Puppet_X::Coi::require_relative(rel, lvl = 1) } unless Kernel.respond_to? :require_relative
end

require_relative 'jboss/provider/abstract_jboss_cli'
require_relative 'jboss/provider/securitydomain'
require_relative 'jboss/internal/logic_creator'
require_relative 'jboss/internal/execution_state_wrapper'
require_relative 'jboss/internal/cli_executor'
require_relative 'jboss/internal/securitydomain_auditor'
require_relative 'jboss/internal/command_compilator'
require_relative 'jboss/internal/state/execution_state'
require_relative 'jboss/internal/state/securitydomain_state'
require_relative 'jboss/internal/executor/shell_executor'

require_relative 'jboss/constants'
require_relative 'jboss/buildins_utils'
require_relative 'jboss/configuration'
require_relative 'jboss/facts'
require_relative 'jboss/factsrefresher'

require_relative 'jboss/functions/jboss_basename'
require_relative 'jboss/functions/jboss_dirname'
require_relative 'jboss/functions/jboss_short_version'
require_relative 'jboss/functions/jboss_to_bool'
require_relative 'jboss/functions/jboss_to_i'
require_relative 'jboss/functions/jboss_to_s'
require_relative 'jboss/functions/jboss_type_version'

require_relative 'jboss/provider/datasource'
require_relative 'jboss/provider/datasource/post_wildfly_provider'
require_relative 'jboss/provider/datasource/pre_wildfly_provider'
require_relative 'jboss/provider/datasource/static'
require_relative 'jboss/provider/confignode'
require_relative 'jboss/provider/deploy'

require_relative 'jboss/provider/securitydomain/abstract_provider'
require_relative 'jboss/provider/securitydomain/post_wildfly_provider'
require_relative 'jboss/provider/securitydomain/pre_wildfly_provider'
require_relative 'jboss/provider/jmsqueue'
require_relative 'jboss/provider/jdbcdriver'
