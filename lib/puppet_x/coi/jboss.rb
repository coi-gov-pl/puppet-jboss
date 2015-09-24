# A puppet x module
module Puppet_X
  # A COI puppet_x module
  module Coi
    # JBoss module
    module Jboss
      # Requires a Puppet_X JBoss class
      def self.requirex(cls)
        fullpath = File.expand_path(File.join(File.dirname(__FILE__), 'jboss', cls))

        require fullpath
      end
    end
  end
end