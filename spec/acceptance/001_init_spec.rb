require 'spec_helper_acceptance'

describe 'jboss class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  describe 'executing with defaults' do
    
    pp = <<-eos
    class { 'jboss': }
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
    describe service('wildfly') do 
      it { should be_running }
    end
    
  end
end