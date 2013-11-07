require 'puppet/provider/jbosscli'
Puppet::Type.type(:jboss_configproperty).provide(:jbosscli, :parent => Puppet::Provider::Jbosscli) do
  desc "JBoss CLI configuration node's property provider"
  
  def create
    
  end

  def destroy
    
  end

  def exists?
    return false
  end
end