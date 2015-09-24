require File.expand_path(File.join(File.dirname(__FILE__), '../../jboss'))

Puppet_X::Coi::Jboss.requirex 'type'

module Puppet_X::Coi::Jboss::Type::HashmapProperty
  # Define change to string function that is used to pring log message for properties that are changed
  def change_to_s(current, desire)
    changes = []
    if desire.respond_to? :[] and desire.respond_to? :keys
      keys = desire.keys.sort
      keys.each do |key|
        desired_value = desire[key]
        current_value = if current.respond_to? :[] then current[key] else nil end
        message = "property '#{key}' has changed from #{current_value.inspect} to #{desired_value.inspect}"
        changes << message unless current_value == desired_value   
      end
      changes.join ', '
    else
      "properties has been set to #{desire.inspect}"
    end
  end
end

# A hash map property configurator for a Puppet type
class Puppet_X::Coi::Jboss::Type::HashmapPropertyConfigurator

  # Constructor
  #
  # @param property [Puppet::Type::Property] a child type property
  # @return [Puppet::Type::Property] a child type property
  def initialize(property)
    @property = property
  end

  # Configure a property for type
  # @param docs [String] a documentation
  # @return [Puppet::Type::Property] a defined property
  def configure(docs)
    @property.desc docs
    @property.extend(Puppet_X::Coi::Jboss::Type::HashmapProperty)
  end

end