# Retry value object
# ===
# Object that specifies a number of times we want to retry execution of command
# after failure, and timeout after which we assume that command failed to
# execute.
class PuppetX::Coi::Jboss::Value::Try
  attr_reader :count, :timeout

  def initialize(count, timeout)
    @count   = count
    @timeout = timeout.to_i
  end

  ZERO = PuppetX::Coi::Jboss::Value::Try.new(0, 0)
end
