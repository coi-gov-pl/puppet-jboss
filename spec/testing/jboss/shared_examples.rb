module Testing::JBoss::SharedExamples
  DEFAULT_VERSION = '9.0.2.Final'
  DEFAULT_PRODUCT = 'wildfly'
  DEFAULT_WITH    = [
    :anchors,
    :interfaces,
    :packages
  ]
  DEFAULT_OPTIONS = {
    :product => DEFAULT_PRODUCT,
    :version => DEFAULT_VERSION,
    :with    => DEFAULT_WITH
  }

  def it_behaves_like_full_working_jboss_installation(options = DEFAULT_OPTIONS)
    without = options[:without] || []
    with = options[:with] || DEFAULT_WITH
    with = [with] unless with.is_a? Array
    with = with.reject { |el| without.include? el  }
    version = options[:version] || DEFAULT_VERSION
    product = options[:product] || DEFAULT_PRODUCT
    it_behaves_like working_jboss_installation
    it_behaves_like containg_installation_packages if with.include? :packages
    it_behaves_like common_anchors if with.include? :anchors
    it_behaves_like common_interfaces(version, product) if with.include? :interfaces
  end

  def containg_installation_packages
    name = 'containing installation packages'
    shared_examples(name) do
      it { is_expected.to contain_package 'wget' }
      it { is_expected.to contain_package 'unzip' }
    end
    name
  end

def containing_basic_class_structure
  name = "containing basic class structure"
  shared_examples(name) do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class 'jboss::internal::runtime::node' }
  end
  name
end

  def working_jboss_installation
    name = "working jboss installation"
    shared_examples(name) do
      it { is_expected.to compile }
      it { is_expected.to contain_user 'jboss' }
      it { is_expected.to contain_class 'jboss' }
      it { is_expected.to contain_group 'jboss' }
      it { is_expected.to contain_class 'jboss::internal::service' }
      it { is_expected.to contain_class 'jboss::params' }
      it { is_expected.to contain_class 'jboss::internal::runtime' }
      it { is_expected.to contain_class 'jboss::internal::augeas' }
      it { is_expected.to contain_class 'jboss::internal::params' }
      it { is_expected.to contain_class 'jboss::internal::runtime::dc' }
    end
    name
  end

  def it_behaves_like_containing_basic_includes
    name = 'it_behaves_like_containing_basic_includes'
    shared_examples(name) do
      it { is_expected.to contain_class('jboss') }
      it { is_expected.to contain_class('jboss::internal::service') }
      it { is_expected.to contain_class('jboss::internal::runtime::node') }
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

  def common_interfaces(version = DEFAULT_VERSION, product = DEFAULT_PRODUCT)
    basic_bind_variables_list = [
      "inet-address", "link-local-address",
      "loopback", "loopback-address", "multicast",
      "nic", "nic-match", "point-to-point", "public-address",
      "site-local-address", "subnet-match", "up", "virtual" ]
    name = 'common interfaces'
    shared_examples(name) do
      it { is_expected.to contain_class 'jboss::internal::configure::interfaces' }
      it { is_expected.to contain_jboss__interface('public').with({
        :ensure       => 'present',
        :inet_address => nil
        }) }
      it { is_expected.to contain_augeas('ensure present interface public').with({
          :context => "/files/usr/lib/#{product}-#{version}/standalone/configuration/standalone-full.xml/",
          :changes => "set server/interfaces/interface[last()+1]/#attribute/name public",
          :onlyif  => "match server/interfaces/interface[#attribute/name='public'] size == 0"
          }) }
      it { is_expected.to contain_augeas('interface public set any-address').with({
        :context => "/files/usr/lib/#{product}-#{version}/standalone/configuration/standalone-full.xml/",
        :changes => "set server/interfaces/interface[#attribute/name='public']/any-address/#attribute/value 'true'",
        :onlyif  => "get server/interfaces/interface[#attribute/name='public']/any-address/#attribute/value != 'true'"
        }) }
      it { is_expected.to contain_jboss__internal__interface__foreach("public:any-address").with({
        :cfg_file => "/usr/lib/#{product}-#{version}/standalone/configuration/standalone-full.xml",
        :path     => 'server/interfaces'
        }) }
      it { is_expected.to contain_service(product).with({
        :ensure => 'running',
        :enable => true
        }) }
      basic_bind_variables_list.each do |var|
        it { is_expected.to contain_augeas("interface public rm #{var}").with({
          :context => "/files/usr/lib/#{product}-#{version}/standalone/configuration/standalone-full.xml/",
          :changes => "rm server/interfaces/interface[#attribute/name='public']/#{var}",
          :onlyif  => "match server/interfaces/interface[#attribute/name='public']/#{var} size != 0"
          }) }
        it { is_expected.to contain_jboss__internal__interface__foreach("public:#{var}").with({
          :cfg_file => "/usr/lib/#{product}-#{version}/standalone/configuration/standalone-full.xml",
          :path     => 'server/interfaces'
          }) }
      end
    end
    name
  end
end
