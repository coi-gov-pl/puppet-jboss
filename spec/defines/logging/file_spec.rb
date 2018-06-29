require 'spec_helper_puppet'

describe 'jboss::logging::file', :type => :define do
  let(:title) { 'test-handler' }
  let(:facts) do
    {
      :osfamily        => 'RedHat',
      :operatingsystem => 'RedHat',
      :concat_basedir  => '/tmp/'
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_jboss__logging__file(title) }
  it { is_expected.to contain_jboss_confignode("/subsystem=logging/periodic-rotating-file-handler=#{title}") }
  it do
    is_expected.to contain_jboss__clientry("/subsystem=logging/periodic-rotating-file-handler=#{title}").
      with_ensure('present').
      with_properties(
        'level'     => 'INFO',
        'formatter' => '%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n',
        'suffix'    => '.yyyy-MM-dd',
        'file'      => {
          'relative-to' => 'jboss.server.log.dir',
          'path'        => 'server.log'
        }
      )
  end
end
