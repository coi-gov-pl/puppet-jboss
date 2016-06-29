source ENV['GEM_SOURCE'] || 'https://rubygems.org'

eval(IO.read(File.join(File.dirname(__FILE__), 'Gemfile.ruby19')), binding) if RUBY_VERSION < '2.0.0' and RUBY_VERSION >= '1.9.0'
eval(IO.read(File.join(File.dirname(__FILE__), 'Gemfile.ruby18')), binding) if RUBY_VERSION < '1.9.0'
eval(IO.read(File.join(File.dirname(__FILE__), 'Gemfile.local')), binding) if File.exists?('Gemfile.local')

group :test do
  gem 'rake',                           :require => false unless dependencies.map {|dep| dep.name}.include?('rake')
  # TODO: Remove this explicitly pinned version by the time ticket gh-org/puppet-jboss#84 is closed.
  gem 'rspec-puppet', '2.3.2',          :require => false
  gem 'puppetlabs_spec_helper',         :require => false
  gem 'puppet-lint',                    :require => false
  gem 'metadata-json-lint',             :require => false
  gem 'json',                           :require => false
  gem 'os',                             :require => false
  gem 'specinfra', '2.59.0',            :require => false
  gem 'net-ssh', '2.9.4',               :require => false

  if RUBY_VERSION >= '1.9.0'
    gem 'beaker',                       :require => false
    gem 'beaker-rspec',                 :require => false
    gem 'docker-api',                   :require => false
    gem 'coveralls',                    :require => false
    gem 'codeclimate-test-reporter',    :require => false
    gem 'simplecov',                    :require => false
  end
  if facterver = ENV['FACTER_VERSION']
    gem 'facter', facterver,            :require => false
  else
    gem 'facter',                       :require => false
  end
  puppetver = if RUBY_VERSION < '1.9.0' then '~> 2.7.0' else ENV['PUPPET_VERSION'] end
  if puppetver
    gem 'puppet', puppetver,            :require => false
    if Gem::Requirement.new(puppetver) =~ Gem::Version.new('2.7.0')
      gem 'hiera-puppet',               :require => false
    end
  else
    gem 'puppet', '~> 3.0',             :require => false
  end
  gem 'ruby-augeas',                    :require => false
  gem 'augeas',                         :require => false
end

group :development do
  gem 'inch',                           :require => false
  gem 'vagrant-wrapper',                :require => false
  if RUBY_VERSION >= '1.9.0'
    gem 'travis',                       :require => false
    gem 'puppet-blacksmith',            :require => false
    if RUBY_VERSION >= '2.0.0'
      gem 'guard-rake',                 :require => false
      gem 'pry-byebug',                 :require => false
    else
      gem 'pry-debugger',               :require => false
    end
  end
end

# vim:ft=ruby
