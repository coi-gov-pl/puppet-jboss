class Testing::Acceptance::JavaPlatform
  JAVA6_PLATFORMS = [
    'Ubuntu 14.04',
    'CentOS 6',
    'Debian 7'
  ].freeze

  class << self
    def java6?
      JAVA6_PLATFORMS.any? do |c|
        os = fact('operatingsystem')
        rel = fact('operatingsystemmajrelease')
        c == "#{os} #{rel}"
      end
    end

    def java8?
      if fact('osfamily') == 'RedHat' && fact('operatingsystemmajrelease') >= '6'
        true
      elsif fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') >= '9'
        true
      elsif fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') >= '15.10'
        true
      else
        false
      end
    end
  end
end
