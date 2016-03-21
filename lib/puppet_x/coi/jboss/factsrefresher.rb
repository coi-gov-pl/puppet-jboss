require_relative 'facts'

class Puppet_X::Coi::Jboss::FactsRefresher
  class << self

    # Method to refresh given facts
    # @param {[Symbol]}  list of fact symbols to be refreshed
    def refresh_facts value
      facts = Facter.list # get list of symbols of facts in the system
      config = Puppet_X::Coi::Jboss::Configuration::read

      value.each do |val|
        raise Puppet::Error, 'You can only delete fact that are made by jboss_module(start with jboss_)' unless validate_fact_name val
        delete_resolves val
        delete_value val

        fact_value = config[val.to_sym]
        Puppet_X::Coi::Jboss::Facts::add_fact(val.to_sym, fact_value)
      end
    end

    # Method used to delete resolves in given fact
    # @param {String} fact_symbol that resolves should be deleted
    def delete_resolves fact_symbol
      fct = Facter.fact fact_symbol
      fct.instance_variable_set(:@resolves, [])
    end

    # Method used to delete values in given fact
    # @param {String} fact_symbol that value should be deleted
    def delete_value fact_symbol
      fct = Facter.fact fact_symbol
      fct.instance_variable_set(:@value, {})
    end

    private
    # Method used to validate if fact is system or module fact
    # @param {String} name of the fact to be validated
    # @return {true} if fact name is from jboss module
    def validate_fact_name value
      value.to_s.start_with? 'jboss_'
    end
  end
end
