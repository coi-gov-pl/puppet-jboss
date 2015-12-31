require 'spec_helper'

describe 'jboss_deploy', :type => :type do
  let(:described_class) { Puppet::Type.type(:jboss_deploy) }
  subject { described_class }
  it { expect(subject).not_to be_nil }
  let(:ex_class) { if Puppet.version > '3.0.0' then Puppet::ResourceError else Puppet::Error end }

  def extend_params(given)
    {
      :title => 'spec-artifact'
    }.merge(given)
  end

  let(:type) { described_class.new(params) }

  context 'no parameters given' do
    let(:params) { extend_params({}) }
    it { expect(type).not_to be_nil }
  end

  describe 'controler' do
    context 'given :undef' do
      let(:params) { extend_params({ :controller => :undef }) }
      it do
        expect { type }.to raise_error(ex_class,
          'Parameter controller failed on Jboss_deploy[spec-artifact]: Domain controller must be provided')
        end
    end
  end

end
