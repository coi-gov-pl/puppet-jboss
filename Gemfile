source ENV['GEM_SOURCE'] || 'https://rubygems.org/'

SUPPORTED_RUBIES = [
  '~> 2.1.8'
].freeze

# Used for gem conditionals, ugly code here :-P
RVERSION = Gem::Version.new(RUBY_VERSION.dup)
ruby_version_segments = RVERSION.segments
minor_version = "#{ruby_version_segments[0]}.#{ruby_version_segments[1]}"
def ver(spec)
  Gem::Version.new(spec)
end

def location_for(place_or_version)
  [place_or_version, { :require => false }]
end

# Puppet Module version
VER = '~> 0.3.5'.freeze

# Testing dependencies group
group :test do
  gem "puppet-module-posix-default-r#{minor_version}", VER, :require => false, :platforms => 'ruby'
  gem "puppet-module-posix-dev-r#{minor_version}",     VER, :require => false, :platforms => 'ruby'
  gem "puppet-module-win-default-r#{minor_version}",   VER, :require => false, :platforms => %w[mswin mingw x64_mingw]
  gem "puppet-module-win-dev-r#{minor_version}",       VER, :require => false, :platforms => %w[mswin mingw x64_mingw]
  gem 'coveralls',                                     :require => false
  gem 'rspec-puppet-facts-unsupported', '~> 0', '>= 0.1.1', :require => false
  gem 'ruby-augeas',                                   :require => false
  gem 'safe_yaml',                                     :require => false
end

# Acceptance Testing dependencies group
group :system_test do
  gem "puppet-module-posix-system-r#{minor_version}",  VER, :require => false, :platforms => 'ruby'
  gem "puppet-module-win-system-r#{minor_version}",    VER, :require => false, :platforms => %w[mswin mingw x64_mingw]
  beakerver = RVERSION < ver('2.2.0') ? ['>= 3.13.0', '< 4.0.0'] : nil
  gem 'beaker', '>= 3.36.0', *location_for(ENV['BEAKER_VERSION'] || beakerver)
  gem 'beaker-abs',                                    *location_for(ENV['BEAKER_ABS_VERSION'])
  gem 'beaker-hostgenerator',                          *location_for(ENV['BEAKER_HOSTGENERATOR_VERSION'])
  gem 'beaker-pe',                                     :require => false
  gem 'beaker-puppeter',                               :require => false
  gem 'beaker-rspec',                                  *location_for(ENV['BEAKER_RSPEC_VERSION'])
  gem 'puppet-examples-helpers', '~> 0',               :require => false
  gem 'vagrant-wrapper',                               :require => false
end

# Development dependencies group
group :development do
  gem 'pry',        :require => false
  gem 'pry-byebug', :require => false
end

gem 'puppet', '>= 6.25.1', *location_for(ENV['PUPPET_GEM_VERSION'] || '~> 3')

# Only explicitly specify Facter/Hiera if a version has been specified.
# Otherwise it can lead to strange bundler behavior. If you are seeing weird
# gem resolution behavior, try setting `DEBUG_RESOLVER` environment variable
# to `1` and then run bundle install.
gem 'facter', *location_for(ENV['FACTER_GEM_VERSION']) if ENV['FACTER_GEM_VERSION']
gem 'hiera', *location_for(ENV['HIERA_GEM_VERSION']) if ENV['HIERA_GEM_VERSION']

# Check for correct Ruby version, ugly code here :-P
if SUPPORTED_RUBIES.map { |v| Gem::Requirement.new(v) }.find { |req| req.satisfied_by? RVERSION }.nil?
  raise "Unsupported Ruby version #{RVERSION}, use one of: #{SUPPORTED_RUBIES}"
end
# vim:ft=ruby
