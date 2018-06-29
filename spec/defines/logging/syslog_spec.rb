require 'spec_helper_puppet'

describe 'jboss::logging::syslog', :type => :define do
  let(:title) { 'test-handler' }
  let(:params) { { :app_name => 'test-app' } }
  let(:facts) do
    {
      :osfamily           => 'RedHat',
      :operatingsystem    => 'RedHat',
      'jboss::profile'    => 'domain',
      'jboss::controller' => 'controller.example.com',
      :concat_basedir     => '/tmp/'
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_jboss__logging__syslog(title) }
  it { is_expected.to contain_jboss_confignode("/subsystem=logging/syslog-handler=#{title}") }
  it do
    is_expected.to contain_jboss__clientry("/subsystem=logging/syslog-handler=#{title}").
      with_ensure('present').
      with_properties(
        'port'           => 514,
        'app-name'       => 'test-app',
        'level'          => 'INFO',
        'server-address' => '127.0.0.1',
        'syslog-format'  => 'RFC5424'
      )
  end
end
