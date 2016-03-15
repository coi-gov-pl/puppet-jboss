require_relative 'facts'

class Puppet_X::Coi::Jboss::FactsRefresher
  class << self

    def refresh_facts
      Puppet_X::Coi::Jboss::Facts::define_fullconfig_fact
    end

    # Method used to delete resolves in given fact
    # @param {String} fact name that resolves should be deleted
    def delete_resolves value
      if validate_fact_name value
        fct = Facter.fact value
        fct.instance_variable_set(:@resolves, [])
      else
        raise Puppet::Error, 'You can only delete fact that are made by jboss_module(start with jboss_)'
      end
    end

    # Method used to delete values in given fact
    # @param {String} fact name that value should be deleted
    def delete_value value
      if validate_fact_name value
        fct = Facter.fact value
        fct.instance_variable_set(:@value, {})
      else
        raise Puppet::Error, 'You can only delete fact that are made by jboss_module(start with jboss_)'
      end
    end

    private
    def validate_fact_name value
      value.to_s.start_with? 'jboss'
  end
end
end
