# A module for JBoss security domain common abstract resource
class Puppet_X::Coi::Jboss::Provider::SecurityDomain::AbstractProvider

  # Standard constructor
  # @param {Hash} resource standard Puppet resource
  # @param {Puppet_X::Coi::Jboss::Internal::CommandCompilator} compilator that is used to compile jboss command
  def initialize(resource, compilator)
    @resource = resource
    @compilator = compilator
  end
  
  COMMAND_SPLITTER = ','
  NEWLINE_REPLACEMENT = ' '

  # Creates a parametrized command to be executed by resource
  # @return {String} a complete command without profile
  def build_main_command
    res = @resource
    correct_cmd = correct_command_template_begining(res)
    options = []
    res[:moduleoptions].keys.sort.each do |key|
      value = res[:moduleoptions][key]
      val = value
      # FIXME: After coi-gov-pl/puppet-jboss#59 is resolved the fallowing lines
      # should be moved to mungle function in securitydomain type not resource
      val = 'undefined' if val.nil?
      val = val.to_s if val.is_a?(Symbol)
      # New lines in values are not supported, they can't be passed to JBoss CLI
      val = val.gsub(/\n/, NEWLINE_REPLACEMENT).strip if val.is_a?(String)
      options << module_option_template % [key.inspect, val.inspect]
    end
    correct_cmd += options.join(COMMAND_SPLITTER) + correct_command_template_ending
  end

  # Method that decides about what commands should be executed
  # @param {Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState} state of security domain
  # @return {List} commands
  def get_commands(state, resource)
    decide(resource, state)
  end

  # Methods that compiles jboss command
  # @param {String} command jboss command that will be executed
  # @return {String} comamnd with profile if needed
  def compile_command(base_command, resource)
    @compilator.compile(resource[:runasdomain], resource[:profile], base_command)
  end

  protected

  ABSTRACT_MESSAGE = 'Abstract class, implement ths method'

  def correct_command_template_begining(resource)
    raise ABSTRACT_MESSAGE
  end

  def correct_command_template_ending
    raise ABSTRACT_MESSAGE
  end

  def module_option_template
    raise ABSTRACT_MESSAGE
  end
end
