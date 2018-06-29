require 'spec_helper_puppet'

describe Puppet_X::Coi::Jboss::Provider::SecurityDomain::AbstractProvider do
  let(:instance) { described_class.new }
  let(:message) { /Abstract class, implement this method/ }
  describe '#correct_command_template_begining' do
    subject { instance.send(:correct_command_template_begining, 'sample') }
    it { expect { subject }.to raise_error(ArgumentError) }
  end
  describe '#correct_command_template_ending' do
    subject { instance.send(:correct_command_template_ending) }
    it { expect { subject }.to raise_error(ArgumentError) }
  end
  describe '#module_option_template' do
    subject { instance.send(:module_option_template) }
    it { expect { subject }.to raise_error(ArgumentError) }
  end
end
