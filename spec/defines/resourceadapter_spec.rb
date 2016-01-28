require 'spec_helper_puppet'

describe 'jboss::resourceadapter', :type => :define do
  shared_examples 'completly working define' do
    it { is_expected.to compile }
    it { is_expected.to contain_jboss_resourceadapter(title).with ({
      :ensure  => 'present',
      :archive => 'jca-filestore.rar'
    })}
    it { is_expected.to contain_jboss_resourceadapter(title).that_requires('Anchor[jboss::package::end]') }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class 'jboss::internal::runtime::node' }
    it { is_expected.to contain_jboss__resourceadapter(title) }
  end

  context 'On RedHat os family' do
    let(:title) { 'test-resourceadapter' }
    let(:params) do
      {
        :jndiname           => 'java:/jboss/jca/photos',
        :archive            => 'jca-filestore.rar',
        :transactionsupport => 'LocalTransaction',
        :classname          => 'org.example.jca.FileSystemConnectionFactory',
      }
    end
    let(:facts) do
      {
        :operatingsystem => 'OracleLinux',
        :osfamily        => 'RedHat',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :puppetversion   => Puppet.version
      }
    end
    it_behaves_like 'completly working define'
  end
  context 'On Debian os family' do
    let(:title) { 'test-resourceadapter' }
    let(:params) do
      {
        :jndiname           => 'java:/jboss/jca/photos',
        :archive            => 'jca-filestore.rar',
        :transactionsupport => 'LocalTransaction',
        :classname          => 'org.example.jca.FileSystemConnectionFactory',
      }
    end
    let(:facts) do
      {
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :ipaddress       => '192.168.0.1',
        :concat_basedir  => '/root/concat',
        :lsbdistcodename => 'trusty',
        :puppetversion   => Puppet.version
      }
    end
    it_behaves_like 'completly working define'
  end
end
