require 'spec_helper_puppet'

describe 'jboss_deploy', :type => :type do
  let(:described_class) { Puppet::Type.type(:jboss_deploy) }
  subject { described_class }
  it { expect(subject).not_to be_nil }

  def extend_params(given)
    {
      :title => 'spec-artifact'
    }.merge(given)
  end

  let(:type) { described_class.new(params) }

  describe 'no parameters given' do
    let(:params) { extend_params({}) }
    it { expect(type).not_to be_nil }
  end

  describe 'controler' do
    describe 'given :undef' do
      let(:params) { extend_params({ :controller => :undef }) }
      it do
        expect { type }.to raise_error(
          Puppet::Error,
          'Parameter controller failed on Jboss_deploy[spec-artifact]: Domain controller must be provided'
        )
      end
    end
  end

  describe ':runtime_name' do
    describe 'given invalid input' do
      let(:params) { extend_params(:runtime_name => 'not_valid_runtime_name') }
      it do
        expect { type }.to raise_error(
          Puppet::Error,
          'Parameter runtime_name failed on Jboss_deploy[spec-artifact]: Invalid file extension, module only' \
          ' supports: .jar, .war, .ear, .rar'
        )
      end
    end
  end
end
