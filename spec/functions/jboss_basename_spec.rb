require "spec_helper"

describe 'jboss_basename', :type => :puppet_function do

    let(:input) { 'path/to/file' }
    it do
      should run.
        with_params(input).and_return('file')
    end

    let(:input2) { ['path/to/file', 'path/to/file2'] }
    it do
      should run.
        with_params(input2).and_return(['file', 'file2'])
    end

end
