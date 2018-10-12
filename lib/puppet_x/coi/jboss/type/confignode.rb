# A module for Type::ConfigNode
module PuppetX::Coi::Jboss::Type::ConfigNode
  def self.define(type)
    type.instance_eval do
      @doc = 'Generic configuration entry for JBoss Application Sever'

      newproperty(:ensure) do
        desc 'Whether a configuration node should be in one of `present`, `absent`, `running`, `stopped`, `disabled` or `enabled` state.'

        newvalues :stopped, :running, :present, :absent, :enabled, :disabled

        aliasvalue(:true, :present)
        aliasvalue(:false, :absent)
      end
      newparam(:name) do
        desc 'The name of resource'
      end

      newparam(:path) do
        desc 'The JBoss configuration path to be ensured'
      end

      newproperty(:properties) do
        desc 'Additional properties for node'

        munge do |value|
          if %w[absent undef].include?(value)
            value.to_sym
          else
            matcher = PuppetX::Coi::Jboss::BuildinsUtils::HashlikeMatcher.new(value)
            if matcher.hashlike?
              value
            else
              {}
            end
          end
        end

        def change_to_s(current, desire)
          absentlike = PuppetX::Coi::Jboss::Constants::ABSENTLIKE_WITH_S
          changes = []
          keys = []
          keys.concat(desire.keys) unless absentlike.include?(desire)
          keys.concat(current.keys) unless absentlike.include?(current)
          keys.uniq.sort.each do |key|
            desired_value = absentlike.include?(desire) ? desire : desire[key]
            current_value = absentlike.include?(current) ? current : current[key]
            message = if absentlike.include?(desired_value) && !absentlike.include?(current_value)
                        "property '#{key}' was #{current_value.inspect} and has been removed"
                      elsif absentlike.include?(current_value) && !absentlike.include?(desired_value)
                        "property '#{key}' has been set to #{desired_value.inspect}"
                      else
                        "property '#{key}' has changed from #{current_value.inspect} to #{desired_value.inspect}"
                      end
            changes << message unless current_value == desired_value
          end
          changes.join ', '
        end
      end
    end
    PuppetX::Coi::Jboss::Type::Meta.define(type)
  end
end
