module Polytene
  class Command
    def checkout_cmd(project_dir, sha)
      cmd = []
      cmd << "cd #{project_dir}"
      cmd << "git reset --hard"
      cmd << "git checkout #{sha}"
      cmd.join(" && ")
    end

    def clone_cmd(builds_dir, repo_url, project_dir, sha)
      cmd = []
      cmd << "cd #{builds_dir}"
      cmd << "git clone #{repo_url} #{project_dir}"
      cmd << "cd #{project_dir}"
      cmd << "git checkout #{sha}"
      cmd.join(" && ")
    end

    def make_sure_repo_is_here_cmd(project_dir)
      cmd = []
      cmd << "if [ ! -d #{File.join(project_dir, '.git')} ]; then exit 1; fi;"
      cmd.join(" && ")
    end

    def copy_polytene_runner_file_cmd(project_polytene_runner_tmp_file_path, destination)
      cmd = []
      cmd << "cp #{project_polytene_runner_tmp_file_path} #{destination}"
      cmd.join(" && ")
    end

    def archive_repo(project_dir, sha, destination)
      cmd = []
      cmd << "cd #{project_dir}"
      cmd << "git archive -o #{File.join(destination, sha)}.zip #{sha}"
      cmd.join(" && ")
    end

    def create_artifacts_dir(dir_path)
      cmd = []
      cmd << "mkdir -p #{dir_path}"
      cmd.join(" && ")
    end
  end
end
