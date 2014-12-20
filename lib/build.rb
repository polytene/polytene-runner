module Polytene
  class Build
    TIMEOUT = 7200
    POLYTENE_VARS_FILE_NAME = 'polytene-runner.yml'
    POLYTENE_ARTIFACTS_DIR = 'polytene'

    attr_accessor :id, :build_status, :deployment_status, :gitlab_ci_project_id, :polytene_project_id, :gitlab_deploy_key, :sha, :ref, :commands, :repo_url
    attr_accessor :run_at
    attr_accessor :deployment_finished_at
    attr_accessor :polytene_artifacts_dir

    def initialize(data)
      @commands = data[:commands].to_a
      @ref = data[:ref] #here ref is name of branch
      @sha = data[:sha] #commit
      @id = data[:id]
      @polytene_project_id = data[:polytene_project_id]
      @gitlab_ci_project_id = data[:gitlab_ci_project_id]
      @repo_url = data[:repo_url]
      @timeout = data[:timeout] || TIMEOUT
      @build_status = data[:build_status]
      @deployment_status = data[:deployment_status]
      @gitlab_deploy_key = data[:gitlab_deploy_key]
      @default_environment = data[:default_environment]
      @polytene_artifacts_dir = data[:polytene_artifacts_dir]

      prepare_polytene_vars_file
    end

    def polytene_vars
      {'polytene_runner_branch_name' => @ref, 'polytene_runner_commit_sha' => @sha, 'polytene_runner_repo_url' => @repo_url, 'polytene_runner_environment' => @default_environment}
    end

    def prepare_polytene_vars_file
      @project_polytene_runner_tmp_file = Tempfile.new(POLYTENE_VARS_FILE_NAME)
      @project_polytene_runner_tmp_file.write(Psych.dump(polytene_vars))
      @project_polytene_runner_tmp_file.close
    end

    def prepare_deployment_executor
      #removing old repo
      FileUtils.rm_rf(project_dir)
      FileUtils.mkdir_p(project_dir)

      @run_file = Tempfile.new("executor")
      @run_file.chmod(0700)

      #Adding native commands
      @commands.unshift(command.archive_repo(project_dir, @sha, polytene_artifacts_dir))
      @commands.unshift(command.copy_polytene_runner_file_cmd(@project_polytene_runner_tmp_file.path, polytene_vars_file_path))
      @commands.unshift(command.create_artifacts_dir(polytene_artifacts_dir))
      @commands.unshift(command.checkout_cmd(project_dir, @sha))
      @commands.unshift(command.make_sure_repo_is_here_cmd(project_dir))
      @commands.unshift(command.clone_cmd(config.builds_dir, @repo_url, project_dir, @sha))

      @run_file.puts "#!/bin/bash"
      @run_file.puts "trap 'echo \"FAILED: line $LINENO, exit code $?\"; exit 1;' ERR"

      @commands.each do |command|
        command.strip!
        @run_file.puts "echo #{command.shellescape}"
        @run_file.puts(command)
      end
      @run_file.close
    end

    def run_deployment
      @run_at = Time.now
      prepare_deployment_executor

      Bundler.with_clean_env { execute("setsid #{@run_file.path}") }
    end

    def state
      return :succeeded if success?
      return :failed if failed?
      :running
    end

    def completed?
      @process.exited?
    end

    def success?
      return nil unless completed?
      @process.exit_code == 0
    end

    def failed?
      return nil unless completed?
      @process.exit_code != 0
    end

    def running?
      @process.alive?
    end

    def abort(reason = nil)
      @process.stop

      case reason
      when 'timeout' then LOGGER.info("Deployment aborted because of timeout. Execution took longer then #{@timeout} seconds.")
      when 'aborted' then LOGGER.info("Deployment aborted because of user action.")
      else LOGGER.info("Deployment aborted because of unknown error.")
      end
    end

    def stderr_trace
      if @tmp_file_stderr && File.readable?(@tmp_file_stderr.path)
        File.read(@tmp_file_stderr.path)
      else
        ''
      end
    end

    def stdout_trace
      if @tmp_file_stdout && File.readable?(@tmp_file_stdout.path)
        File.read(@tmp_file_stdout.path)
      else
        ''
      end
    end

    def cleanup
      @tmp_file_stdout.close
      @tmp_file_stdout.unlink

      @tmp_file_stderr.close
      @tmp_file_stderr.unlink

      @run_file.unlink

      @project_polytene_runner_tmp_file.unlink
    end

    def running_too_long?
      if @run_at && @timeout
        @run_at + @timeout < Time.now
      else
        false
      end
    end

    private

    def polytene_vars_file_path
      File.join(polytene_artifacts_dir, POLYTENE_VARS_FILE_NAME)
    end

    def execute(cmd)
      @process = ChildProcess.build('bash', '--login', '-c', cmd.strip)

      @tmp_file_stdout = Tempfile.new("polytene-stdout-deployment-#{@id}-", :encoding => 'utf-8')
      @tmp_file_stderr = Tempfile.new("polytene-stderr-deployment-#{@id}-", :encoding => 'utf-8')

      @process.io.stdout = @tmp_file_stdout
      @process.io.stderr = @tmp_file_stderr

      @process.cwd = project_dir

      @process.start
    end
 
    def polytene_artifacts_dir
      File.join(project_dir, @polytene_artifacts_dir || POLYTENE_ARTIFACTS_DIR)
    end

    def command
      @command ||= Polytene::Command.new
    end

    def repo_exists?
      File.exists?(File.join(project_dir, '.git'))
    end

    def config
      @config ||= Polytene::Config.new
    end

    def project_dir_name
      "project-#{@polytene_project_id}"
    end

    def project_dir
      File.join(config.builds_dir, project_dir_name)
    end
  end
end
