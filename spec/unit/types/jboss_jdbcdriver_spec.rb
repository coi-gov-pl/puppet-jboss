require 'spec_helper_puppet'

describe 'jboss_jdbcdriver', :type => :type do
  let(:described_class) { Puppet::Type.type(:jboss_jdbcdriver) }
  subject { described_class }
  it { expect(subject).not_to be_nil }

  describe 'controller == nil' do
    let(:params) do
      {
        :title      => 'test-driver',
        :controller => :undef
      }
    end
    subject { described_class.new(params) }

    it do
      expect { subject }.to raise_error(
        Puppet::Error,
        'Parameter controller failed on Jboss_jdbcdriver[test-driver]: Domain controller must be provided'
      )
    end
  end
end
