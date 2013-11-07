require 'puppet/provider/jbosscli'
Puppet::Type.type(:jboss_confignode).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  desc "JBoss CLI configuration node provider"
  
  def create
    
  end

  def destroy
    
  end
  
  def exists?
    if execute("#{compiledpath}:read-resource()")[:result]
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