require 'spec_helper_puppet'

describe 'Fact jboss_configfile', :type => :fact do
  subject { Facter.value(:jboss_configfile) }
  let(:sample_config) { '/etc/jboss-eap/jboss-eap.conf' }
  let(:sample_content) { "export JBOSS_CONF='#{sample_config}'" }
  let(:path) { '/etc/profile.d/jboss.sh' }
  before :each do
    expect(File).to receive(:read).with(path).and_return(sample_content)
  end
  after :each do
    fct = Facter.fact :jboss_configfile
    fct.instance_variable_set(:@value, nil)
  end
  context "with sample file \"export JBOSS_CONF='/etc/jboss-eap/jboss-eap.conf'\"" do
    it { expect(subject).to eq(sample_config) }
  end
end
