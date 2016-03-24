class Puppet_X::Coi::Jboss::Provider::SecurityDomain::LogicCreator

  def initialize(state)
    @state = state
  end

  # This the method that will decide which commands should be run in order to setup working security domain
  #
  # @param command_list list of templates for command to be executed
  # @param state hash with informations about current resources in jboss security subsystem
  # @return [String] list of commands that has to be executed
  def prepare_commands_for_ensure(command_list)
  end

end
