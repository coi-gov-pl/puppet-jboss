require File.expand_path(File.join(File.dirname(__FILE__), 'jbosscli.rb'))

Puppet::Type.type(:jboss_datasource).provide(:wildflycli, :parent => Puppet::Type.type(:jboss_datasource).provider(:jbosscli)) do
  desc "WildFly CLI datasource provider"
  
  confine :false => begin
    Facter.value(:jboss_product) == 'jboss-as' or 
    (Facter.value(:jboss_product) == 'jboss-eap' and Facter.value(:jboss_version) < '6.3.0.GA')
  end
  
  def xa_datasource_properties_wrapper(parameters)
    "{#{parameters}}"
  end
  
  def jta
    if xa?
      true.to_s
    else
      getattrib('jta').to_s
    end
  end

  def jta= value
    Puppet.waring 'JTA does not make sense in XA Datasource as distributed transaction is being used' if @resource[:xa]
    setattrib 'jta', value.to_s unless @resource[:xa]
  end
  
  def jta_opt(cmd)
    cmd.push "--jta=#{@resource[:jta].inspect}" unless @resource[:xa]
  end
end