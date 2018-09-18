require 'spec_helper_puppet'

describe PuppetX::Coi::Jboss::Provider::AbstractJbossCli do
  let(:resource) { double }
  let(:provider) { described_class.new(resource) }
end
