require 'spec_helper_puppet'

describe 'jboss_short_version', :type => :puppet_function do
  describe 'with zero parameters given' do
    it do
      should run.
        with_params.and_raise_error(
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

  {
    'as-7.1.1.Final' => '7.1',
    '6.4.14.GA'      => '6.4',
    'eap-6.2.0.GA'   => '6.2',
    'asdasd'         => nil
  }.each do |input, expected|
    describe "with #{input.inspect} as input it should return #{expected.inspect}" do
      let(:args) { input }
      it { should run.with_params(args).and_return expected }
    end
  end
end
