require 'spec_helper_puppet'

describe 'jboss_initsystem' do
  subject { Facter.value(:jboss_initsystem) }
  before(:each) do
    Facter.clear
    expect(Facter).to receive(:value).with(:jboss_initsystem).and_call_original
  end
  after(:each) do
    Facter.clear
  end

  describe 'on systemD os linke Debian 8' do
    before(:each) do
      expect(Facter).to receive(:value).with(:osfamily).and_return('Debian')
      expect(Facter).to receive(:value).with(:operatingsystem).and_return('Debian')
      expect(Facter).to receive(:value).with(:operatingsystemrelease).and_return('8.0')
    end
    it { expect(subject).to eq('SystemD') }
  end
  describe 'on SysV os linke CentOS 6' do
    before(:each) do
      expect(Facter).to receive(:value).with(:osfamily).and_return('RedHat')
      expect(Facter).to receive(:value).with(:operatingsystem).and_return('CentOS')
      expect(Facter).to receive(:value).with(:operatingsystemrelease).and_return('6.0')
    end
    it { expect(subject).to eq('SystemV') }
  end
end
