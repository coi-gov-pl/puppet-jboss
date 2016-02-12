module Testing::RspecPuppet::Package
  DEFAULT_VERSION = '8.2.0.Final'
  DEFAULT_PRODUCT = 'wildfly'

  DEFAULT_OPTIONS = {
    :product => DEFAULT_PRODUCT,
    :version => DEFAULT_VERSION
  }
  def package_files_for_jboss_product(options = DEFAULT_OPTIONS)
    without = options[:without] || []
    with = [with] unless with.is_a? Array
    with = with.reject { |el| without.include? el  }
    version = options[:version] || DEFAULT_VERSION
    product = options[:product] || DEFAULT_PRODUCT
    describe "with package files for #{product}" do
      it { is_expected.to contain_file("/etc/#{product}").with({
        :ensure => 'directory',
        :alias  => 'jboss::confdir',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755'
        })}
      it { is_expected.to contain_file("/usr/src/download-#{product}-#{version}").
        with_ensure('directory')}
      it { is_expected.to contain_jboss__internal__util__fetch__file('wildfly-8.2.0.Final.zip').with({
        :address   => 'http://download.jboss.org/wildfly/8.2.0.Final/wildfly-8.2.0.Final.zip',
        :fetch_dir => "/usr/src/download-#{product}-#{version}"}).
        that_requires("File[/usr/src/download-#{product}-#{version}]")}
      it { is_expected.to contain_jboss__internal__util__groupaccess("/usr/lib/#{product}-#{version}") }
      it { is_expected.to contain_file("/etc/#{product}/domain.xml") }
      it { is_expected.to contain_file("/etc/#{product}/host.xml") }
      it { is_expected.to contain_file("/etc/#{product}/standalone.xml") }
      it { is_expected.to contain_file("/etc/init.d/#{product}") }
    end
  end
end
