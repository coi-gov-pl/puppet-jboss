require 'spec_helper'

describe 'jboss_datasource', :type => :type do
  let(:described_class) { Puppet::Type.type(:jboss_datasource) }
  subject { described_class }
  it { expect(subject).not_to be_nil }
  let(:ex_class) { if Puppet.version > '3.0.0' then Puppet::ResourceError else Puppet::Error end }

  def extend_params(given)
    {
      :title => 'spec-datasource'
    }.merge(given)
  end

  let(:type) { described_class.new(params) }

  describe 'controller' do
    context 'given :undef' do
      let(:params) { extend_params({ :controller => :undef }) }
      it do
        expect { type }.to raise_error(ex_class, 
          'Parameter controller failed on Jboss_datasource[spec-datasource]: Domain controller must be provided')
      end
    end
  end

  describe 'port' do
    context 'given invalid text' do
      let(:params) { extend_params({ :port => "an invalid port" }) }
      it do
        expect { type }.to raise_error(ex_class, 
          'Parameter port failed on Jboss_datasource[spec-datasource]: Datasource port is invalid, given "an invalid port"')
      end
    end
    context 'given "5x45"' do
      let(:params) { extend_params({ :port => "5x45" }) }
      before { skip('FIXME: A buggy host validation, ref: coi-gov-pl/puppet-jboss#8') }
      it do
        expect { type }.to raise_error(ex_class, 
          'Parameter port failed on Jboss_datasource[spec-datasource]: Datasource port is invalid, given "an invalid port"')
      end
    end
    context 'property :port' do
      subject { type.property :port }
      context 'given as "7778"' do
        let(:params) { extend_params({ :port => "7778" }) }
        its(:value) { should == 7778 }
      end
      context 'given as ""' do
        let(:params) { extend_params({ :port => "" }) }
        its(:value) { should == 0 }
      end
    end
  end

  describe 'host' do
    context 'given invalid text " "' do
      let(:params) { extend_params({ :host => ' ' }) }
      it do
        expect { type }.to raise_error(ex_class, 
          'Parameter host failed on Jboss_datasource[spec-datasource]: Datasource host is invalid, given " "')
      end
    end
    context 'given "an invalid host"' do
      before { skip('FIXME: A buggy host validation, ref: coi-gov-pl/puppet-jboss#8') }
      let(:params) { extend_params({ :host => "an invalid host" }) }
      it do
        expect { type }.to raise_error(ex_class, 
          'Parameter host failed on Jboss_datasource[spec-datasource]: Datasource host is invalid, given "an invalid host"')
      end
    end
  end

  describe 'minpoolsize' do
    subject { type.property :minpoolsize }
    context 'given invalid text' do
      let(:params) { extend_params({ :minpoolsize => "an invalid text" }) }
      its(:value) { should == 1 }
    end
    context 'given 13.45' do
      let(:params) { extend_params({ :minpoolsize => 13.45 }) }
      its(:value) { should == 13 }
    end
    context 'given :undef' do
      let(:params) { extend_params({ :minpoolsize => :undef }) }
      its(:value) { should == 1 }
    end
    context 'given "17"' do
      let(:params) { extend_params({ :minpoolsize => '17' }) }
      its(:value) { should == 17 }
    end
  end

  describe 'maxpoolsize' do
    subject { type.property :maxpoolsize }
    context 'given invalid text' do
      let(:params) { extend_params({ :maxpoolsize => "an invalid text" }) }
      its(:value) { should == 50 }
    end
    context 'given 13.45' do
      let(:params) { extend_params({ :maxpoolsize => 13.45 }) }
      its(:value) { should == 13 }
    end
    context 'given :undef' do
      let(:params) { extend_params({ :maxpoolsize => :undef }) }
      its(:value) { should == 50 }
    end
    context 'given "17"' do
      let(:params) { extend_params({ :maxpoolsize => '17' }) }
      its(:value) { should == 17 }
    end
  end

  describe 'password' do
    let(:params) { extend_params({ :password => "an invalid text" }) }
    let(:expected_message) { 'password has been changed.' }
    subject { type.property(:password).change_to_s(from, to) }
    context 'change_to_s' do
      context ':absent, "test-passwd"' do
        let(:from) { :absent }
        let(:to) { 'test-passwd' }
        it { expect(subject).to eq(expected_message) }
      end
      context '"test-passwd", :absent' do
        let(:from) { 'test-passwd' }
        let(:to) { :absent }
        it { expect(subject).to eq(expected_message) }
      end
    end
  end

  describe 'options' do
    let(:params) do
      extend_params({
        :options => options
      })
    end
    context 'given invalid text' do
      before { skip('FIXME: String should not be accepted as a parameter, ref: coi-gov-pl/puppet-jboss#9')}
      let(:options) { "an invalid text" }
      it do
        expect { type }.to raise_error(ex_class,
          'Parameter options failed on Jboss_datasource[spec-datasource]: You can pass only hash-like objects')
      end
    end
    context 'given invalid boolean' do
      let(:options) { true }
      it do
        expect { type }.to raise_error(ex_class,
          'Parameter options failed on Jboss_datasource[spec-datasource]: You can pass only hash-like objects')
      end
    end
    context 'given' do
      let(:options) { {} }
      subject { type.property(:options).change_to_s(from, to) }
      context 'from :absent and to hash', :from => :absent, :to => { 'alice' => 'five', 'bob' => 'seven' } do
        before do
          msg = 'FIXME: Handle :symbols as parameters in change_to_s, ref: coi-gov-pl/puppet-jboss#9'
          skip(msg) if RUBY_VERSION < '1.9.0'
        end
        let(:from) { |expl| expl.metadata[:from] }
        let(:to) { |expl| expl.metadata[:to] }
        it { expect(subject).to eq("option 'alice' has changed from nil to \"five\", option 'bob' has changed from nil to \"seven\"") }
      end
      context 'from hash and to changed hash', :from => { 'alice' => 'five', 'bob' => 'nine' }, :to => { 'alice' => 'five', 'bob' => 'seven' } do
        let(:from) { |expl| expl.metadata[:from] }
        let(:to) { |expl| expl.metadata[:to] }
        it { expect(subject).to eq("option 'bob' has changed from \"nine\" to \"seven\"") }
      end
      context 'from hash and to :absent', :from => { 'alice' => 'five', 'bob' => 'nine' }, :to => :absent do
        before { skip('FIXME: A proper message while executing change_to_s for :to == :absent, ref: coi-gov-pl/puppet-jboss#9')}
        let(:from) { |expl| expl.metadata[:from] }
        let(:to) { |expl| expl.metadata[:to] }
        it { expect(subject).to eq('options has been removed') }
      end
    end
  end

end