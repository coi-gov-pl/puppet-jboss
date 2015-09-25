require 'spec_helper'

describe 'jboss_confignode', :type => :type do
  let(:described_class) { Puppet::Type.type(:jboss_confignode) }
  subject { described_class }
  let(:ex_class) { if Puppet.version > '3.0.0' then Puppet::ResourceError else Puppet::Error end }

  def extend_params(given)
    {
      :title => '/sybsystem=datasources'
    }.merge(given)
  end

  let(:type) { described_class.new(params) }
  let(:params) { extend_params({}) }
  describe 'new type with title == /sybsystem=datasources' do
    it { expect(type).not_to be_nil }
    describe 'controller == :undef' do
      let(:params) { extend_params({ :controller => :undef }) }
      it { expect { type }.to raise_error(ex_class, 'Parameter controller failed on Jboss_confignode[/sybsystem=datasources]: Domain controller must be provided') }
    end

    describe 'properties' do
      let(:params) { extend_params({ :properties => properties }) }
      describe 'munge' do
        context 'not respond_to? :[]' do
          let(:properties) { false }
          subject { type.property :properties }
          its(:value) { is_expected.to eq({}) }
        end
        context 'respond_to? :[]' do
          let(:properties) { {'example' => false} }
          subject { type.property :properties }
          its(:value) { is_expected.to eq(properties) }
        end
      end
      
      describe 'change_to_s' do
        let(:properties) { false }
        subject { type.property(:properties).change_to_s(from, to) }
        context 'from :absent and to hash', :from => :absent, :to => { 'alice' => 'five', 'bob' => 'seven' } do
          let(:from) { |expl| expl.metadata[:from] }
          let(:to) { |expl| expl.metadata[:to] }
          it { expect(subject).to eq("property 'alice' has been changed from nil to \"five\", property 'bob' has been changed from nil to \"seven\"") }
        end
        context 'from hash and to changed hash', :from => { 'alice' => 'five', 'bob' => 'nine' }, :to => { 'alice' => 'five', 'bob' => 'seven' } do
          let(:from) { |expl| expl.metadata[:from] }
          let(:to) { |expl| expl.metadata[:to] }
          it { expect(subject).to eq("property 'bob' has been changed from \"nine\" to \"seven\"") }
        end
        context 'from hash and to :absent', :from => { 'alice' => 'five', 'bob' => 'nine' }, :to => :absent do
          before { skip('FIXME: A proper message while executing change_to_s for :to == :absent, ref: coi-gov-pl/puppet-jboss#9')}
          let(:from) { |expl| expl.metadata[:from] }
          let(:to) { |expl| expl.metadata[:to] }
          it { expect(subject).to eq('properties has been removed') }
        end
      end
    end
  end

end
