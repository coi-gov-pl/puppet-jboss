# A module for Type::JdbcDriver
module PuppetX::Coi::Jboss::Type::JdbcDriver
  def self.define(type)
    type.instance_eval do
      @doc = 'Manages JDBC driver on JBoss Application Server'
      ensurable

      newparam(:name) do
        desc 'The name of driver.'
        isnamevar
        isrequired
      end

      newparam(:modulename) do
        desc 'Driver module name.'
        isrequired
      end

      newparam(:classname) do
        desc 'Driver Java class name.'
      end

      newparam(:datasourceclassname) do
        desc 'Datasource Java class name.'
      end

      newparam(:xadatasourceclassname) do
        desc 'XA Datasource Java class name.'
      end
    end
    PuppetX::Coi::Jboss::Type::Meta.define(type)
  end
end
