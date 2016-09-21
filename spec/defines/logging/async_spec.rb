require 'spec_helper_puppet'

describe 'jboss::logging::async', :type => :define do
  let(:title) { 'test-handler' }
  let(:facts) { {
    :osfamily        => "RedHat",
    :operatingsystem => "RedHat",
    :concat_basedir  => "/tmp/"
  } }

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
