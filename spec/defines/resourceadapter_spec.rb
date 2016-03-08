require 'spec_helper_puppet'

describe 'jboss::resourceadapter', :type => :define do
  shared_examples 'contains self' do

    it { is_expected.to contain_jboss_resourceadapter(title).with({
      :ensure  => 'present',
      :archive => 'jca-filestore.rar'
    })}
    it { is_expected.to contain_jboss_resourceadapter(title).
      that_requires('Anchor[jboss::package::end]') }
    it { is_expected.to contain_jboss__resourceadapter(title).with({
      :ensure             => 'present',
      :archive            => 'jca-filestore.rar',
      :transactionsupport => 'LocalTransaction',
      :classname          => 'org.example.jca.FileSystemConnectionFactory',
      }) }
  end

  context 'On RedHat os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-resourceadapter' }
    let(:params) do
      {
        :jndiname           => 'java:/jboss/jca/photos',
        :archive            => 'jca-filestore.rar',
        :transactionsupport => 'LocalTransaction',
        :classname          => 'org.example.jca.FileSystemConnectionFactory',
      }
    end
    let(:facts) { Testing::JBoss::SharedFacts.oraclelinux_facts }

    it_behaves_like containing_basic_class_structure
    it_behaves_like 'contains self'
  end

  context 'On Debian os family' do
    extend Testing::JBoss::SharedExamples
    let(:title) { 'test-resourceadapter' }
    let(:params) do
      {
        :jndiname           => 'java:/jboss/jca/photos',
        :archive            => 'jca-filestore.rar',
        :transactionsupport => 'LocalTransaction',
        :classname          => 'org.example.jca.FileSystemConnectionFactory',
      }
    end
    let(:facts) { Testing::JBoss::SharedFacts.ubuntu_facts }

    it_behaves_like containing_basic_class_structure
    it_behaves_like 'contains self'
  end
end
