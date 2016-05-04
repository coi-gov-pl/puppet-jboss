# TODO change to jbossclirunner/jbosscliexecutor
# Class that will handle executions of commands
class Puppet_X::Coi::Jboss::Internal::CliExecutor

  def initialize(system_executor)
    @system_executor = system_executor
  end

  def system_executor=(value)
    @system_executor = value
  end

  def executeAndGet(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    ret = run_command(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    unless ret[:result]
      return {
        :result => false,
        :data => ret[:lines]
      }
    end

    # TODO move to another method
    # Giving JBoss `undefine` value in Ruby
    undefined = nil
    # JBoss expression and Long value handling
    ret[:lines].gsub!(/expression \"(.+)\",/, '\'\1\',')
    ret[:lines].gsub!(/=> (\d+)L/, '=> \1')

    begin
      evalines = eval(ret[:lines])
      Puppet.debug(evalines.inspect)
      return {
        :result  => evalines["outcome"] == "success",
        :data    => (evalines["outcome"] == "success" ? evalines["result"] : evalines["failure-description"])
      }

    rescue Exception => e
      Puppet.err e
      return {
        :result  => false,
        :data    => ret[:lines]
      }
    end
  end

  # TODO move to methods
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

    File.open(path, 'w') {|f| f.write(jbosscmd + "\n") }

    home = Puppet_X::Coi::Jboss::Configuration::config_value :home
    ENV['JBOSS_HOME'] = home

    jboss_home = "#{home}/bin/jboss-cli.sh"
    cmd = "#{jboss_home} #{timeout_cli} --connect --file=#{path} --controller=#{ctrlcfg[:controller]}"
    unless ctrlcfg[:ctrluser].nil?
      cmd += " --user=#{ctrlcfg[:ctrluser]}"
    end
    environment = ENV.to_hash
    unless ctrlcfg[:ctrlpasswd].nil?
      environment['__PASSWD'] = ctrlcfg[:ctrlpasswd]
      cmd += " --password=$__PASSWD"
    end
    retries = 0
    result = ''
    lines = ''
    begin
      if retries > 0
        Puppet.warning "JBoss CLI command failed, try #{retries}/#{retry_count}, last status: #{result}, message: #{lines}"
        sleep retry_timeout.to_i
      end

      Puppet.debug "Command send to JBoss CLI: " + jbosscmd
      Puppet.debug "Cmd to be executed %s" % cmd

      execution_state = @system_executor.execute(cmd, jbosscmd, environment)
      Puppet.debug "execution state "
      result = execution_state.ret_code
      lines = execution_state.output

      Puppet.debug 'after execution state'

      retries += 1
    end while (result != 0 && retries <= retry_count)
    Puppet.debug "Output from JBoss CLI [%s]: %s" % [result.inspect, lines]
    # deletes the temp file
    File.unlink path
    return {
      :cmd    => jbosscmd,
      :result => result,
      :lines  => lines
    }
  end

  def timeout_cli
    '--timeout=50000' unless jbossas?
  end

  def jbossas?
    # jboss_product fact is not set on first run, so that
    # calls to jboss-cli can fail (if jboss-as is installed)
    if jboss_product.nil?
      Puppet_X::Coi::Jboss::FactsRefresher::refresh_facts [:jboss_product]
    end
    jboss_product == 'jboss-as'
  end

  def jboss_product
    Facter.value(:jboss_product)
  end


end
