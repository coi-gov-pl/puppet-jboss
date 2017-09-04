require 'spec_helper_puppet'

describe 'jboss::logging::console', :type => :define do
  let(:title) { 'test-handler' }
  let(:pre_condition)  { "jboss::clientry { 'hornetq-server=default': profile => 'full', controller  => '127.0.0.1', runasdomain => true}" }
  let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

  it { is_expected.to compile }
  it { is_expected.to contain_jboss__logging__console(title) }
  it { is_expected.to contain_jboss_confignode("/subsystem=logging/console-handler=#{title}") }
  it do
    is_expected.to contain_jboss__clientry("/subsystem=logging/console-handler=#{title}").
      with_ensure('present').
      with_properties({
        'level'     => 'INFO',
        'target'    => 'System.out',
        'formatter' => '%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n',
      })
  end
end
