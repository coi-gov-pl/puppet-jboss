require 'spec_helper_puppet'

describe 'jboss::logging::async', :type => :define do
  let(:title) { 'test-handler' }
  let(:pre_condition)  { "jboss::clientry { 'hornetq-server=default': profile => 'full', controller  => '127.0.0.1', runasdomain => true}" }
  let(:facts) { Testing::RspecPuppet::SharedFacts.oraclelinux_facts }

    it { is_expected.to compile }
    it { is_expected.to contain_jboss__logging__async(title) }
    it { is_expected.to contain_jboss_confignode("/subsystem=logging/async-handler=#{title}") }
    it do
      is_expected.to contain_jboss__clientry("/subsystem=logging/async-handler=#{title}").
        with_ensure('present').
        with_properties({
          'level'           => 'INFO',
          'formatter'       => '%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n',
          'subhandlers'     => [ 'CONSOLE', 'FILE' ],
          'overflow-action' => 'BLOCK',
          'queue-length'    => '1024',
        })
  end
end
