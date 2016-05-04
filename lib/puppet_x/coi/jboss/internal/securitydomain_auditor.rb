# Internal class to audits what is the state of securitydomain in Jboss instance
# Do not use outside of securitydomain provider
class Puppet_X::Coi::Jboss::Internal::SecurityDomainAuditor

 def initialize(resource, runner)
   @resource = resource
   @runner = runner
 end

 # Method that checks if securitydomain exists
 def exists?

   res = read_resource

   unless res[:result]
     Puppet.debug "Security Domain does NOT exist"
     return false
   end

   undefined = nil
   lines = preparelines res[:data].to_s
   data = eval(lines)
   save_state(data)
   read_resource_state(data, @resource)
 end

 # Internal mathod that saves current state of every subpath of securitydomain
 def fetch_securtydomain_state
   Puppet.debug("Stateeeeee: #{@state}")
   Puppet.debug('I`m in fetch securitydomain state')

   data = @state
   unless data['security-domain']["#{@resource[:name]}"]
     state = Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState.new
   else
   state = Puppet_X::Coi::Jboss::Internal::State::SecurityDomainState.new
   Puppet.debug("I`m after state creation")
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

  # Method prepares lines outputed by JBoss CLI tool, changing output to be readable in Ruby
 # @param {string[]} lines
 def preparelines lines
   lines.
     gsub(/\((\"[^\"]+\") => (\"[^\"]+\")\)/, '\1 => \2').
     gsub(/\[((?:[\n\s]*\"[^\"]+\" => \"[^\"]+\",?[\n\s]*)+)\]/m, '{\1}')
 end

 def read_resource
   compilator = Puppet_X::Coi::Jboss::Internal::CommandCompilator.new
   cmd = compilator.compile(@resource[:runasdomain], @resource[:profile],  "/subsystem=security:read-resource(recursive=true)")

   conf = {
     :controller  => @resource[:controller],
     :ctrluser    => @resource[:ctrluser],
     :ctrlpasswd  => @resource[:ctrlpasswd],
   }

   @runner.executeAndGet(cmd, @resource[:runasdomain],  conf, 0, 0)
 end

 def read_resource_state(data, resource)
   if data["security-domain"].key? resource[:name]
     Puppet.debug "There is securitydomain with such name #{resource[:name]}"
     return true
   else
     return false
   end
   Puppet.debug "Security Domain exists: #{data.inspect}"

   existinghash = Hash.new
   givenhash = Hash.new

   Puppet.debug("#{resource['moduleoptions']}")

   unless resource[:moduleoptions].nil?
     resource[:moduleoptions].each do |key, value|
       givenhash["#{key}"] = value.to_s.gsub(/\n/, ' ').strip
     end
   end

   data['login-modules'][0]['module-options'].each do |key, value|
     existinghash[key.to_s] = value.to_s.gsub(/\n/, ' ').strip
   end

   if !existinghash.nil? && !givenhash.nil? && existinghash != givenhash
     diff = givenhash.to_a - existinghash.to_a
     Puppet.notice "Security domain should be recreated. Diff: #{diff.inspect}"
     Puppet.debug "Security domain moduleoptions existing hash => #{existinghash.inspect}"
     Puppet.debug "Security domain moduleoptions given hash => #{givenhash.inspect}"
     destroy
     return false
   end
   return true
 end

 private
  def save_state(data)
    @state = {}
    @state = data
  end
end
