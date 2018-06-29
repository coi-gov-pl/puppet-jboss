require 'spec_helper_puppet'

describe 'jboss_jmsqueue', :type => :type do
  let(:described_class) { Puppet::Type.type(:jboss_jmsqueue) }
  subject { described_class }
  it { expect(subject).not_to be_nil }
  let(:ex_class) { Puppet.version > '3.0.0' ? Puppet::ResourceError : Puppet::Error }

  def extend_params(given)
    { :title => 'spec-jmsqueue_spec' }.merge(given)
  end

  let(:type) { described_class.new(params) }

  describe 'controller' do
    describe 'given :undef' do
      let(:params) { extend_params({ :controller => :undef }) }
      it do
        expect { type }.to raise_error(
          ex_class,
          'Parameter controller failed on Jboss_jmsqueue[spec-jmsqueue_spec]: Domain controller must be provided'
        )
      end
    end
  end

  describe 'entries' do
    describe 'is_to_s' do
      let(:entries) { ['queue/app-mails', 'java:jboss/exported/jms/queue/app-mails'] }
      let(:params) { extend_params({ :entries => entries }) }
      let(:property) { type.property(:entries) }
      it do
        expect(property.is_to_s(entries)).to eq('["queue/app-mails", "java:jboss/exported/jms/queue/app-mails"]')
      end
    end
    describe 'should_to_s' do
      let(:entries) { ['queue/app-mails', 'java:jboss/exported/jms/queue/app-mails'] }
      let(:params) { extend_params({ :entries => entries }) }
      let(:property) { type.property(:entries) }
      it do
        expect(property.should_to_s(entries)).to eq('["queue/app-mails", "java:jboss/exported/jms/queue/app-mails"]')
      end
    end
  end
end
