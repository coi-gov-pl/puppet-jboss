# Internal class to audits what is the state of securitydomain in Jboss instance
# Do not use outside of securitydomain provider
class Puppet_X::Coi::Jboss::Internal::SecurityDomainAuditor

  # Constructor
  # @param {Hash} resource standard puppet resource object
  # @param {Puppet_X::Coi::Jboss::Internal::CliExecutor} cli_executor that will handle execution of
  # command
  # @param {Puppet_X::Coi::Jboss::Internal::CommandCompilator} compilator object that handles
  # compilaton of command to be executed
  # @param {Puppet_X::Coi::Jboss::Internal::SecurityDomainDestroyer} destroyer object that handles removing of
  # securitydomain
 def initialize(resource, cli_executor, compilator, destroyer)
   @resource = resource
   @cli_executor = cli_executor
   @compilator = compilator
   @destroyer = destroyer
   @state = nil
 end

 # Method that checks if securitydomain exists
 # @return {Boolean} returns true if security-domain exists in any state
 def exists?

   raw_result = read_resource_recursive

   unless raw_result[:result]
     Puppet.debug "Security Domain does NOT exist"
     return false
   end
   actual_data = evaluate_data(raw_result)

   resolve_state(actual_data, @resource)
 end

 # Internal mathod that saves current state of every subpath of securitydomain
 def fetch_securtydomain_state

   data = @state
   unless data['security-domain']["#{@resource[:name]}"]
     state = Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState.new
   else
   state = Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState.new
     unless data['security-domain']["#{@resource[:name]}"]['cache-type'].nil?
       state.is_cache_default = true
     end
     unless data['security-domain']["#{@resource[:name]}"]["authentication"].nil?
       state.is_authentication = true
     end
     state
   end
   state
 end

 private

 #TODO check if there is safer way to do it
 def evaluate_data(result)
   undefined = nil
   lines = preparelines(result[:data].to_s)
   #TODO: $SAFE = 4
   evaluated_data = eval(lines)
   Puppet.debug("Evaluated data for security-domain #{@resource[:name]}: #{evaluated_data.inspect}")
   evaluated_data
 end

  # Method prepares lines outputed by JBoss CLI tool, changing output to be readable in Ruby
 # @param {string[]} lines
 def preparelines(lines)
   lines.
     gsub(/\((\"[^\"]+\") => (\"[^\"]+\")\)/, '\1 => \2').
     gsub(/\[((?:[\n\s]*\"[^\"]+\" => \"[^\"]+\",?[\n\s]*)+)\]/m, '{\1}')
 end

 # Method that handles execution of command
 def read_resource_recursive
   cmd = @compilator.compile(@resource[:runasdomain], @resource[:profile],  "/subsystem=security:read-resource(recursive=true)")

   conf = {
     :controller  => @resource[:controller],
     :ctrluser    => @resource[:ctrluser],
     :ctrlpasswd  => @resource[:ctrlpasswd],
   }

   @cli_executor.executeAndGet(cmd, @resource[:runasdomain],  conf, 0, 0)
 end

 # Method that checks current situation of security-domain in Jboss instance
 # @param {Hash} actual_data output of recursive read of security-domain resource
 # @param {Hash} resource reference to standard puppet resource object
 # @return {Boolean} return true if security-domain with given name exists in any state
 def resolve_state(actual_data, resource)
   @state = actual_data
   unless actual_data.key? "security-domain"
     Puppet.debug("There is no securitydomain at all")
     return false
   end
  #  unless actual_data["security-domain"].key? resource[:name]
  #    Puppet.debug "There is securitydomain with such name #{resource[:name]}"
  #    return false
  #  end
   Puppet.debug "Security Domain exists: #{actual_data.inspect}"

   existinghash = Hash.new
   givenhash = Hash.new

   Puppet.debug("#{resource['moduleoptions']}")

   unless resource[:moduleoptions].nil?
     resource[:moduleoptions].each do |key, value|
       givenhash["#{key}"] = value.to_s.gsub(/\n/, ' ').strip
     end
   end

   actual_data['login-modules'][0]['module-options'].each do |key, value|
     existinghash[key.to_s] = value.to_s.gsub(/\n/, ' ').strip
   end

   if !existinghash.nil? && !givenhash.nil? && existinghash != givenhash
     diff = givenhash.to_a - existinghash.to_a
     Puppet.notice "Security domain should be recreated. Diff: #{diff.inspect}"
     Puppet.debug "Security domain moduleoptions existing hash => #{existinghash.inspect}"
     Puppet.debug "Security domain moduleoptions given hash => #{givenhash.inspect}"
     @destroyer.destroy
     return false
   end
   return true
 end
end
