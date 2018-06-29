require 'spec_helper_puppet'

describe 'jboss::logging::logger', :type => :define do
  let(:title) { 'test-handler' }
  let(:facts) do
    {
      :osfamily        => 'RedHat',
      :operatingsystem => 'RedHat',
      :concat_basedir  => '/tmp/'
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_jboss__logging__logger(title) }
  it { is_expected.to contain_jboss_confignode("/subsystem=logging/logger=#{title}") }
  it do
    is_expected.to contain_jboss__clientry("/subsystem=logging/logger=#{title}").
      with_ensure('present').
      with_properties(
        'level'               => 'INFO',
        'use-parent-handlers' => true
      )
  end
end
