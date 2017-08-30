require 'spec_helper_puppet'

describe 'jboss::internal::module::registerlayer', :type => :define do
  let(:title) { 'testlayer' }
  let(:params) { { :layer => title, } }
  let(:pre_condition)  { "class { jboss: product => '#{product}', version => '#{version}', jboss_user => '#{user}', jboss_group => '#{group}', install_dir => '#{dir}' }" }
  let(:product) {'wildfly'}
  let(:version) {'9.0.2.Final'}
  let(:dir) {'/jboss'}
  let(:user) {'test-user'}
  let(:group) {'test-group'}
  let(:facts) do
    {
    :osfamily               => 'RedHat',
    :operatingsystem        => 'OracleLinux',
    :concat_basedir         => '/tmp/',
    :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    :operatingsystemrelease => '7.0',
    :virtual                => true,
    :jboss_running          => true,
    }
  end
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss' }
    it { is_expected.to contain_jboss__internal__module__registerlayer("#{title}") }
    it { is_expected.to contain_exec("jboss::module::layer::#{title}").with({
      :command => "awk -F'=' 'BEGIN {ins = 0} /^layers=/ { ins = ins + 1; print \$1=testlayer,\$2 } END {if(ins == 0) print \"layers=testlayer,base\"}' > #{dir}/#{product}-#{version}/modules/layers.conf",
      :unless  => "egrep -e '^layers=.*testlayer.*' #{dir}/#{product}-#{version}/modules/layers.conf",
      :user    => 'test-user'
      }) }
    it {
      is_expected.to contain_file("#{dir}/#{product}-#{version}/modules/system/layers/#{title}").with({
      :ensure => 'directory',
      :owner  => 'test-user',
      :group  => 'test-group',
      :mode   => '0640'
      }) }
end
