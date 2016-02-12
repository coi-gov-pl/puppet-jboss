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
      it { is_expected.to contain_jboss__internal__util__groupaccess("/usr/lib/#{product}-#{version}").with({
        :user => 'jboss'
        })}
      it { is_expected.to contain_file("/etc/#{product}/domain.xml").with({
        :ensure => 'link',
        :alias  => 'jboss::configuration-link::domain',
        :target => "/usr/lib/#{product}-#{version}/domain/configuration/domain.xml"
        })}
      it { is_expected.to contain_file("/etc/#{product}/host.xml").with({
        :ensure => 'link',
        :alias  => 'jboss::configuration-link::host',
        :target => "/usr/lib/#{product}-#{version}/domain/configuration/host.xml"
        })}
      it { is_expected.to contain_file("/etc/#{product}/standalone.xml").with({
        :ensure => 'link',
        :alias  => 'jboss::configuration-link::standalone',
        :target => "/usr/lib/#{product}-#{version}/standalone/configuration/standalone-full.xml"
        })}
      it { is_expected.to contain_file("/etc/init.d/#{product}").with({
        :ensure => 'link',
        :alias  => 'jboss::service-link'
        }) }
    end
  end

  def package_exec_for_jboss
    it { is_expected.to contain_exec('jboss::unzip-downloaded').with({
      :command => 'unzip -o -q /usr/src/download-wildfly-8.2.0.Final/wildfly-8.2.0.Final.zip -d /usr/lib/wildfly-8.2.0.Final',
      :cwd     => '/usr/src/download-wildfly-8.2.0.Final',
      :creates => '/usr/lib/wildfly-8.2.0.Final'
      }) }
    it { is_expected.to contain_exec('jboss::move-unzipped').with({
      :command => 'mv /usr/lib/wildfly-8.2.0.Final/*/* /usr/lib/wildfly-8.2.0.Final/',
      :creates => '/usr/lib/wildfly-8.2.0.Final/bin'}).
      that_requires('Exec[jboss::unzip-downloaded]')
    }
    it { is_expected.to contain_exec('jboss::test-extraction').with({
      :command => "echo '/usr/lib/wildfly-8.2.0.Final/bin/init.d not found!' 1>&2 && exit 1",
      :unless  => 'test -d /usr/lib/wildfly-8.2.0.Final/bin/init.d'}).
      that_requires('Exec[jboss::move-unzipped]')
    }
    it { is_expected.to contain_exec('jboss::package::check-for-java') }
  end
end
