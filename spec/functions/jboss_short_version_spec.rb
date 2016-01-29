require "spec_helper"

describe 'jboss_short_version', :type => :puppet_function do

    describe 'with zero parameters given' do
      it do
        should run.
          with_params().and_raise_error(
              Puppet::ParseError,
              'jboss_short_version(): Wrong number of arguments given (0 for 1)'
            )
        end
    end

    describe 'with two parameters given' do
      it do
        should run.
          with_params('as-7.1.1.Final', 'eap-6.2.0.GA').and_raise_error(
            Puppet::ParseError,
            'jboss_short_version(): Wrong number of arguments given (2 for 1)'
          )
      end
    end

    describe 'with as-7.1.1.Final as input it should return 7.1' do
      let(:args) { ['as-7.1.1.Final'] }
      it { should run.with_params(args[0]).and_return '7.1' }
    end

    describe 'with asd as input it should return nil' do
      it { should run.with_params('asd').and_return nil }
    end
end
