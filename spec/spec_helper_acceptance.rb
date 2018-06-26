require 'puppet'
require 'beaker-rspec'
require 'beaker/puppeter'
require 'beaker/module_install_helper'
require 'puppet-examples-helpers'
require 'testing'

run_puppeter
install_module
install_module_dependencies
shell 'rm -fv /etc/profile.d/python27.sh'

JAVA6_PLATFORMS = ['Ubuntu 14.04', 'CentOS 6'].freeze

RSpec.configure do |c|
  c.include PuppetExamplesHelpers

  c.formatter = :documentation
  c.order     = :defined
end
