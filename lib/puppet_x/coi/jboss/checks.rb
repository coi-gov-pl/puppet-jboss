# A module that contains checks
module PuppetX::Coi::Jboss::Checks
  def assert_not_nil(value)
    raise Puppet::Error, 'value cant be nil' if value.nil?
    value
  end

  # Will verify if value is not nil
  # @param {string} value - a nillable value
  def check_not_empty(value)
    raise Puppet::Error, 'Value can\'t be nil' if value.nil?
    raise Puppet::Error, 'Value can\'t be empty' if value.empty?
    value
  end
end
