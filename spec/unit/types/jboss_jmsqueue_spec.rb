require "spec_helper"

describe 'jboss_jmsqueue', :type => :type do
    let(:described_class) { Puppet::Type.type(:jboss_jmsqueue) }
    subject { described_class }
    it { expect(subject).not_to be_nil }
    let(:ex_class) { if Puppet.version > '3.0.0' then Puppet::ResourceError else Puppet::Error end }

    def extend_params(given)
        {
            :title => 'spec-jmsqueue_spec'
        }.merge(given)
    end

    let(:type) { described_class.new(params) }

    describe 'controller' do
        context 'given :undef' do
            let(:params) { extend_params({ :controller => :undef }) }
            it do
                expect { type }.to raise_error(ex_class,
                'Parameter controller failed on Jboss_jmsqueue[spec-jmsqueue_spec]: Domain controller must be provided')
            end
        end
    end
end
