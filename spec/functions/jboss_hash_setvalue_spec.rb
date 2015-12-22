require "spec_helper"

describe 'jboss_hash_setvalue', :type => :puppet_function do

  context 'given invalid number of arguments(4)' do
    it do
      should run.
        with_params(1,2,1,1).and_raise_error(
          Puppet::ParseError,
          "jboss_hash_setvalue(): wrong lenght of input given (4 for 3)"
        )
    end
  end

  context 'given invalid number of arguments(2)' do
    it do
      should run.
        with_params(1,2).and_raise_error(
          Puppet::ParseError,
          "jboss_hash_setvalue(): wrong lenght of input given (2 for 3)"
        )
    end
  end

  context "given input => { 'john' = 'cena' }, 'adam', 'smith' it should return => { john => 'cena', adam => 'smith' }" do
    let(:input) { { 'john' => 'cena' } }
      it do
        should run.
          with_params(input, 'adam', 'smith').and_return('smith')
      end

      after(:each) do
        expect(input).to include('adam' => 'smith')
        expect(input).to include('john' => 'cena')
        expect(input.size).to eq(2)
      end
end
