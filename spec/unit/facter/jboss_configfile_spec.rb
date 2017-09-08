require 'spec_helper'

describe 'Fact jboss_configfile' do
  subject { Facter.value(:jboss_configfile) }
  let(:sample_config) { '/etc/jboss-eap/jboss-eap.conf' }
  let(:sample_content) { "export JBOSS_CONF='#{sample_config}'" }
  let(:path) { '/etc/profile.d/jboss.sh' }
  before :all do
    Puppet_X::Coi::Jboss::Facts.define_configfile_fact
  end
  before :each do
    expect(File).to receive(:read).with(path).and_return(sample_content)
  end
  after :each do
    fct = Facter.fact(:jboss_configfile)
    fct.flush
  end
  context "with sample file \"export JBOSS_CONF='/etc/jboss-eap/jboss-eap.conf'\"" do
    it { expect(subject).to eq(sample_config) }
  end
end
