require 'spec_helper_puppet'

describe 'jboss_resourceadapter', :type => :type do
  let(:described_class) { Puppet::Type.type(:jboss_resourceadapter) }
  subject { described_class }
  it { expect(subject).not_to be_nil }

  def extend_params(given)
    { :title => 'spec-resourceadapter_spec' }.merge(given)
  end

  let(:type) { described_class.new(params) }

  describe 'controler' do
    describe 'given :undef' do
      let(:params) { extend_params(:controller => :undef) }
      it do
        expect { type }.to raise_error(
          Puppet::Error,
          'Parameter controller failed on Jboss_resourceadapter[spec-resourceadapter_spec]: Domain controller must be provided'
        )
      end
    end
  end
end
