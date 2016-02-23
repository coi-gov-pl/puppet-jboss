require 'spec_helper_puppet'

describe 'jboss::internal::module::registerlayer', :type => :define do
  let(:title) { 'testlayer' }
  let(:params) { { :layer => title, } }
  let(:facts) do
    {
    :osfamily             => 'RedHat',
    :operatingsystem      => 'OracleLinux',
    :concat_basedir       => '/tmp/'
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_class 'jboss' }
  it { is_expected.to contain_jboss__internal__module__registerlayer("#{title}") }
  it { is_expected.to contain_exec("jboss::module::layer::#{title}").with({
    :user => 'jboss'
    }) }
  it {
    is_expected.to contain_file("/usr/lib/wildfly-8.2.0.Final/modules/system/layers/#{title}").with({
    :ensure => 'directory',
    :owner  => 'jboss',
    :group  => 'jboss',
    :mode   => '0640'
    }) }
end
