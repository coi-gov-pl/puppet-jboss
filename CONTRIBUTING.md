This module has grown over time based on a range of contributions from
people using it. If you follow these contributing guidelines your patch
will likely make it into a release a little quicker.


## Contributing

1. Fork the repo.

2. Create your feature branch (`git checkout -b feature/my-new-feature`)

3. Run the tests. We only take pull requests with passing tests, and
   it's great to know that you have a clean slate

4. Add a test for your change. Only refactoring and documentation
   changes require no new tests. If you are adding functionality
   or fixing a bug, please add a test.

5. Make the test pass.

6. Push to your fork and submit a pull request.


## Dependencies

The testing and development tools have a bunch of dependencies,
all managed by [bundler](http://bundler.io/) according to the
[Puppet support matrix](http://docs.puppetlabs.com/guides/platforms.html#ruby-versions).

By default the tests use a baseline version of Puppet.

If you have Ruby 2.x or want a specific version of Puppet,
you must set an environment variable such as:

    export PUPPET_VERSION="~> 3.2.0"

Install the dependencies like so... (you can also pass `--path /fs/path/for/deps` to fetch dependencies to other directory)

    bundle install

If you want to use Ruby 1.8 that we still support you have to pass `--gemfile gemfiles/Gemfile18.facter17` to download correct versions of gems that we use.

## Syntax and style

The test suite will run [Puppet Lint](http://puppet-lint.com/) and
[Puppet Syntax](https://github.com/gds-operations/puppet-syntax) to
check various syntax and style things. You can run these locally with:

    bundle exec rake lint
    bundle exec rake syntax

## Running the unit tests

The unit test suite covers most of the code, as mentioned above please
add tests if you're adding new functionality. If you've not used
[rspec-puppet](http://rspec-puppet.com/) before then feel free to ask
about how best to test your new feature. Running the test suite is done
with:

    bundle exec rake spec

Note also you can run the syntax, style and unit tests in one go with:

    bundle exec rake test

## Automatically run the Integration tests

During development of your puppet module you might want to run your unit tests a couple of times. You can use the following command to automate running the unit tests on every change made in the manifests folder.

  bundle exec guard

## Integration tests

The unit tests just check the code runs, not that it does exactly what
we want on a real machine. For that we're using
[beaker](https://github.com/puppetlabs/beaker).

This fires up a new virtual machine (using vagrant) and runs a series of
simple tests against it after applying the module. You can run this
with:

    bundle exec rake acceptance

This will run the tests on an Centos 6.5 docker container. You can also
run the integration tests against any other configuration specified in directory `spec/acceptance/nodesets`. For example for Ubuntu 14.04 running on virtualbox via Vagrant you should run:

    RS_SET=ubuntu-14.04-x86_64-vagrant bundle exec rake acceptance

If you don't want to have to recreate the virtual machine every time you
can use `BEAKER_DESTROY=no` and `BEAKER_PROVISION=no`. On the first run you will
at least need `BEAKER_PROVISION` set to yes (the default). The Vagrantfile
for the created virtual machines will be in `.vagrant/beaker_vagrant_files`.

## Release Management

This paragraph applies mostly to COI staff. `coi/jboss` module follows a Git Flow standard. To make a release make sure you got:

 * sign in inforamation for Puppet Forge website for COI account
 * all PR an issues for given milestone are completed
 * you have GPG signing enabled for Git by default

To perform a release:

1. Switch to `develop` branch: `git checkout develop`, and sync it to upstream with: `git pull`
1. Clean all temporary files with: `git clean -fdx`
1. Ensure git flow is initialized with defaults: `git flow init -fd`
1. Start a release: `git flow release start vX.X.X` with version of completed milestone
1. Being on release branch, update `metadata.json` file by removing `"-pre"` from version, for ex.: `"1.3.0-pre"` -> `"1.3.0"`
1. Also update `README.md` with all appopriate changes, at least write an entry for "Changelog" section for new release
1. Commit changes.
1. Perform a release with: `git flow release finish vX.X.X`
1. Now you should be on `develop` branch, update `metadata.json` file by setting version to next candidate as PRE release, for ex.: `"1.3.0"` -> `"1.3.1-pre"`
1. Commit changes
1. Switch to master branch, and check proper taging: `git describe` should returns simply `v1.3.0`
1. Sign a tag with: `git tag v1.3.0 --force --sign` (`--sign` in not needed if you have GPG signing enabled for Git by default)
1. Perform a tests, unit and acceptance
1. If everything is ok, clean all temporary files, again, with: `git clean -fdx`
1. Build a package with: `bundle exec rake build`, tarball package should be located in `pkg/` directory
1. Login to Puppet Forge and upload a built tarball package.
1. Push git changes to upstream with: `git push origin master develop --tags`
1. Go to Github, releases tab. Click new release, select tag. Write a description, should be quite same as changelog entry (you can add links to resolved issues and PR). Upload a tarball as attachment. Save.
1. Done 😅

If something wasn't okey, in some step, don't go further. Especially if uploaded to Puppet Forge tarball is invalid, you will be forced to release additional version, as it's not possible to override version on Puppet Forge.

Watch out!

