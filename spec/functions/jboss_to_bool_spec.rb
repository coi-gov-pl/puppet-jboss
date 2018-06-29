require 'spec_helper_puppet'

describe 'jboss_to_bool', :type => :puppet_function do
  it do
    should run.
      with_params.and_raise_error(
        Puppet::ParseError,
        'jboss_to_bool(): Wrong number of arguments given (0 for 1)'
      )
  end

  it do
    should run.
      with_params(1, true).and_raise_error(
        Puppet::ParseError,
        'jboss_to_bool(): Wrong number of arguments given (2 for 1)'
      )
  end

  it { should run.with_params(true).and_return true }
  it { should run.with_params(1).and_return true }
  it { should run.with_params(:true).and_return true }
  it { should run.with_params(:t).and_return true }
  it { should run.with_params(:yes).and_return true }
  it { should run.with_params(:y).and_return true }
  it { should run.with_params('true').and_return true }
  it { should run.with_params('t').and_return true }
  it { should run.with_params('yes').and_return true }
  it { should run.with_params('y').and_return true }

  it { should run.with_params(nil).and_return false }
  it { should run.with_params(false).and_return false }
  it { should run.with_params(:undef).and_return false }
  it { should run.with_params(:undefined).and_return false }
  it { should run.with_params('undef').and_return false }
  it { should run.with_params('undefined').and_return false }
  it { should run.with_params('').and_return false }
  it { should run.with_params('It\'s tick tac toe!').and_return false }
  it { should run.with_params(0).and_return false }
  it { should run.with_params(1340).and_return false }
  it { should run.with_params(:f).and_return false }
  it { should run.with_params(:false).and_return false }
  it { should run.with_params('false').and_return false }
  it { should run.with_params('f').and_return false }
  it { should run.with_params(:no).and_return false }
  it { should run.with_params(:n).and_return false }
  it { should run.with_params('no').and_return false }
  it { should run.with_params('n').and_return false }
end
