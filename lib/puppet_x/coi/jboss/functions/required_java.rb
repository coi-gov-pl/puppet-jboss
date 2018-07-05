# A custom class that holds custom functions
class PuppetX::Coi::Jboss::Functions
  class << self
    # PRIVATE INTERNAL FUNCTION. Casts any value to string
    #
    # @param scope [Scope] a function scope
    # @param args [Array] should contain product and version
    # @return [int[]] an array of integers representing required java version of AS server
    def required_java(scope, args)
      validate_method_parameters('jboss_required_java', args) do
        { :desc => '2', :condition => args.size != 2 }
      end
      product = args[0]
      version = args[1]

      required_java_for_product_and_version(scope, product, version)
    end

    private

    def required_java_for_product_and_version(scope, product, version)
      case product
      when 'jboss-as'
        required_java_for_jboss_as(version)
      when 'jboss-eap'
        required_java_for_jboss_eap(version)
      when 'wildfly'
        required_java_for_wildfly(scope, version)
      else
        raise_error_invalid_product(product)
      end
    end

    def raise_error_invalid_product(product)
      raise(
        Puppet::Error,
        "Invalid product: #{product}. Only: jboss-as, jboss-eap and wildfly values are acceptavle"
      )
    end

    def required_java_for_jboss_as(_)
      [6]
    end

    def required_java_for_jboss_eap(version)
      if version > '6.4.1'
        if version > '7.0.0'
          [8]
        else
          [6, 7, 8]
        end
      else
        [6, 7]
      end
    end

    def required_java_for_wildfly(scope, version)
      if version > '10.0.0'
        [8]
      elsif version < '9.0.0' && scope.lookupvar('osfamily') == 'Debian'
        # Due to JBoss bugs that sometimes leads to JBoss crashes due to SIGSEGV signal thrown by Java
        # The issue is described in https://github.com/coi-gov-pl/puppet-jboss/issues/102 ticket
        [8]
      else
        [7, 8]
      end
    end
  end
end
