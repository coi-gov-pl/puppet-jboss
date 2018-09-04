# A module that holds JBoss datasource provider lib metod
# This module should be loaded staticly
#   class << self
#     include PuppetX::Coi::Jboss::Provider::Datasource::Static
#   end
module PuppetX::Coi::Jboss::Provider::Datasource::Static

  # Method that decides about type of datasource
  # @param {Boolean} xa value that holds information that we want to use xa datasource
  # @return {String} type of datasource
  def datasource_type(xa)
    if xa
      "xa-data-source"
    else
      "data-source"
    end
  end
end
