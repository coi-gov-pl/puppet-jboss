# Constants for COI's JBoss module
module Puppet_X::Coi::Jboss::Constants
  ABSENTLIKE = [:absent, :undef, nil].freeze
  ABSENTLIKE_WITH_S = (Proc.new do
    # Proc scope not to leave any helper variables inside the context
    stringified = ABSENTLIKE.reject { |v| v.nil? }.map { |v| v.to_s }
    (ABSENTLIKE + stringified).freeze
  end).call
end
