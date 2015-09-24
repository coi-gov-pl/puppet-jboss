require 'spec_helper'

describe 'jboss_to_s', :type => :puppet_function do
  it 'should throw Puppet::ParseError if passing 0 args' do
    should run.
      with_params().and_raise_error(
        Puppet::ParseError, 
        'jboss_to_s(): Wrong number of arguments given (0 for 1)'
      )
  end
  
  it 'should throw Puppet::ParseError if passing 2 args' do
    should run.
      with_params(1, true).and_raise_error(
        Puppet::ParseError, 
        'jboss_to_s(): Wrong number of arguments given (2 for 1)'
      )
  end
  
  it 'should return "true" if passing true' do
    should run.with_params(true).and_return 'true'
  end
  
  it 'should return "undef" if passing :undef' do
    should run.with_params(:undef).and_return 'undef'
  end
end