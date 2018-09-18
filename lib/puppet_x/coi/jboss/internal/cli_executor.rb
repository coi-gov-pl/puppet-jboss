require 'json'

# Class that will handle executions of commands
class PuppetX::Coi::Jboss::Internal::CliExecutor
  include PuppetX::Coi::Jboss::Checks

  # Constructor
  # @param executor [PuppetX::Coi::Jboss::Internal::ExecutionStateWrapper] handles command execution
  # @param execlogic [PuppetX::Coi::Jboss::Internal::ExecuteLogic]         a logic for execution
  def initialize(executor, execlogic)
    @executor  = executor
    @execlogic = execlogic
    @sanitizer = PuppetX::Coi::Jboss::Internal::Sanitizer.new
  end

  # Standard settter for executor
  attr_writer :executor

  # Method that allows us to setup shell executor, used in tests
  def shell_executor=(shell_executor)
    @executor.shell_executor = shell_executor
  end

  # Standard getter for shell_executor
  def shell_executor
    @executor.shell_executor
  end

  # Method that executes command, if method fails it prints log message
  #
  # @param typename [String] name of resource
  # @param cmd [String]      command that will be executed
  # @param way [String]      bring up|bring down to for logging
  # @param resource [Hash]   standard puppet resource object
  def execute_with_fail(typename, cmd, way, resource)
    executor_proc = proc { |compiled| wrap_execution(compiled, resource) }
    @execlogic.execute_with_fail(typename, cmd, way, executor_proc)
  end

  # Method that executes command and returns outut
  # @param cmd [String]          command that will be executed
  # @param runasdomain [Boolean] if command will be executen in comain instance
  # @param ctrlcfg [Hash]        hash with configuration
  # @param try [PuppetX::Coi::Jboss::Value::Try] the try object
  # @return [Hash] a hash of `:result` as `Boolean`, and `:data` as `Hash`
  def execute_and_get(cmd, runasdomain, ctrlcfg, try)
    state = run_jboss_command(cmd, runasdomain, ctrlcfg, try)
    if state.success?
      read_output state.output
    else
      final_result false, state.output
    end
  end

  # Method that will prepare and delegate execution of command
  # @param jbosscmd     [String]  command to be execute_and_get
  # @param _runasdomain [Boolean] if jboss is run in domain mode
  # @param ctrlcfg      [Hash]    configuration Hash
  # @param try [PuppetX::Coi::Jboss::Value::Try] the try object
  # @return [PuppetX::Coi::Jboss::Internal::State::ExecutionState] a state of execution
  def run_jboss_command(jbosscmd, _runasdomain, ctrlcfg, try)
    file = Tempfile.new 'jbosscli'
    path = file.path
    file.close
    file.unlink

    File.open(path, 'w') { |f| f.write(jbosscmd + "\n") }

    cmd = prepare_command(path, ctrlcfg)

    retries = 0
    result = nil
    loop do
      if retries > 0
        Puppet.warning "JBoss CLI command failed, try #{retries}/#{try.count}, last status: #{result}, message: #{result.output}"
        sleep try.timeout
      end
      Puppet.debug "OS command to be executed #{cmd.command}"
      Puppet.debug "JBoss CLI command to be executed: #{jbosscmd}"

      result = @executor.execute(cmd, jbosscmd)
      retries += 1
      break if result.success? || retries > try.count
    end
    Puppet.debug "Output from JBoss CLI [#{result.retcode}]: #{result.output}"
    result
  ensure
    # deletes the temp file
    File.unlink path
  end

  private

  # Method that prepares command to be executed
  #
  # @param path [String]  path for execution
  # @param ctrlcfg [Hash] hash with configuration that is need to execute command
  # @return [PuppetX::Coi::Jboss::Value::Command] a command with environment
  def prepare_command(path, ctrlcfg)
    home = check_not_empty PuppetX::Coi::Jboss::Configuration.config_value(:home)
    jboss_cli = "#{home}/bin/jboss-cli.sh"
    environment = ENV.to_hash
    environment['JBOSS_HOME'] = home

    cmd = "#{jboss_cli} #{timeout_cli} --connect --file=#{path} --controller=#{ctrlcfg[:controller]}"
    cmd += " --user=#{ctrlcfg[:ctrluser]}" unless ctrlcfg[:ctrluser].nil?
    unless ctrlcfg[:ctrlpasswd].nil?
      environment['__PASSWD'] = ctrlcfg[:ctrlpasswd]
      cmd += ' --password=$__PASSWD'
    end
    PuppetX::Coi::Jboss::Value::Command.new cmd, environment
  end

  def read_output(lines)
    json = @sanitizer.sanitize(lines)
    Puppet.debug("Output from JBoss CLI JSON'ized: #{json}")
    value = JSON.parse(json)
    final_result success_from(value), data_of(value)
  rescue StandardError => ex
    Puppet.err ex
    Puppet.err ex.backtrace
    final_result false, lines
  end

  def final_result(success, data)
    { :result => success, :data => data }
  end

  def success_from(value)
    value['outcome'] == 'success'
  end

  def data_of(value)
    value['outcome'] == 'success' ? value['result'] : value['failure-description']
  end

  # Method that deletes execution of command by aading configurion
  # @param cmd [String] jbosscmd
  # @param standard [resource] Puppet resource
  def wrap_execution(cmd, resource)
    conf = {
      :controller => resource[:controller],
      :ctrluser   => resource[:ctrluser],
      :ctrlpasswd => resource[:ctrlpasswd]
    }
    try = PuppetX::Coi::Jboss::Value::Try::ZERO
    run_jboss_command(cmd, resource[:runasdomain], conf, try)
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
end
