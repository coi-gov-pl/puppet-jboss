require 'augeas'
configfile = Facter.value(:jboss_configfile)
unless configfile.nil?
  aug = Augeas::open('/', nil, Augeas::NO_MODL_AUTOLOAD)
  aug.transform(:lens => 'Shellvars.lns', :incl => configfile, :name => 'jboss-as.conf')
  aug.load
  is_bool = lambda { |value| !/^(true|false)$/.match(value).nil? }
  to_bool = lambda { |value| if !/^true$/.match(value).nil? then true else false end }                                   
  map = {}
  aug.match("/files#{configfile}/*").each do |key|
      m = key[/(JBOSS_.+)$/]
      if m
          v = aug.get(key)
          v = to_bool.call(v) if is_bool.call(v)
          map[m.downcase.sub('jboss_', '')] = v
          Facter.add(m.downcase) do
            setcode { v }
          end
      end
  end
  aug.close
  Facter.add(:jboss_fullconfig) do
    setcode { map }
  end
  
end