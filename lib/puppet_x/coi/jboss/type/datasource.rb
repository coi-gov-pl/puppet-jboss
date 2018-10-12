# A module for Type::Datasource
module PuppetX::Coi::Jboss::Type::DataSource
  def self.define(type)
    type.instance_eval do
      @doc = 'Data sources configuration for JBoss Application Sever'
      ensurable

      newparam(:name) do
        desc 'Name of type resource'
        isnamevar
      end

      newproperty(:xa) do
        desc 'Is it XA Datasource?'
        newvalues :true, :false
        defaultto :false
        munge do |value|
          value == :true || value == true
        end
      end

      newproperty(:dbname) do
        desc "The database's name"
      end

      newproperty(:jndiname) do
        desc 'jndi-name'
      end

      newproperty(:jta) do
        desc 'jta'
        newvalues :true, :false
        defaultto :true
        munge do |value|
          value == :true || value == true
        end
      end

      newproperty(:drivername) do
        desc 'driver-name'
        isrequired
      end

      newproperty(:minpoolsize) do
        desc 'min-pool-size'
        munge do |value|
          begin
            value.to_i if Float value
          rescue
            1
          end
        end
      end

      newproperty(:maxpoolsize) do
        desc 'max-pool-size'
        munge do |value|
          begin
            value.to_i if Float value
          rescue
            50
          end
        end
      end

      newproperty(:username) do
        desc 'user-name'
        isrequired
      end

      newproperty(:password) do
        desc 'The internal JBoss user asadmin uses. Default: admin'
        isrequired
        def change_to_s(_from, _to)
          'password has been changed.'
        end
      end

      newproperty(:options) do
        desc 'Extra options for datasource or xa-datasource'

        validate do |value|
          matcher = PuppetX::Coi::Jboss::BuildinsUtils::HashlikeMatcher.new(value)
          unless PuppetX::Coi::Jboss::Constants::ABSENTLIKE_WITH_S.include?(value) || matcher.hashlike?
            raise Puppet::Error, "You can pass only hash-like objects or absent and undef values, given #{value.inspect}"
          end
        end

        munge do |value|
          matcher = PuppetX::Coi::Jboss::BuildinsUtils::HashlikeMatcher.new(value)
          ret = %w[absent undef].include?(value) ? value.to_sym : value
          if matcher.hashlike?
            value.each do |k, v|
              ret[k] = PuppetX::Coi::Jboss::Constants::ABSENTLIKE_WITH_S.include?(v) ? nil : v
            end
          end
          ret
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
                        "option '#{key}' was #{current_value.inspect} and has been removed"
                      elsif absentlike.include?(current_value) && !absentlike.include?(desired_value)
                        "option '#{key}' has been set to #{desired_value.inspect}"
                      else
                        "option '#{key}' has changed from #{current_value.inspect} to #{desired_value.inspect}"
                      end
            changes << message unless current_value == desired_value
          end
          changes.join ', '
        end
      end

      newproperty(:enabled) do
        desc 'Is datasource enabled?'
        newvalues :true, :false
        defaultto :true
        munge do |value|
          value == :true || value == true
        end
      end

      newproperty(:host) do
        desc 'host to connect'
        isrequired
        validate do |value|
          # Regex developed here (hostnames, ipv4, ipv6): https://regex101.com/r/hJ4jD1/3
          re = /^((?:[a-zA-Z0-9_-]+\.)*[a-zA-Z0-9_-]+|(?:[a-fA-F0-9]{0,4}:){2,5}[a-fA-F0-9]{1,4})$/
          unless value == '' || re.match(value.to_s)
            raise Puppet::Error, "Datasource host is invalid, given #{value.inspect}"
          end
        end
      end

      newproperty(:port) do
        desc 'port to connect'
        isrequired
        validate do |value|
          unless value == '' || /^\d+$/.match(value.to_s)
            raise Puppet::Error, "Datasource port is invalid, given #{value.inspect}"
          end
        end
        munge do |value|
          value == '' ? 0 : Integer(value)
        end
      end

      newproperty(:jdbcscheme) do
        desc 'jdbcscheme to be used'
        isrequired
      end
    end
    PuppetX::Coi::Jboss::Type::Meta.define(type)
  end
end
