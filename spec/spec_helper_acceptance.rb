require 'spec_helper'
require 'beaker-rspec'
require 'beaker/puppeter'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'puppet-examples-helpers'
require 'testing'

if default[:type] == 'pe'
  run_puppet_install_helper
else
  run_puppeter
end
install_module
install_module_dependencies
shell 'rm -fv /etc/profile.d/python27.sh'

RSpec.configure do |c|
  c.include PuppetExamplesHelpers

  c.formatter = :documentation
  c.order     = :defined
end
