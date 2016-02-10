require 'spec_helper_puppet'

describe 'jboss::internal::quirks::etc_initd_functions', :type => :class do

  shared_examples 'contains installtion classes' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class 'jboss::internal::compatibility' }
  end

  shared_examples 'do not contains quirks files & execs' do
    it { is_expected.not_to contain_file('/sbin/consoletype') }
    it { is_expected.not_to contain_file('/etc/init.d/functions') }
    it { is_expected.not_to contain_exec("sed -i '1s/.*/#!\/bin\/bash/' /usr/lib/jboss-eap-6.4.0.GA/bin/init.d/jboss-as-standalone.sh") }
  end

  shared_examples 'contains quirks files & execs' do
    it { is_expected.to contain_file('/sbin/consoletype').
      with_mode('0755')
    }
    it { is_expected.to contain_file('/etc/init.d/functions').
      with_ensure('file').
      with_source('puppet:///modules/jboss/rhel-initd-functions.sh').
      that_requires('File[/sbin/consoletype]')
    }
  end

  context 'On Debian os family' do
    let(:initd_file) {  }
    let(:title) { 'test-etc_initd_functions' }
    let(:facts) do
      {
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :lsbdistcodename => 'trusty',
        :puppetversion   => Puppet.version,
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

      }
    end
    it_behaves_like 'contains installtion classes'
    it_behaves_like 'do not contains quirks files & execs'


    context 'Running Wildfly' do
      let(:product) { 'wildfly' }
      let(:version) { '8.2.0.Final' }
      let(:pre_condition) do
        "class { 'jboss': product => '#{product}', version => '#{version}' }"
      end
      it_behaves_like 'contains installtion classes'
      it_behaves_like 'do not contains quirks files & execs'
    end
    context 'Running JBoss eap >= 6.4' do
      let(:product) { 'jboss-eap' }
      let(:version) { '6.4.0.GA' }
      let(:pre_condition) do
        "class { 'jboss': product => '#{product}', version => '#{version}' }"
      end
      it_behaves_like 'contains installtion classes'
      it { is_expected.not_to contain_exec("sed -i '1s/.*/#!\\/bin\\/bash/' /usr/lib/#{product}-#{version}/bin/init.d/jboss-as-standalone.sh}").
        that_requires('Anchor[jboss::package::end]').
        that_notifies("Service[#{product}]")
      }
    end

    context 'Running JBoss eap < 6.4' do
      let(:product) { 'jboss-eap' }
      let(:version) { '6.2.0.GA' }
      let(:pre_condition) do
        "class { 'jboss': product => '#{product}', version => '#{version}' }"
      end
      it_behaves_like 'contains installtion classes'
      it_behaves_like 'contains quirks files & execs'
      it { is_expected.to contain_exec("sed -i '1s/.*/#!\\/bin\\/bash/' /usr/lib/#{product}-#{version}/bin/init.d/jboss-as-standalone.sh").
        that_requires('Anchor[jboss::package::end]').
        that_notifies("Service[#{product}]")
      }
    end
    context 'Running JBoss AS' do
      let(:product) { 'jboss-as' }
      let(:version) { '7.1.0.Final' }
      let(:pre_condition) do
        "class { 'jboss': product => '#{product}', version => '#{version}' }"
      end
      it_behaves_like 'contains installtion classes'
      it_behaves_like 'contains quirks files & execs'
      it { is_expected.to contain_exec("sed -i '1s/.*/#!\\/bin\\/bash/' /usr/lib/#{product}-#{version}/bin/init.d/jboss-as-standalone.sh").
        that_requires('Anchor[jboss::package::end]').
        that_notifies("Service[#{product}]")
     }
    end
  end

  context 'On other OS for ex.: OracleLinux' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-etc_initd_functions' }
    let(:facts) do
      {
        :operatingsystem => 'OracleLinux',
        :osfamily        => 'RedHat',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :puppetversion   => Puppet.version
      }
    end
    it_behaves_like 'contains installtion classes'
    it_behaves_like 'do not contains quirks files & execs'
    it_behaves_like_full_working_jboss_installation
  end
end
