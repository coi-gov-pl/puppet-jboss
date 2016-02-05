# A module for JBoss security domain common abstract provider
class Puppet_X::Coi::Jboss::Provider::SecurityDomain::AbstractProvider
  COMMAND_SPLITTER = ','
  NEWLINE_REPLACEMENT = ' '

  # Creates a parametrized command to be executed by provider
  # @return {String} a complete command without profile
  def create_parametrized_cmd
    resource = @provider.resource
    correct_cmd = correct_command_template_begining(resource)
    options = []
    resource[:moduleoptions].keys.sort.each do |key|
      value = resource[:moduleoptions][key]
      val = value
      val = 'undefined' if val.nil?
      val = val.to_s if val.is_a?(Symbol)
      # New lines in values are not supported, they can't be passed to JBoss CLI
      val = val.gsub(/\n/, NEWLINE_REPLACEMENT).strip if val.is_a?(String)
      options << module_option_template % [key.inspect, val.inspect]
    end
    correct_cmd += options.join(COMMAND_SPLITTER) + correct_command_template_ending
    correct_cmd
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
