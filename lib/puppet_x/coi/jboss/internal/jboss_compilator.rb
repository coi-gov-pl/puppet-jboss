class Puppet_X::Coi::Jboss::Internal::JbossCompilator

  def compile(runasdomain, profile, cmd)
    out = cmd.to_s
    convr = Puppet_X::Coi::Jboss::BuildinsUtils::ToBooleanConverter.new(runasdomain)
    asdomain = convr.to_bool
    if asdomain && out[0..9] == '/subsystem'
      out = "/profile=#{profile}#{out}"
    end
    return out
  end

end
