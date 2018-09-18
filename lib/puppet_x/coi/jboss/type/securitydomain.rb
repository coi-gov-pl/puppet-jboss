# A module for Type::SecurityDomain
module PuppetX::Coi::Jboss::Type::SecurityDomain
  def self.define(type)
    type.instance_eval do
      @doc = 'Security-domain configuration for JBoss Application Sever'
      ensurable

      newparam(:name) do
        desc ''
        isnamevar
      end

      newparam(:moduleoptions) do
        desc 'module-options given as a table'
      end

      newparam(:code) do
        desc 'code for JBOSS security-domain'
      end

      newparam(:codeflag) do
        desc 'codeflag for JBOSS security-domain'
      end
    end
    PuppetX::Coi::Jboss::Type::Meta.define(type)
  end
end
