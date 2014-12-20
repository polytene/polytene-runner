require_relative 'spec_helper'
require_relative '../lib/bootstrap'

describe 'Build' do
  describe :run_deployment do

    before(:all) do
      @build = Polytene::Build.new(build_data)
      @build.run_deployment
      
      loop do
        break if @build.completed?
      end
    end
    
    it { expect(@build.stdout_trace).to include 'bundle' }
    it { expect(@build.stdout_trace).to include 'HEAD is now at 0af5cd' }
    it { expect(@build.stderr_trace).to include 'detached HEAD' }

    it { expect(@build.state).to eq(:succeeded) }

    it { expect(File).to exist(File.join(@build.send('polytene_artifacts_dir'), "#{@build.sha}.zip"))}

    it { expect(File).to exist(@build.send('polytene_vars_file_path'))}
    it { expect(Psych.load_file(@build.send('polytene_vars_file_path'))['polytene_runner_commit_sha']).to eq('0af5cdc4cda89e7274dca33fcb921013f54b7934')}
    it { expect(Psych.load_file(@build.send('polytene_vars_file_path'))['polytene_runner_branch_name']).to eq('master')}

    it { expect(@build.polytene_vars).to have_key('polytene_runner_branch_name')}
    it { expect(@build.polytene_vars).to have_key('polytene_runner_commit_sha')}
    it { expect(@build.polytene_vars).to have_key('polytene_runner_repo_url')}
    it { expect(@build.polytene_vars).to have_key('polytene_runner_environment')}

    it { expect(@build.polytene_vars.values).not_to include(nil) }
    it { expect(@build.polytene_vars.values).not_to include("") }

    it { expect(@build.polytene_vars['polytene_runner_branch_name']).to eq('master') }
    it { expect(@build.polytene_vars['polytene_runner_commit_sha']).to eq('0af5cdc4cda89e7274dca33fcb921013f54b7934') }
  end

  def build_data
    {
      ref: 'master',
      commands: ['bundle'],
      polytene_project_id: 0,
      id: 9312,
      sha: '0af5cdc4cda89e7274dca33fcb921013f54b7934',
      repo_url: 'git@github.com:stricte/2k-djkmm.git',
      default_environment: 'production',
      polytene_artifacts_dir: 'polytene'
    }
  end
end
