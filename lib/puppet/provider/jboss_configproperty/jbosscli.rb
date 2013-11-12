require 'puppet/provider/jbosscli'
Puppet::Type.type(:jboss_configproperty).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  desc "JBoss CLI configuration node's property provider"
  
  def create
    
  end

  def destroy
    
  end

  def exists?
    res = execute_datasource "#{compiledpath}:read-resource()"
    key = @resource[:key]
    if res[:result] and not res[:data][key]
      return true
    end
    return false
  end
  
  private
  
  def compiledpath
    path = @resource[:path]
    cmd = compilecmd path
  end
end