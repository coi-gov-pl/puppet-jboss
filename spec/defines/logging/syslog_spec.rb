require 'spec_helper'

describe 'jboss::logging::syslog' do
  let(:title) { 'test-handler' }
  let(:params) { { :app_name => 'test-app', } }
  let(:facts) { {
    :osfamily => "RedHat",
    :operatingsystem => "RedHat",
    'jboss::profile' => "domain",
    'jboss::controller' => "controller.example.com",
    :concat_basedir => "/tmp/"
  } }

  it do should
    contain_jboss__clientry("/subsystem=logging/syslog-handler=#{title}").
      with_ensure('present').
      with_properties({
        'port' => 514,
        'app-name' => 'test_app',
        'level' => 'ALL',
        'enabled' => true,
        'server-address' => 'localhost',
        'syslog-format' => nil,
      })
  end

  it do should
    contain_jboss__clientry("/subsystem=logging/logger=#{title}").
      with_ensure('present').
      with_properties({
        'level' => "ALL",
        'handlers' => [ title ],
        'use-parent-handlers' => false,
      })
  end
end

