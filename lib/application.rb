require_relative 'bootstrap'

class PolyteneRunner < Thor
  include Thor::Actions

  desc 'configure', 'Call configure to configure runner'
  def configure
    if pid_file_exists?
      puts "PID file exists. Runner may be running. Stop him before reconfiguring."
    else
      Polytene::Configurator.new.configure
    end
  end

  desc 'start', 'Call start to start runner'
  method_option :daemonize, :aliases => "-d", :default => false, :type => :boolean, :banner => "Run as daemon"
  def start
    kill_app if pid_file_exists? && yes?('PID file exists. Runner may be running. Kill him?')

    unless pid_file_exists?
      if Polytene::Configurator.new.valid?
        Daemons.daemonize({:app_name => app_name, :dir => TMP_PATH, :log_dir => TMP_PATH, :log_output => true, :dir_mode => :normal}) if options[:daemonize]
        Polytene::Runner.new.run
      else
        Polytene::Configurator.new.validate
        exit 1
      end
    else
      exit 1
    end
  end

  desc 'restart', 'Call to restart runner (daemon mode)'
  method_option :daemonize, :aliases => "-d", :default => true, :type => :boolean, :banner => "Run as daemon"
  def restart
    stop
    start
  end

  desc 'validate', 'Call validate to validate configuration'
  def validate
    Polytene::Configurator.new.validate
  end

  desc 'stop', 'Kill daemonized runner'
  def stop
    if pid_file_exists?
      kill_app
      puts "Killed."
    else
      puts "Nothing to stop. No PID file found."
    end
  end

  no_tasks do
    def app_name
      'polytene-runner'
    end

    def pid_file_exists?
      File.exists?(pid_path)
    end

    def kill_app
      Process.kill(15, File.read(pid_path).to_i)
      FileUtils.rm(pid_path)
    end

    def pid_path
      File.join(TMP_PATH, "#{app_name}.pid")
    end
  end
end
