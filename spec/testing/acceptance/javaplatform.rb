class Testing::Acceptance::JavaPlatform
  JAVA6_PLATFORMS = [
    'Ubuntu 14.04',
    'CentOS 6'
  ].freeze

  class << self
    def java6compatibile?
      JAVA6_PLATFORMS.any? do |c|
        os = fact('operatingsystem')
        rel = fact('operatingsystemmajrelease')
        c == "#{os} #{rel}"
      end
    end
  end
end
