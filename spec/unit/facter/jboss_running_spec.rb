require 'spec_helper'

describe 'jboss_running' do
  subject { Facter.value(:jboss_running) }
  before :all do
    Facter.clear
  end
  before :each do
    Puppet_X::Coi::Jboss::Facts.define_jboss_running_fact
    Facter.fact(:jboss_running).flush
  end
  context 'without mocking anything' do
    it { expect { subject }.not_to raise_error }
    it { expect(subject).to be_falsy }
  end
  context 'with mocking' do
    let(:tmpdir) { Dir.mktmpdir }
    before :each do
      expect(Puppet_X::Coi::Jboss::Facts).to receive(:system_processes_commandline)
        .at_least(:once).and_return("#{tmpdir}/[0-9]*/cmdline")
    end
    after :each do
      FileUtils.remove_entry(tmpdir)
    end

    context 'JBoss process' do
      before :each do
        piddir = "#{tmpdir}/12334"
        FileUtils.mkdir_p(piddir)
        File.write("#{piddir}/cmdline", '/usr/bin/java -Xmx512m -server -Xms128m org.jboss.as.webserver')
      end
      it { expect { subject }.not_to raise_error }
      it { expect(subject).to be_truthy }
    end
    context 'Wildfly process' do
      before :each do
        piddir = "#{tmpdir}/3244"
        FileUtils.mkdir_p(piddir)
        File.write("#{piddir}/cmdline", '/usr/bin/java -server org.wildfly.undertow')
      end
      it { expect { subject }.not_to raise_error }
      it { expect(subject).to be_truthy }
    end
  end
end
