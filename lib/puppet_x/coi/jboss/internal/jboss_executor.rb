#A class for Jboss executor, layer of abstraction beetwen providers and main jboss cli class
class Puppet_X::Coi::Jboss::Internal::JbossExecutor

  # Constructor to make an instance of jboss executor
  # @param {Puppet_X::Coi::Jboss::Provider::AbstractJbossCli} jboss cli class that will handle all of cli interactions
  def initialize(target)
    @target = target
  end
end
