require_relative 'facts'

class Puppet_X::Coi::Jboss::FactsRefresher
  class << self

    def refresh_facts
      Puppet_X::Coi::Jboss::Facts::define_fullconfig_fact
    end
  end
end
