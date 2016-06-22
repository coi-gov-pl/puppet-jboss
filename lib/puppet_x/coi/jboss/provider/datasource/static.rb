# A module that holds JBoss datasource provider lib metod
# This module should be loaded staticly
#   class << self
#     include Puppet_X::Coi::Jboss::Provider::Datasource::Static
#   end
module Puppet_X::Coi::Jboss::Provider::Datasource::Static

  def datasource_type(xa)
    if xa
      "xa-data-source"
    else
      "data-source"
    end
  end
end
