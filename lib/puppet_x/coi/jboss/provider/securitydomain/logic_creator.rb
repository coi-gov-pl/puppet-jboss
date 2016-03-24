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
    authentication = command_list[2]
    result_list = []
    if @state['result']['authentication'] == nil
      # there is no authentication so we need to create one
      commands = [command_list[0], command_list[1], command_list[2]]
      authentication = '/'.join(commnad_list[0], )
      result.push(command_list[0])
    end
  end

end
