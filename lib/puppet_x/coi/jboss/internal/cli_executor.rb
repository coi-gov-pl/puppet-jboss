# Class that will handle executions of commands
class PuppetX::Coi::Jboss::Internal::CliExecutor
  # Constructor
  # @param {PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper} execution_state_wrapper handles command execution
  def initialize(execution_state_wrapper)
    @execution_state_wrapper = execution_state_wrapper
    @sanitizer = PuppetX::Coi::Jboss::Internal::Sanitizer.new
  end

  # Standard settter for execution_state_wrapper
  attr_writer :execution_state_wrapper

  # Method that allows us to setup shell executor, used in tests
  def shell_executor=(shell_executor)
    @execution_state_wrapper.shell_executor = shell_executor
  end

  # Standard getter for shell_executor
  def shell_executor
    @execution_state_wrapper.shell_executor
  end

  # Method that executes command, if method fails it prints log message
  # @param {String} typename name of resource
  # @param {String} cmd command that will be executed
  # @param {String} way bring up|bring down to for logging
  # @param {Hash} resource standard puppet resource object
  def executeWithFail(typename, cmd, way, resource)
    executed = wrap_execution(cmd, resource)
    unless executed[:result]
      ex = "\n#{typename} failed #{way}:\n[CLI command]: #{executed[:cmd]}\n[Error message]: #{executed[:lines]}"
      unless $add_log.nil? and $add_log > 0
        ex = "#{ex}\n#{printlog $add_log}"
      end
      raise ex
    end
    executed
  end

  # Method that executes command and returns outut
  # @param {String} cmd command that will be executed
  # @param {Boolean} runasdomain if command will be executen in comain instance
  # @param {Hash} ctrlcfg hash with configuration
  # @param {Number} retry_count number of retry after failed command
  # @param {Number} retry_timeout timeout after failed command
  def executeAndGet(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    ret = run_command(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    unless ret[:result]
      return {
        :result => false,
        :data => ret[:lines]
      }
    end

    begin
      evaluated_output = @sanitizer.sanitize(ret[:lines])
      undefined = nil
      evalines = eval(evaluated_output)
      return {
        :result => evalines['outcome'] == 'success',
        :data => (evalines['outcome'] == 'success' ? evalines['result'] : evalines['failure-description'])
      }

    rescue Exception => e
      Puppet.err e
      return {
        :result => false,
        :data => ret[:lines]
      }
    end
  end

  # Method that prepares command to be executed
  # @param {String} path path for execution
  # @param {Hash} ctrlcfg  hash with configuration that is need to execute command
  def prepare_command(path, ctrlcfg)
    home = PuppetX::Coi::Jboss::Configuration.config_value :home
    ENV['JBOSS_HOME'] = home

    jboss_home = "#{home}/bin/jboss-cli.sh"

    cmd = "#{jboss_home} #{timeout_cli} --connect --file=#{path} --controller=#{ctrlcfg[:controller]}"
    cmd += " --user=#{ctrlcfg[:ctrluser]}" unless ctrlcfg[:ctrluser].nil?
    cmd
  end

  # Method that will prepare and delegate execution of command
  # @param {String} jbosscmd command to be executeAndGet
  # @param {Boolean} runasdomain if jboss is run in domain mode
  # @param {Hash} ctrlcfg configuration Hash
  # @param {Integer} retry_count number of retries after command failure-description
  # @param {Integer} retry_timeout time after command is timeouted
  # @return {Hash} hash with result of command executed, output and command
  def run_command(jbosscmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    file = Tempfile.new 'jbosscli'
    path = file.path
    file.close
    file.unlink

    File.open(path, 'w') { |f| f.write(jbosscmd + "\n") }

    cmd = prepare_command(path, ctrlcfg)

    environment = ENV.to_hash

    unless ctrlcfg[:ctrlpasswd].nil?
      environment['__PASSWD'] = ctrlcfg[:ctrlpasswd]
      cmd += ' --password=$__PASSWD'
    end

    retries = 0
    result = ''
    lines = ''
    begin
      if retries > 0
        Puppet.warning "JBoss CLI command failed, try #{retries}/#{retry_count}, last status: #{result}, message: #{lines}"
        sleep retry_timeout.to_i
      end

      Puppet.debug 'Command send to JBoss CLI: ' + jbosscmd
      Puppet.debug('Cmd to be executed %s' % cmd)

      execution_state = @execution_state_wrapper.execute(cmd, jbosscmd, environment)
      result = execution_state.ret_code
      lines = execution_state.output

      retries += 1
    end while (result != 0 && retries <= retry_count)
    Puppet.debug('Output from JBoss CLI [%s]: %s' % [result.inspect, lines])
    # deletes the temp file
    File.unlink path
    {
      :cmd => jbosscmd,
      :result => result,
      :lines => lines
    }
  end

  private

  # Method that deletes execution of command by aading configurion
  # @param {String} cmd jbosscmd
  # @param {resource} standard Puppet resource
  def wrap_execution(cmd, resource)
    conf = {
      :controller => resource[:controller],
      :ctrluser => resource[:ctrluser],
      :ctrlpasswd => resource[:ctrlpasswd]
    }

    run_command(cmd, resource[:runasdomain], conf, 0, 0)
  end

  # method that return timeout parameter if we are running Jboss AS
  # @return {String} timeout_cli
  def timeout_cli
    '--timeout=50000' unless jbossas?
  end

  # Method that return refreshes facts that are available in the system or returns jboss_product
  def jbossas?
    # jboss_product fact is not set on first run, so that
    # calls to jboss-cli can fail (if jboss-as is installed)
    if jboss_product.nil?
      PuppetX::Coi::Jboss::FactsRefresher.refresh_facts [:jboss_product]
    end
    jboss_product == 'jboss-as'
  end

  # Method that return value of fact jboss_product
  def jboss_product
    Facter.value(:jboss_product)
  end

  $add_log = nil

  # Standard setter for isprintinglog
  def isprintinglog=(setting)
    $add_log = setting
  end
  
  def getlog(lines)
    last_lines = `tail -n #{lines} #{jbosslog}`
  end

  def printlog(lines)
    " ---\n JBoss AS log (last #{lines} lines): \n#{getlog lines}"
  end
end
