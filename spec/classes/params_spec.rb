require 'spec_helper_puppet'

describe 'jboss::params', :type => :class do

  it { is_expected.to compile }
  
end