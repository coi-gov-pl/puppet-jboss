require 'spec_helper_puppet'

describe 'jboss_dirname', :type => :puppet_function do
  let(:input) { 'path/to/file' }
  it do
    should run.
      with_params(input).and_return('path/to')
  end

  let(:input2) { ['path/to/file', 'path/to/file2'] }
  it do
    should run.
      with_params(input2).and_return(['path/to', 'path/to'])
  end
end
