# Represents a command to be executed on OS
class PuppetX::Coi::Jboss::Value::Command
  attr_reader :command, :environment

  def initialize(command, environment)
    @command = command
    @environment = environment
  end

  def with(key, value)
    @environment[key] = value
  end
end
