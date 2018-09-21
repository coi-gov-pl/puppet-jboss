# A module for Type::JmsQueue
module PuppetX::Coi::Jboss::Type::JmsQueue
  def self.define(type)
    type.instance_eval do
      @doc = 'JMS Queues configuration for JBoss Application Sever'
      ensurable

      newparam(:name) do
        desc 'name'
        isnamevar
      end

      newproperty(:entries, :array_matching => :all) do
        desc 'entries passed as array'

        def is_to_s(is)
          is.inspect
        end

        def should_to_s(should)
          should.inspect
        end
      end

      newproperty(:durable, :boolean => true) do
        newvalues :true, :false
        defaultto false
        desc 'durable true/false'
      end
    end
    PuppetX::Coi::Jboss::Type::Meta.define(type)
  end
end
