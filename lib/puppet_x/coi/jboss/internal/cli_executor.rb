# Class that will handle executions of commands
class Puppet_X::Coi::Jboss::Internal::CliExecutor
  # Constructor
  # @param {Puppet_X::Coi::Jboss::Internal::ExecutionStateWrapper} execution_state_wrapper handles command execution
  def initialize(execution_state_wrapper)
    @execution_state_wrapper = execution_state_wrapper
    @evaluator = Puppet_X::Coi::Jboss::Internal::Evaluator.new
  end

  attr_writer :execution_state_wrapper

  # Method that allows us to setup shell executor, used in tests
  def shell_executor=(shell_executor)
    @execution_state_wrapper.shell_executor = shell_executor
  end

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
    Puppet.debug("Ret: #{ret.inspect}")
    unless ret[:result]
      return {
        :result => false,
        :data => ret[:lines]
      }
    end

    # JBoss expression and Long value handling
    ret[:lines].gsub!(/expression \"(.+)\",/, '\'\1\',')
    ret[:lines].gsub!(/=> (\d+)L/, '=> \1')

    begin
      evaluated_output = @evaluator.evaluate(ret[:lines])
      undefined = nil
      Puppet.debug("Output to be evaluated: #{ret[:lines].inspect}")
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

  # Method that prepares output from command execution so it can be later evaluated to Ruby hash
  # @param {String} output output from command execution
  # @return {Hash} hash with prepared data
  def evaluate_output(output)
    undefined = nil
    # JBoss expression and Long value handling
    output[:lines].gsub!(/expression \"(.+)\",/, '\'\1\',')
    output[:lines].gsub!(/=> (\d+)L/, '=> \1')
    output
  end

  def prepare_command(path, ctrlcfg)
    Puppet.debug('Start of prepare command')
    home = Puppet_X::Coi::Jboss::Configuration.config_value :home
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

  def wrap_execution(cmd, resource)
    conf = {
      :controller => resource[:controller],
      :ctrluser => resource[:ctrluser],
      :ctrlpasswd => resource[:ctrlpasswd]
    }

    run_command(cmd, resource[:runasdomain], conf, 0, 0)
  end

  def timeout_cli
    '--timeout=50000' unless jbossas?
  end

  def jbossas?
    # jboss_product fact is not set on first run, so that
    # calls to jboss-cli can fail (if jboss-as is installed)
    if jboss_product.nil?
      Puppet_X::Coi::Jboss::FactsRefresher.refresh_facts [:jboss_product]
    end
    jboss_product == 'jboss-as'
  end

  def jboss_product
    Facter.value(:jboss_product)
  end

  $add_log = nil

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
