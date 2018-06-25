require 'spec_helper_puppet'

describe 'jboss::logging::root', :type => :define do
  let(:title) { 'test-handler' }
  let(:facts) do
    {
      :osfamily        => 'RedHat',
      :operatingsystem => 'RedHat',
      :concat_basedir  => '/tmp/'
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_jboss__logging__root(title) }
  it { is_expected.to contain_jboss_confignode("/subsystem=logging/root-logger=#{title}") }
  it do
    is_expected.to contain_jboss__clientry("/subsystem=logging/root-logger=#{title}").
      with_ensure('present').
      with_properties(
        'level'    => 'INFO',
        'handlers' => %w[CONSOLE FILE]
      )
  end
end
