require 'spec_helper_puppet'

describe 'jboss_required_java', :type => :puppet_function do
  describe 'with zero parameters given' do
    it do
      is_expected.to run.with_params.and_raise_error(
        Puppet::ParseError,
        'jboss_required_java(): Wrong number of arguments given (0 for 3)'
      )
    end
  end

  describe 'with tree parameters given' do
    it do
      is_expected.to run.with_params('RedHat', 'wildfly', '10.0.0').and_return(
        [8]
      )
    end
    it do
      is_expected.to run.with_params('RedHat', 'wildfly', '8.0.1').and_return(
        [7, 8]
      )
    end
    it do
      is_expected.to run.with_params('Debian', 'wildfly', '8.0.1').and_return(
        [8]
      )
    end
    it do
      is_expected.to run.with_params('RedHat', 'jboss-as', '7.0.1').and_return(
        [6]
      )
    end
    it do
      is_expected.to run.with_params('RedHat', 'jboss-eap', '7.0.0').and_return(
        [8]
      )
    end
    it do
      is_expected.to run.with_params('RedHat', 'jboss-eap', '6.4.2').and_return(
        [6, 7, 8]
      )
    end
    it do
      is_expected.to run.with_params('RedHat', 'jboss-eap', '6.3.12').and_return(
        [6, 7]
      )
    end
    it do
      is_expected.to run.with_params('RedHat', 'blah', '12.0').and_raise_error(
        Puppet::Error,
        'Invalid product: blah. Only: jboss-as, jboss-eap and wildfly values are acceptable'
      )
    end
  end
end
