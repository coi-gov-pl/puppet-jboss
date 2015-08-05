require 'spec_helper'

describe 'Fact jboss_fullconfig', :type => :fact do
  subject { Facter.value(:jboss_fullconfig) }
  let(:sample_config) { Dir::Tmpname.make_tmpname "/tmp/rspec-jboss-fullconfig", nil }
  let(:sample_content) do
    <<-eos
    # The Jboss home directory.
    #
    JBOSS_HOME=/usr/lib/wildfly-12.2.0.Final
    
    # The JBoss product name.
    #
    JBOSS_PRODUCT=wildfly
    
    # The JBoss version.
    #
    JBOSS_VERSION=12.2.0.Final
    
    # The JBoss configuration file
    #
    JBOSS_CONFIG=standalone-full.xml
    
    # The username who should own the process.
    #
    JBOSS_USER=wildfly
    
    # The amount of time to wait for startup
    #
    # STARTUP_WAIT=30
    
    # The amount of time to wait for shutdown
    #
    # SHUTDOWN_WAIT=30
    
    # Location to keep the console log
    #
    JBOSS_CONSOLE_LOG=/var/log/wildfly/console.log
    
    # Runs JBoss in domain mode?
    JBOSS_RUNASDOMAIN=false
    
    # JBoss running mode: domain or standalone
    JBOSS_MODE=standalone
    
    # Default JBoss domain controller
    JBOSS_CONTROLLER=127.0.0.1:9990
    
    # Default JBoss domain profile
    JBOSS_PROFILE=full
    eos
  end
  let(:expected_hash) do
    {
      'home'        => '/usr/lib/wildfly-12.2.0.Final',
      'product'     => 'wildfly',
      'version'     => '12.2.0.Final',
      'config'      => 'standalone-full.xml',
      'user'        => 'wildfly',
      'console_log' => '/var/log/wildfly/console.log',
      'runasdomain' => false,
      'mode'        => 'standalone',
      'controller'  => '127.0.0.1:9990',
      'profile'     => 'full',
    }
  end
  before :each do
    configfile_fct = Facter.fact :jboss_configfile
    configfile_fct.instance_variable_set(:@value, sample_config)
    File.write(sample_config, sample_content)
  end
  after :each do
    fct = Facter.fact :jboss_fullconfig
    fct.instance_variable_set(:@value, nil)
    configfile_fct = Facter.fact :jboss_configfile
    configfile_fct.instance_variable_set(:@value, nil)
    File.unlink(sample_config)
  end
  context "with sample config file for WildFly 8.2" do
    context 'return value' do
      it { expect(subject).not_to be_nil }
      it { expect(subject).not_to be_empty }
      it { expect(subject).to respond_to(:[]) }
      its(:size) { should eq(10) }
      it { expect(subject).to eq(expected_hash) }
    end
  end
end