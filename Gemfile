source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'rake',                   :require => false
  gem 'rspec-puppet',           :require => false
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint',            :require => false
  gem 'metadata-json-lint',     :require => false
  gem 'json',                   :require => false
  if RUBY_VERSION < '1.9.0'
    gem 'rspec-its',            :require => false
    gem 'rspec', '~> 3.1.0',    :require => false
  end

  if RUBY_VERSION >= '1.9.0'
    gem 'beaker',               :require => false
    gem 'beaker-rspec',         :require => false
    gem 'coveralls',            :require => false
    gem 'simplecov',            :require => false
  end
  if facterver = ENV['FACTER_VERSION']
    gem 'facter', facterver,    :require => false
  else
    gem 'facter',               :require => false
  end
  if puppetver = ENV['PUPPET_VERSION']
    gem 'puppet', puppetver,    :require => false
  else
    gem 'puppet',               :require => false
  end
end

group :development do
  gem 'inch',                   :require => false
  gem 'vagrant-wrapper',        :require => false
  if RUBY_VERSION >= '1.9.0'
    gem 'travis',               :require => false
    gem 'puppet-blacksmith',    :require => false
    gem 'guard-rake',           :require => false
    if RUBY_VERSION >= '2.0.0'
      gem 'pry-byebug',         :require => false
    else
      gem 'pry-debugger',       :require => false
    end
  else
    gem 'pry', '~> 0.9.0',      :require => false
  end
end
# vim:ft=ruby