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
      it do
        expect { type }.to raise_error(ex_class,
          'Parameter port failed on Jboss_datasource[spec-datasource]: Datasource port is invalid, given "5x45"')
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
      let(:params) { extend_params({ :host => "an invalid host" }) }
      it do
        expect { type }.to raise_error(ex_class,
          'Parameter host failed on Jboss_datasource[spec-datasource]: Datasource host is invalid, given "an invalid host"')
      end
    end
    context 'given "node-01.example.org"' do
      let(:params) { extend_params({ :host => "node-01.example.org" }) }
      it { expect { type }.not_to raise_error }
    end
    context 'given "192.168.16.2"' do
      let(:params) { extend_params({ :host => "192.168.16.2" }) }
      it { expect { type }.not_to raise_error }
    end
    context 'given "fe80::250:56ff:fec0:8"' do
      let(:params) { extend_params({ :host => "fe80::250:56ff:fec0:8" }) }
      it { expect { type }.not_to raise_error }
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
      let(:options) { "an invalid text" }
      it do
        expect { type }.to raise_error(ex_class,
          'Parameter options failed on Jboss_datasource[spec-datasource]: You can pass only hash-like objects or absent and undef values, given "an invalid text"')
      end
    end
    context 'given invalid boolean' do
      let(:options) { true }
      it do
        expect { type }.to raise_error(ex_class,
          'Parameter options failed on Jboss_datasource[spec-datasource]: You can pass only hash-like objects or absent and undef values, given true')
      end
    end
    context 'display changes via change_to_s(from, to) using' do
      let(:options) { {} }
      subject { type.property(:options).change_to_s(from, to) }
      context 'from :absent and to hash', :from => :absent, :to => { 'alice' => 'five', 'bob' => 'seven' } do
        let(:from) { |expl| expl.metadata[:from] }
        let(:to) { |expl| expl.metadata[:to] }
        it { expect(subject).to eq("option 'alice' has been set to \"five\", option 'bob' has been set to \"seven\"") }
      end
      context 'from hash and to changed hash', :from => { 'alice' => 'five', 'bob' => 'nine' }, :to => { 'alice' => 'five', 'bob' => 'seven' } do
        let(:from) { |expl| expl.metadata[:from] }
        let(:to) { |expl| expl.metadata[:to] }
        it { expect(subject).to eq("option 'bob' has changed from \"nine\" to \"seven\"") }
      end
      context 'from hash and to :absent', :from => { 'alice' => 'five', 'bob' => 'nine' }, :to => :absent do
        let(:from) { |expl| expl.metadata[:from] }
        let(:to) { |expl| expl.metadata[:to] }
        it { expect(subject).to eq('option \'alice\' was "five" and has been removed, option \'bob\' was "nine" and has been removed') }
      end
    end

    context 'munge new values using' do
      let(:options) { {} }
      subject { type.property(:options).munge(new_values) }
      context 'regular hash' do
        let(:new_values) { { 'alice' => 'five', 'bob' => 'seven' } }
        it { expect(subject).to eq({ 'alice' => 'five', 'bob' => 'seven' }) }
      end
      context 'hash with :undef\'s' do
        let(:new_values) { { 'alice' => :undef, 'bob' => 'seven' } }
        it { expect(subject).to eq({ 'alice' => nil, 'bob' => 'seven' }) }
      end
      context 'an :undef\'s' do
        let(:new_values) { :undef }
        it { expect(subject).to eq(:undef) }
      end
    end
  end

end
