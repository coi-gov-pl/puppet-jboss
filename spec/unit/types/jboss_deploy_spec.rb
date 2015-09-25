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
  let(:params) { extend_params({}) }
  it { expect(type).not_to be_nil }

end