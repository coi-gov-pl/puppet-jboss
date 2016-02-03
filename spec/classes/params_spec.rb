require 'spec_helper_puppet'

describe 'jboss::params', :type => :class do

  it { is_expected.to compile }
  it { is_expected.to contain_class 'jboss::params' }
  it { is_expected.to contain_class 'jboss::internal::params' }
  it { is_expected.to contain_class 'jboss::internal::quirks::autoinstall' }
  it { is_expected.to contain_class 'jboss::internal::params::socketbinding' }
  it { is_expected.to contain_class 'jboss::internal::params::memorydefaults' }

end
