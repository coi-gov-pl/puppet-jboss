class Testing::RspecPuppet::SharedFacts
  DEFAULT_IP         = '192.168.0.1'
  DEFAULT_CONCAT_DIR = '/root/concat'

  DEFAULT_ORACLELINUX_FACTS = {
    :operatingsystem           => 'OracleLinux',
    :osfamily                  => 'RedHat',
    :ipaddress                 => DEFAULT_IP,
    :concat_basedir            => DEFAULT_CONCAT_DIR,
    :operatingsystemrelease    => '6.7',
    :operatingsystemmajrelease => '6',
    :puppetversion             => Puppet.version.to_s
  }
  DEFAULT_UBUNTU_RELEASE = '14.04'
  DEFAULT_UBUNTU_FACTS = {
    :operatingsystem           => 'Ubuntu',
    :osfamily                  => 'Debian',
    :ipaddress                 => DEFAULT_IP,
    :concat_basedir            => DEFAULT_CONCAT_DIR,
    :operatingsystemmajrelease => DEFAULT_UBUNTU_RELEASE,
    :operatingsystemrelease    => DEFAULT_UBUNTU_RELEASE,
    :lsbdistcodename           => 'trusty',
    :lsbdistdescription        => 'Ubuntu 14.04.3 LTS',
    :lsbdistid                 => 'Ubuntu',
    :lsbdistrelease            => DEFAULT_UBUNTU_RELEASE,
    :lsbmajdistrelease         => DEFAULT_UBUNTU_RELEASE,
    :puppetversion             => Puppet.version.to_s
  }
  class << self
    def ubuntu_facts(override = {})
      DEFAULT_UBUNTU_FACTS.merge(override)
    end

    def oraclelinux_facts(override = {})
      DEFAULT_ORACLELINUX_FACTS.merge(override)
    end
  end
end
