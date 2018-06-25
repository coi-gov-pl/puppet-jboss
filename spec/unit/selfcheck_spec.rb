require 'spec_helper_puppet'

describe 'selfcheck' do
  class SelfCheck
    def test(motd = false)
      value = File.read '/etc/passwd'
      value = File.read '/etc/motd' if motd
      value
    end
  end

  it { expect(subject).to eq 'selfcheck' }
  it 'returns :rspec' do
    expect(RSpec.configuration.mock_framework.framework_name).to eq(:rspec)
  end

  describe 'validate mocks' do
    before(:each) do
      expect(File).to receive(:read).with('/etc/passwd').and_return(
        'secret'
      )
      allow(File).to receive(:read).with('/etc/motd').and_raise('Access denied')
    end
    let(:instance) { SelfCheck.new }
    subject { instance.test(motd) }

    describe 'on motd' do
      let(:motd) { true }
      it { expect { subject }.to raise_error(/Access denied/) }
    end
    describe 'on passwd' do
      let(:motd) { false }
      it { is_expected.to eq 'secret' }
    end
  end
end
