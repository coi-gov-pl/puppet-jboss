require 'spec_helper_puppet'

describe 'jboss::internal::service', :type => :class do
  shared_examples 'containg service anchors' do
    it { is_expected.to contain_anchor('jboss::service::begin') }
    it { is_expected.to contain_anchor('jboss::service::end') }
    it { is_expected.to contain_anchor('jboss::service::started') }
  end
  shared_examples 'containg class structure' do
    it { is_expected.to compile }
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::params') }
    it { is_expected.to contain_class('jboss::internal::configuration') }
  end
  shared_examples 'containg service restart exec' do
    it do
      is_expected.to contain_exec('jboss::service::restart').
        with(
          :command     => '/usr/lib/wildfly-9.0.2.Final/bin/restart.sh',
          :refreshonly => true,
          :logoutput   => true
        )
    end
  end
  shared_examples 'containg SystemD execs' do
    it do
      is_expected.to contain_exec('systemctl-daemon-reload-for-wildfly').
        with_command('/bin/systemctl daemon-reload')
    end
  end
  shared_examples 'as a valid Java-JBoss configuration' do
    it do
      is_expected.to contain_exec('jboss::service::test-running').
        with(
          :loglevel  => 'emerg',
          :command   => 'tail -n 200 /var/log/wildfly/console.log && exit 1',
          :unless    => "sleep 1 && pgrep -f 'java.*/usr/lib/wildfly-9.0.2.Final' > /dev/null",
          :logoutput => true
        )
    end
  end
  shared_examples 'as a invalid Java-JBoss configuration' do
    it do
      is_expected.to contain_exec('jboss::service::test-running').
        with(
          :loglevel  => 'warning',
          :command   => 'tail -n 200 /var/log/wildfly/console.log && exit 0',
          :unless    => "sleep 1 && pgrep -f 'java.*/usr/lib/wildfly-9.0.2.Final' > /dev/null",
          :logoutput => true
        )
    end
  end

  on_supported_os.each do |os, facts|
    describe "On #{os}" do
      initsystem = PuppetX::Coi::Jboss::Facts.calculate_initsystem(
        facts[:osfamily],
        facts[:operatingsystem],
        facts[:operatingsystemrelease]
      )
      describe 'in Docker container' do
        let(:jboss_virtual) { 'docker' }
        let(:facts) do
          raise Puppet::Error, 'Double check metadata.json suppoted OS\'s' if initsystem == :unsuppoted
          facts.merge(
            :concat_basedir   => '/root',
            :jboss_virtual    => jboss_virtual,
            :jboss_initsystem => initsystem
          )
        end
        it_behaves_like 'containg service anchors'
        it_behaves_like 'containg class structure'
        it_behaves_like 'containg service restart exec'
        if initsystem == :SystemD
          describe 'with SystemD enabled system' do
            it_behaves_like 'containg SystemD execs'
          end
        end
      end
      describe 'on non-Docker machine' do
        let(:jboss_virtual) { 'phisycal' }
        let(:facts) do
          raise Puppet::Error, 'Double check metadata.json suppoted OS\'s' if initsystem == :unsuppoted
          facts.merge(
            :concat_basedir   => '/root',
            :jboss_virtual    => jboss_virtual,
            :jboss_initsystem => initsystem
          )
        end
        it_behaves_like 'containg service anchors'
        it_behaves_like 'containg class structure'
        it_behaves_like 'containg service restart exec'
        if initsystem == :SystemD
          describe 'on SystemD enabled system' do
            it_behaves_like 'containg SystemD execs'
          end
        end
      end
    end
  end

  # describe 'on RedHat os family' do
  #   describe 'release 6.7' do
  #     let(:facts) do
  #       Testing::RspecPuppet::SharedFacts.oraclelinux_facts
  #     end
  #     it_behaves_like 'as a invalid Java-JBoss configuration'
  #   end
  #   describe 'release 7.4' do
  #     let(:facts) do
  #       Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
  #         :operatingsystemrelease    => '7.4',
  #         :operatingsystemmajrelease => '7'
  #       )
  #     end
  #     it_behaves_like 'as a valid Java-JBoss configuration'
  #   end
  #   describe 'on Docker container' do
  #     let(:facts) do
  #       Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
  #         :jboss_virtual => 'docker'
  #       )
  #     end
  #     it_behaves_like 'containg service anchors'
  #     it_behaves_like 'containg service restart exec'
  #     it_behaves_like 'containg class structure'
  #     it do
  #       is_expected.to contain_service('wildfly').
  #         with(
  #           :ensure     => 'running',
  #           :enable     => nil,
  #           :hasstatus  => true,
  #           :hasrestart => true
  #         )
  #     end
  #     describe 'on SystemD system' do
  #       let(:facts) do
  #         Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
  #           :jboss_virtual          => 'docker',
  #           :operatingsystemrelease => '7.1'
  #         )
  #       end
  #       it_behaves_like 'containg SystemD execs'
  #     end
  #   end
  #   describe 'on non-Docker machine' do
  #     let(:facts) do
  #       Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
  #         :jboss_virtual => 'phisycal'
  #       )
  #     end
  #     it_behaves_like 'containg service anchors'
  #     it_behaves_like 'containg service restart exec'
  #     it_behaves_like 'containg class structure'
  #     it do
  #       is_expected.to contain_service('wildfly').
  #         with(
  #           :ensure     => 'running',
  #           :enable     => true,
  #           :hasstatus  => true,
  #           :hasrestart => true
  #         )
  #     end
  #     describe 'on SystemD system' do
  #       let(:facts) do
  #         Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
  #           :jboss_virtual          => 'phisycal',
  #           :operatingsystemrelease => '7.1'
  #         )
  #       end
  #       it_behaves_like 'containg SystemD execs'
  #     end
  #   end
  # end

  # describe 'on Debian os family' do
  #   let(:facts) { Testing::RspecPuppet::SharedFacts.ubuntu_facts }
  #   it_behaves_like 'as a valid Java-JBoss configuration'
  #   describe 'on Docker container' do
  #     let(:facts) do
  #       Testing::RspecPuppet::SharedFacts.ubuntu_facts(
  #         :jboss_virtual => 'docker'
  #       )
  #     end
  #     it_behaves_like 'containg service anchors'
  #     it_behaves_like 'containg service restart exec'
  #     it_behaves_like 'containg class structure'
  #     it do
  #       is_expected.to contain_service('wildfly').
  #         with(
  #           :ensure     => 'running',
  #           :enable     => nil,
  #           :hasstatus  => true,
  #           :hasrestart => true
  #         )
  #     end
  #     describe 'on SystemD system' do
  #       let(:facts) do
  #         Testing::RspecPuppet::SharedFacts.ubuntu_facts(
  #           :jboss_virtual          => 'docker',
  #           :operatingsystem        => 'Debian',
  #           :operatingsystemrelease => '8'
  #         )
  #       end
  #       it_behaves_like 'containg SystemD execs'
  #     end
  #   end
  #   describe 'on non-Docker machine' do
  #     let(:facts) do
  #       Testing::RspecPuppet::SharedFacts.ubuntu_facts(
  #         :jboss_virtual => 'vmware'
  #       )
  #     end
  #     it_behaves_like 'containg service anchors'
  #     it_behaves_like 'containg service restart exec'
  #     it_behaves_like 'containg class structure'
  #     it do
  #       is_expected.to contain_service('wildfly').
  #         with(
  #           :ensure     => 'running',
  #           :enable     => true,
  #           :hasstatus  => true,
  #           :hasrestart => true
  #         )
  #     end
  #     describe 'on SystemD system' do
  #       let(:facts) do
  #         Testing::RspecPuppet::SharedFacts.ubuntu_facts(
  #           :jboss_virtual          => 'vmware',
  #           :operatingsystemrelease => '16.04'
  #         )
  #       end
  #       it_behaves_like 'containg SystemD execs'
  #     end
  #   end
  # end
end
