require 'spec_helper_puppet'

describe 'Fact jboss_fullconfig', :type => :fact do
  let(:sample_config) do
    t = Tempfile.new('rspec-jboss-fullconfig')
    path = t.path
    t.unlink
    path
  end
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
  let(:profile_d_content) { "export JBOSS_CONF=\'#{sample_config}\'" }
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
      'profile'     => 'full'
    }
  end
  before :all do
    Facter.clear
    configfile_fct = Facter.fact :jboss_configfile
    configfile_fct.instance_variable_set(:@value, nil)
  end
  before :each do
    Facter.clear
    expect(Puppet_X::Coi::Jboss::Configuration).to receive(:read_raw_profile_d).
      at_least(:once).and_return(profile_d_content)
    File.open(sample_config, 'w') { |f| f.write(sample_content) }
  end
  after :each do
    fct = Facter.fact :jboss_fullconfig
    fct.instance_variable_set(:@value, nil)
    configfile_fct = Facter.fact :jboss_configfile
    configfile_fct.instance_variable_set(:@value, nil)
    File.unlink(sample_config)
  end
  subject { Facter.value(:jboss_fullconfig) }
  shared_examples 'is not nill and empty' do
    it { expect(subject).not_to be_nil }
    it { expect(subject).not_to be_empty }
  end
  describe 'with sample config file for WildFly 8.2' do
    describe 'without mocking RUBY_VERSION' do
      it_behaves_like 'is not nill and empty'
      it { expect(subject).to respond_to(:[]) }
      its(:size) { should eq(10) }
      it { expect(subject).to eq(expected_hash) }
    end

    describe 'with mocking RUBY_VERSION to 1.8.7' do
      before :each do
        expect(Puppet_X::Coi::Jboss::Configuration).to receive(:ruby_version).
          at_least(:once).and_return('1.8.7')
      end

      it_behaves_like 'is not nill and empty'
      let(:subject_sorted) { eval(subject.to_s).to_a.sort }
      let(:expected_output) do
        [
          ['config', 'standalone-full.xml'],
          ['console_log', '/var/log/wildfly/console.log'],
          ['controller', '127.0.0.1:9990'],
          ['home', '/usr/lib/wildfly-12.2.0.Final'],
          %w[mode standalone],
          %w[product wildfly],
          %w[profile full],
          ['runasdomain', false],
          %w[user wildfly],
          ['version', '12.2.0.Final']
        ]
      end

      it { expect(subject_sorted).to eq(expected_output) }
    end
  end
end
