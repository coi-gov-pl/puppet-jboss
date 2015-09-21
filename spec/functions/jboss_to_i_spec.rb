require 'spec_helper'

describe 'jboss_to_i', :type => :puppet_function do
  it do
    should run.
      with_params().and_raise_error(
        Puppet::ParseError, 
        'jboss_to_i(): Wrong number of arguments given (0 for 1)'
      )
  end

  it { should run.with_params(nil).and_return(0) }
  it { should run.with_params('').and_return(0) }
  it { should run.with_params(123).and_return(123) }
  it { should run.with_params('67').and_return(67) }
  
  it do
    v = :azx
    should run.with_params(v).and_return(0)
  end

end