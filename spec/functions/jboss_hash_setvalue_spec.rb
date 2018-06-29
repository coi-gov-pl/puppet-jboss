require 'spec_helper_puppet'

describe 'jboss_hash_setvalue', :type => :puppet_function do
  describe 'given invalid number of arguments(4)' do
    it do
      is_expected.to run.
        with_params(1, 2, 1, 1).and_raise_error(
          Puppet::ParseError,
          'jboss_hash_setvalue(): wrong lenght of input given (4 for 3)'
        )
    end
  end

  describe 'given invalid number of arguments(2)' do
    it do
      is_expected.to run.
        with_params(1, 2).and_raise_error(
          Puppet::ParseError,
          'jboss_hash_setvalue(): wrong lenght of input given (2 for 3)'
        )
    end
  end

  describe "given input => { 'john' = 'cena' }, 'adam', 'smith' it should return => { john => 'cena', adam => 'smith' }" do
    before(:each) do
      skip('FIXME: Method should return hash not only last key, ref coi-gov-pl/puppet-jboss#28 ')
    end
    let(:input) { { 'john' => 'cena' } }
    it do
      is_expected.to run.
        with_params(input, 'adam', 'smith').and_return(
          'john' => 'cena',
          'adam' => 'smith'
        )
    end
  end
end
