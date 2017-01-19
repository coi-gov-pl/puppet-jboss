source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'rake',                           :require => false unless dependencies.map {|dep| dep.name}.include?('rake')
  # TODO: Remove this explicitly pinned version by the time ticket gh-org/puppet-jboss#84 is closed.
  gem 'rspec-puppet', '2.3.2',          :require => false
  gem 'puppetlabs_spec_helper',         :require => false
  gem 'puppet-lint',                    :require => false
  gem 'metadata-json-lint',             :require => false
  gem 'os',                             :require => false
  gem 'beaker', '< 3.1.0',              :require => false
  gem 'beaker-rspec', '5.6.0',          :require => false
  gem 'docker-api',                     :require => false
  gem 'coveralls',                      :require => false
  gem 'codeclimate-test-reporter',      :require => false
  gem 'simplecov',                      :require => false
  if facterver = ENV['FACTER_VERSION']
    gem 'facter', facterver,            :require => false
  else
    gem 'facter',                       :require => false
  end
  gem 'puppet', '~> 3.0',               :require => false
  gem 'ruby-augeas',                    :require => false
  gem 'augeas',                         :require => false
  gem 'nokogiri', '~> 1.6.6.0',         :require => false
end

group :development do
  gem 'inch',                           :require => false
  gem 'vagrant-wrapper',                :require => false
  gem 'travis',                         :require => false
  gem 'puppet-blacksmith',              :require => false
  gem 'pry-byebug',                     :require => false
end

# vim:ft=ruby
