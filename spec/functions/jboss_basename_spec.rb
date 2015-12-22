require "spec_helper"

describe 'jboss_basename', :type => :puppet_function do

  describe 'input is a string and should return file' do
    let(:input) { 'path/to/file' }
    it do
      should run.
        with_params(input).and_return('file')
    end
  end

  describe 'input is an array and should return file and file2' do
    let(:input) { ['path/to/file', 'path/to/file2'] }
    it do
      should run.
        with_params(input).and_return(['file', 'file2'])
    end
  end
  
end
