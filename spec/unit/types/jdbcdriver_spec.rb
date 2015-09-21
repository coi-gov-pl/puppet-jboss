require 'spec_helper'

describe 'jboss_jdbcdriver', :type => :type do
  it { expect('').to be_empty }
  let(:described_class) { Puppet::Type.type(:jboss_jdbcdriver) }
  subject { described_class }
  it { expect(subject).not_to be_nil }

  context 'controller == nil' do
    let(:params) do
      {
        :title      => 'test-driver',
        :controller => :undef
      }
    end
    subject { described_class.new(params) }

    it do
      expect { subject }.to raise_error(Puppet::ResourceError, 
        'Parameter controller failed on Jboss_jdbcdriver[test-driver]: Domain controller must be provided')
    end
  end
end