require 'rubygems'

# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Casts any value to string
    #
    # @param args [Array] should contain product and version
    # @return [int[]] an array of integers representing required java version of AS server
    def required_java(args)
      validate_method_parameters('jboss_required_java', args) do
        { :desc => '3', :condition => args.size != 3 }
      end
      osfamily = args[0]
      product = args[1]
      version = args[2]

      required_java_for_product_and_version(osfamily, product, version)
    end

    def required_java_for_product_and_version(osfamily, product, version)
      case product
      when 'jboss-as'
        required_java_for_jboss_as(version)
      when 'jboss-eap'
        required_java_for_jboss_eap(version)
      when 'wildfly'
        required_java_for_wildfly(osfamily, version)
      else
        raise_error_invalid_product(product)
      end
    end

    private

    def raise_error_invalid_product(product)
      raise(
        Puppet::Error,
        "Invalid product: #{product}. Only: jboss-as, jboss-eap and wildfly values are acceptable"
      )
    end

    def required_java_for_jboss_as(_)
      [6]
    end

    def required_java_for_jboss_eap(version)
      if Gem::Version.new(version) > Gem::Version.new('6.4.1')
        if Gem::Version.new(version) >= Gem::Version.new('7.0.0')
          [8]
        else
          [6, 7, 8]
        end
      else
        [6, 7]
      end
    end

    def required_java_for_wildfly(osfamily, version)
      if Gem::Version.new(version) >= Gem::Version.new('10.0.0')
        [8]
      elsif Gem::Version.new(version) < Gem::Version.new('9.0.0') && osfamily == 'Debian'
        # Due to JBoss bugs that sometimes leads to JBoss crashes due to SIGSEGV signal thrown by Java
        # The issue is described in https://github.com/coi-gov-pl/puppet-jboss/issues/102 ticket
        [8]
      else
        [7, 8]
      end
    end
  end
end
