require 'augeas'
aug = Augeas::open('/', nil, Augeas::NO_MODL_AUTOLOAD)
aug.transform(:lens => 'Shellvars.lns', :incl => '/etc/jboss-as/jboss-as.conf', :name => 'jboss-as.conf')
aug.load
aug.match('/files/etc/jboss-as/jboss-as.conf/*').each { |key|
    m = key[/(JBOSS_.+)$/]
    if m
        v = aug.get(key)
        Facter.add(m.downcase) do
          setcode { v }
        end
    end
}

aug.close

