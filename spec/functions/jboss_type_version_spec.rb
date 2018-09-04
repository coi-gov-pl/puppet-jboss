require 'spec_helper_puppet'

describe 'jboss_type_version' do
  describe 'given invalid number of parameters' do
    it do
      should run.
        with_params.and_raise_error(
          Puppet::ParseError,
          'jboss_type_version(): Wrong number of arguments given (0 for 1)'
        )
    end
  end

  describe 'given as-7.1.1.Final it should return as' do
    let(:input) { 'as-7.1.1.Final' }
    it do
      should run.
        with_params(input).and_return('as')
    end
  end

  {
    'as-7.1.1.Final' => 'as',
    '6.4.14.GA'      => nil,
    'eap-6.2.0.GA'   => 'eap',
    'asdasd'         => nil
  }.each do |input, expected|
    describe "given #{input.inspect} as input it should return #{expected.inspect}" do
      let(:args) { input }
      it { should run.with_params(args).and_return expected }
    end
  end
end
