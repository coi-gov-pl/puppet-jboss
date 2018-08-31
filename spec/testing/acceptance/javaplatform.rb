require 'puppet_x/coi/jboss'

class Testing::Acceptance::JavaPlatform
  JAVA6_PLATFORMS = [
    'Ubuntu 14.04',
    'CentOS 6',
    'Debian 7'
  ].freeze

  class << self
    def compatibile_java?(product, version)
      osfamily = fact('osfamily')
      required_java = PuppetX::Coi::Jboss::Functions.required_java_for_product_and_version(
        osfamily, product, version
      )
      required_java.include? platform_java
    end

    private

    def platform_java
      if java8?
        8
      elsif java6?
        6
      else
        7
      end
    end

    def java6?
      JAVA6_PLATFORMS.any? do |c|
        os = fact('operatingsystem')
        rel = fact('operatingsystemmajrelease')
        c == "#{os} #{rel}"
      end
    end

    def java8?
      if redhat_ge_6? || debian_ge_9? || ubuntu_ge_1510?
        true
      else
        false
      end
    end

    def redhat_ge_6?
      fact('osfamily') == 'RedHat' && fact('operatingsystemmajrelease') >= '6'
    end

    def debian_ge_9?
      fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') >= '9'
    end

    def ubuntu_ge_1510?
      fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') >= '15.10'
    end
  end
end
