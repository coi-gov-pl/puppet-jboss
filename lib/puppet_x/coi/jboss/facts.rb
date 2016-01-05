require File.expand_path(File.join(File.dirname(__FILE__), '/configuration'))

# A puppet x module
module Puppet_X
# A COI puppet_x module
module Coi
# JBoss module
module Jboss
# A class for JBoss facts
class Facts
  class << self
      def define_fullconfig_fact
        config = Puppet_X::Coi::Jboss::Configuration::read
        unless config.nil?
          config.each do |key, value|
            fact_symbol = "jboss_#{key}".to_sym
            Facter.add(fact_symbol) do
              setcode { value }
            end
          end
          Facter.add(:jboss_fullconfig) do
            setcode do
              if Puppet_X::Coi::Jboss::Configuration.ruby_version < '1.9.0'
                class << config
                  define_method(:to_s, proc { self.inspect })
                end
              end
              config
            end
          end
        end
      end
  end
end

end
end
end
