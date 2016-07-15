# A class for JBoss pre WildFly datasource provider
class Puppet_X::Coi::Jboss::Provider::Datasource::PreWildFlyProvider
  # Standard constructor
  # @param {Hash} provider standard Puppet provider
  def initialize(provider)
    @provider = provider
  end

  # Method that wraps given parameter in curly braces
  # @param {List} parameters lsit of parameters that will be wrapped
  # @return {String}
  def xa_datasource_properties_wrapper(parameters)
    "[#{parameters}]"
  end

  # Method that return true if we need xa r else returns value of jta attribute
  # @return {String|String}
  def jta
    @provider.getattrib('jta').to_s
  end

  # Method that sets value of jta
  # @param {Object} value
  def jta=(value)
    @provider.setattrib('jta', value.to_s)
  end

  # Method that adds jta options to command
  # @param {String} cmd jboss command
  # @return {String} command with jta parameter
  def jta_opt(cmd)
    cmd.push "--jta=#{@provider.resource[:jta].inspect}"
  end
end
