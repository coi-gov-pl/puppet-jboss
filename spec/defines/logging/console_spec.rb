require 'spec_helper_puppet'

describe 'jboss::logging::console', :type => :define do
  let(:title) { 'test-handler' }
  let(:facts) do
    {
      :osfamily        => 'RedHat',
      :operatingsystem => 'RedHat',
      :concat_basedir  => '/tmp/'
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_jboss__logging__console(title) }
  it { is_expected.to contain_jboss_confignode("/subsystem=logging/console-handler=#{title}") }
  it do
    is_expected.to contain_jboss__clientry("/subsystem=logging/console-handler=#{title}").
      with_ensure('present').
      with_properties(
        'level'     => 'INFO',
        'target'    => 'System.out',
        'formatter' => '%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n'
      )
  end
end
