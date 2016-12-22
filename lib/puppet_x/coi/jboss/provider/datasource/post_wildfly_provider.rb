# A class for JBoss post WildFly datasource provider
class Puppet_X::Coi::Jboss::Provider::Datasource::PostWildFlyProvider
  # Standard constructor
  # @param {Hash} provider standard Puppet provider
  def initialize(provider)
    @provider = provider
  end

  # Method that wraps given parameter in curly braces
  # @param {List} parameters lsit of parameters that will be wrapped
  # @return {String}
  def xa_datasource_properties_wrapper(parameters)
    "{#{parameters}}"
  end

  # Method that return true if we need xa r else returns value of jta attribute
  # @return {String|String}
  def jta
    if @provider.xa?
      true.to_s
    else
      @provider.getattrib('jta').to_s
    end
  end

  # Method that sets value of jta
  # @param {Object} value
  def jta= value
    Puppet.warning 'JTA does not make sense in XA Datasource as distributed transaction is being used' if @provider.xa?
    @provider.setattrib('jta', value.to_s) unless @provider.xa?
  end

  # Method that adds jta options to command
  # @param {String} cmd jboss command
  # @return {String} command with jta parameter
  def jta_opt(cmd)
    cmd.push "--jta=#{@provider.resource[:jta].inspect}" unless @provider.xa?
  end
end
