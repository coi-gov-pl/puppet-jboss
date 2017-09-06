require 'spec_helper'

describe 'jboss_running', :type => :fact do
  subject { Facter.value(:jboss_running) }
  it { expect { subject }.not_to raise_error }
  it { expect(subject).to match('true|false') }
end
