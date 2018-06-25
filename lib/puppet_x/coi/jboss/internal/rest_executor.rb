require 'net/http'

# Class that will handle executions of commands via REST interface
class Puppet_X::Coi::Jboss::Internal::RestExecutor
  include Puppet_X::Coi::Jboss::Internal::JbosscliJsonify

  # Method that executes command, if method fails it prints log message
  # @param {String} typename name of resource
  # @param {String} cmd command that will be executed
  # @param {String} way bring up|bring down to for logging
  # @param {Hash} resource standard puppet resource object
  def executeWithFail(typename, cmd, way, resource)
    ''
  end

  # Method that executes command and returns outut
  # @param {String} cmd command that will be executed
  # @param {Boolean} runasdomain if command will be executen in comain instance
  # @param {Hash} ctrlcfg hash with configuration
  # @param {Number} retry_count number of retry after failed command
  # @param {Number} retry_timeout timeout after failed command
  def executeAndGet(cmd, runasdomain, ctrlcfg, retry_count, retry_timeout)
    jsoncmd = jsonify(cmd)
    uri = URI("http://#{ctrlcfg[:controller]}/management")
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req.set_form_data(jsoncmd)
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    JSON.parse(res)
    return nil
  rescue Exception => e
    Puppet.err e
    return {
      :result => false,
      :data   => ret[:lines]
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

end
