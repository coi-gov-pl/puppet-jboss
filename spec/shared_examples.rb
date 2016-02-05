module Testing::JBoss::SharedExamples

  def working_jboss_installation
    name = "working jboss installation"
    shared_examples(name) do
      it { is_expected.to compile }
      it { is_expected.to contain_user 'jboss' }
      it { is_expected.to contain_class 'jboss' }
      it { is_expected.to contain_group 'jboss' }
      it { is_expected.to contain_package 'wget' }
      it { is_expected.to contain_package 'unzip' }
      it { is_expected.to contain_class 'jboss::internal::service' }
      it { is_expected.to contain_class 'jboss::params' }
      it { is_expected.to contain_class 'jboss::internal::runtime' }
      it { is_expected.to contain_class 'jboss::internal::augeas' }
      it { is_expected.to contain_class 'jboss::internal::params' }
      it { is_expected.to contain_class 'jboss::internal::runtime::dc' }
    end
    name
  end

  def common_anchors
    anchor_list = [
      "begin", "end", "configuration::begin", "configuration::end",
      "installed", "package::begin", "package::end",
      "service::begin", "service::end", "service::started"].map {|item| "jboss::#{item}"}
    name = 'having common anchors'
    shared_examples(name) do
      anchor_list.each do |item|
        it { is_expected.to contain_anchor("#{item}") }
      end
    end
    name
  end

  def common_interfaces(version)
    bind_variables_list = [
      "inet-address", "link-local-address",
      "loopback", "loopback-address", "multicast",
      "nic", "nic-match", "point-to-point", "public-address",
      "site-local-address", "subnet-match", "up", "virtual",
      "any-ipv4-address", "any-ipv6-address" ]
    name = 'common interfaces'
    shared_examples(name) do
      it { is_expected.to contain_class 'jboss::internal::configure::interfaces' }
      it { is_expected.to contain_jboss__interface('public').with({
        :ensure       => 'present',
        :inet_address => nil
        }) }
      it { is_expected.to contain_augeas('ensure present interface public').with({
          :context => "/files/usr/lib/wildfly-#{version}/standalone/configuration/standalone-full.xml/",
          :changes => "set server/interfaces/interface[last()+1]/#attribute/name public",
          :onlyif  => "match server/interfaces/interface[#attribute/name='public'] size == 0"
          }) }
      it { is_expected.to contain_augeas('interface public set any-address').with({
        :context => "/files/usr/lib/wildfly-#{version}/standalone/configuration/standalone-full.xml/",
        :changes => "set server/interfaces/interface[#attribute/name='public']/any-address/#attribute/value 'true'",
        :onlyif  => "get server/interfaces/interface[#attribute/name='public']/any-address/#attribute/value != 'true'"
        }) }
      it { is_expected.to contain_jboss__internal__interface__foreach("public:any-address").with({
        :cfg_file => "/usr/lib/wildfly-#{version}/standalone/configuration/standalone-full.xml",
        :path     => 'server/interfaces'
        }) }
      it { is_expected.to contain_service('wildfly').with({
        :ensure => 'running',
        :enable => true
        }) }
      bind_variables_list.each do |var|
        it { is_expected.to contain_augeas("interface public rm #{var}").with({
          :context => "/files/usr/lib/wildfly-#{version}/standalone/configuration/standalone-full.xml/",
          :changes => "rm server/interfaces/interface[#attribute/name='public']/#{var}",
          :onlyif  => "match server/interfaces/interface[#attribute/name='public']/#{var} size != 0"
          }) }
        it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}").with({
          :cfg_file => "/usr/lib/wildfly-#{version}/standalone/configuration/standalone-full.xml",
          :path     => 'server/interfaces'
          }) }
      end
    end
    name
  end
end
