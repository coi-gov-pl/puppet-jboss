require 'spec_helper_puppet'

describe 'jboss::internal::service', :type => :class do
  shared_examples 'containg service anchors' do
    it { is_expected.to contain_anchor('jboss::service::begin') }
    it { is_expected.to contain_anchor('jboss::service::end') }
    it { is_expected.to contain_anchor('jboss::service::started') }
  end
  shared_examples 'containg class structure' do
    it { is_expected.to contain_class 'jboss::internal::service' }
    it { is_expected.to contain_class('jboss') }
    it { is_expected.to contain_class('jboss::params') }
    it { is_expected.to contain_class('jboss::internal::configuration') }
  end
  shared_examples 'containg service restart exec' do
    it do
      is_expected.to contain_exec('jboss::service::restart').
      with(
        :command     => "service wildfly stop ; sleep 5 ; pkill -9 -f '^java.*wildfly' ; service wildfly start",
        :refreshonly => true
      )
    end
  end
  shared_examples 'containg SystemD execs' do
    it do
      is_expected.to contain_exec('jboss::service::test-running').
      with(
        :loglevel  => 'emerg',
        :command   => 'tail -n 80 /var/log/wildfly/console.log && exit 1',
        :unless    => "pgrep -f '^java.*wildfly' > /dev/null",
        :logoutput => true
      )
    end
    it do
      is_expected.to contain_exec('systemctl-daemon-reload-for-wildfly').
      with_command("/bin/systemctl daemon-reload")
    end
  end
  shared_examples 'containg SystemV execs' do
    it do
      is_expected.to contain_exec('jboss::service::test-running').
      with(
        :loglevel  => 'warning',
        :command   => 'tail -n 80 /var/log/wildfly/console.log && exit 0',
        :unless    => "pgrep -f '^java.*wildfly' > /dev/null",
        :logoutput => true
      )
    end
  end

  context 'on RedHat os family' do
    context 'on Docker container' do
      let(:facts) do
        Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
          :virtual       => 'docker'
        )
      end
      it_behaves_like 'containg service anchors'
      it_behaves_like 'containg service restart exec'
      it_behaves_like 'containg SystemV execs'
      it_behaves_like 'containg class structure'
      it do
        is_expected.to contain_service('wildfly').
        with(
          :ensure     => 'running',
          :enable     => nil,
          :hasstatus  => true,
          :hasrestart => true
        )
      end
      context 'on SystemD system' do
        let(:facts) do
          Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
            :jboss_virtual          => 'docker',
            :operatingsystemrelease => '7.1'
          )
        end
        it_behaves_like 'containg SystemD execs'
      end
    end
    context 'on non-Docker machine' do
      let(:facts) do
        Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
          :jboss_virtual => 'phisycal'
        )
      end
      it_behaves_like 'containg service anchors'
      it_behaves_like 'containg service restart exec'
      it_behaves_like 'containg SystemV execs'
      it_behaves_like 'containg class structure'
      it do
        is_expected.to contain_service('wildfly').
        with(
          :ensure     => 'running',
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true
        )
      end
      context 'on SystemD system' do
        let(:facts) do
          Testing::RspecPuppet::SharedFacts.oraclelinux_facts(
            :jboss_virtual          => 'phisycal',
            :operatingsystemrelease => '7.1'
          )
        end
        it_behaves_like 'containg SystemD execs'
      end
    end
  end

  context 'on Debian os family' do
    context 'on Docker container' do
      let(:facts) do
        Testing::RspecPuppet::SharedFacts.ubuntu_facts(
          :virtual       => 'docker'
        )
      end
      it_behaves_like 'containg service anchors'
      it_behaves_like 'containg service restart exec'
      it_behaves_like 'containg SystemV execs'
      it_behaves_like 'containg class structure'
      it do
        is_expected.to contain_service('wildfly').
        with(
          :ensure     => 'running',
          :enable     => nil,
          :hasstatus  => true,
          :hasrestart => true
        )
      end
      context 'on SystemD system' do
        let(:facts) do
          Testing::RspecPuppet::SharedFacts.ubuntu_facts(
            :jboss_virtual          => 'docker',
            :operatingsystem        => 'Debian',
            :operatingsystemrelease => '8'
          )
        end
        it_behaves_like 'containg SystemD execs'
      end
    end
    context 'on non-Docker machine' do
      let(:facts) do
        Testing::RspecPuppet::SharedFacts.ubuntu_facts(
          :jboss_virtual => 'vmware'
        )
      end
      it_behaves_like 'containg service anchors'
      it_behaves_like 'containg service restart exec'
      it_behaves_like 'containg SystemV execs'
      it_behaves_like 'containg class structure'
      it do
        is_expected.to contain_service('wildfly').
        with(
          :ensure     => 'running',
          :enable     => true,
          :hasstatus  => true,
          :hasrestart => true
        )
      end
      context 'on SystemD system' do
        let(:facts) do
          Testing::RspecPuppet::SharedFacts.ubuntu_facts(
            :jboss_virtual          => 'vmware',
            :operatingsystemrelease => '16.04'
          )
        end
        it_behaves_like 'containg SystemD execs'
      end
    end
  end
end
