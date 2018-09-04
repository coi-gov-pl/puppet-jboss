# Class that handles compilation of commands
class PuppetX::Coi::Jboss::Internal::CommandCompilator
  # Method that adds profile and neccesary stuff
  # @param {Boolean} runasdomain if jbosss in in domain module
  # @param {String} profile name of profile
  # @param {String} cmd command that will be executed
  # @return {String} command that is ready to be executed
  def compile(runasdomain, profile, cmd)
    out = cmd.to_s
    convr = PuppetX::Coi::Jboss::BuildinsUtils::ToBooleanConverter.new(runasdomain)
    asdomain = convr.to_bool
    out = "/profile=#{profile}#{out}" if asdomain && out[0..9] == '/subsystem'
    out
  end
end
