require 'spec_helper_puppet'

describe 'jboss::internal::lenses', :type => :class do
  defaults = {
    :version => '9.0.2.Final',
    :product => 'wildfly'
  }

  shared_examples 'completly working define jboss::internal::lenses' do
    it { is_expected.to contain_class 'jboss::internal::lenses' }
    it { is_expected.to contain_class 'jboss' }
    it do
      is_expected.to contain_file(
        "/usr/lib/#{defaults[:product]}-#{defaults[:version]}/lenses/jbxml.aug"
      ).with(
        :ensure => 'file',
        :source => 'puppet:///modules/jboss/jbxml.aug'
      )
    end
    it do
      is_expected.to contain_file(
        "/usr/lib/#{defaults[:product]}-#{defaults[:version]}/lenses/jbxml.aug"
      ).that_requires(
        "File[/usr/lib/#{defaults[:product]}-#{defaults[:version]}/lenses/]"
      )
    end
    it do
      is_expected.to contain_file(
        "/usr/lib/#{defaults[:product]}-#{defaults[:version]}/lenses"
      ).with(
        :ensure => 'directory',
        :owner  => 'jboss'
      )
    end
    it do
      is_expected.to contain_file(
        "/usr/lib/#{defaults[:product]}-#{defaults[:version]}/lenses"
      ).that_requires(
        'Anchor[jboss::configuration::begin]'
      )
    end
  end

  on_supported_os.each do |os, facts|
    context "On #{os}" do
      let(:title) { 'test-lenses' }
      let(:facts) { facts.merge(:concat_basedir => '/root') }
      it_behaves_like 'completly working define jboss::internal::lenses'
    end
  end
end
