require 'puppet'
require 'beaker-rspec'
require 'beaker/puppeter'
require 'beaker/module_install_helper'
require 'puppet-examples-helpers'

run_puppeter
install_module
install_module_dependencies
shell 'rm -fv /etc/profile.d/python27.sh'

RSpec.configure do |c|
  c.include PuppetExamplesHelpers

  c.formatter = :documentation
end
