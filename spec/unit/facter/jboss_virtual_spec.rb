require 'spec_helper_puppet'

describe 'jboss_virtual', :type => :fact do
  let(:lines) do
    lines = <<-EOS
    11:name=systemd:/
    10:hugetlb:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    9:perf_event:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    8:blkio:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    7:freezer:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    6:devices:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    5:memory:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    4:cpuacct:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    3:cpu:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    2:cpuset:/docker/715a4a76b43c6d67a4900f2cd3f718191671c19b09699c0a16a4fbc48bc69004
    EOS
    lines.split(/\n/)
  end
  let(:docker_pathname) { double(:readable? => true, :readlines => lines) }
  let(:nondocker_pathname) { double(:readable? => true, :readlines => []) }
  before(:each) do
    expect(Facter).to receive(:value).with(:jboss_virtual).and_call_original
    expect(Facter).to receive(:value).with(:virtual).and_return('physical')
  end
  after :each do
    fct = Facter.fact :jboss_virtual
    fct.instance_variable_set(:@value, nil)
  end
  subject { Facter.value(:jboss_virtual) }
  describe 'on Docker container' do
    before(:each) do
      allow(Pathname).to receive(:new).and_call_original
      allow(Pathname).to receive(:new).with('/proc/1/cgroup').and_return(docker_pathname)
    end
    it { expect { subject }.not_to raise_error }
    it { expect(subject).to eq('docker') }
  end
  describe 'on non-Docker machine' do
    before(:each) do
      allow(Pathname).to receive(:new).and_call_original
      allow(Pathname).to receive(:new).with('/proc/1/cgroup').and_return(nondocker_pathname)
    end
    it { expect { subject }.not_to raise_error }
    it { expect(subject).to eq('physical') }
  end
end
