module Polytene
  class Network
    include HTTParty

    format :json

    def get_build
      response = self.class.post(base_api_url + '/runners/get_job.json', :body => {:private_token => config.token})

      if response.code == 201
        {
          id: response['id'],
          build_status: response['status'],
          deployment_status: response['deployment_status'],
          gitlab_ci_project_id: response['gitlab_ci_project_id'],
          polytene_project_id: response['project_id'],
          sha: response['sha'],
          ref: response['ref'],
          commands: response['project_branch']['deployment_script'].lines,
          repo_url: response['project']['gitlab_ssh_url_to_repo'],
          default_environment: response['project_branch']['default_environment'],
          polytene_artifacts_dir: response['project_branch']['polytene_artifacts_dir']
        }
      end
    end

    def update_build(id, state, stdout_trace, stderr_trace, deployment_finished_at = nil)
      body = {
        build_id: id,
        state: state,
        stdout_trace: stdout_trace.force_encoding(Encoding::UTF_8),
        stderr_trace: stderr_trace.force_encoding(Encoding::UTF_8),
        deployment_finished_at: deployment_finished_at,
        private_token: config.token
      }

      response = self.class.post(base_api_url + "/runners/update_build.json", body: body)

      LOGGER.info("Updating results for #{id}... Got #{response.code}")

      case response.code
      when 201
        :success
      when 404
        :aborted
      else
        :failure
      end
    end

    def proof_of_life
      response = self.class.post(base_api_url + '/runners/proof_of_life.json', body: {:private_token => config.token, :public_key => sshkey.ssh_public_key})

      response.code == 201 ? true : false
    end

    private

    def sshkey
      @sshkey ||= Polytene::SSHKey.new
    end

    def base_api_url
      config.polytene_url + '/api/v1'
    end

    def config
      @config ||= Polytene::Config.new
    end

  end
end
