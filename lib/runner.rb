module Polytene
  class Runner
    
    def run
      loop do
        if running?
          abort_if_timeout
          process_deployment
        else
          fetch_build_and_start_deployment
        end
        sleep 5
      end
    end

    private

    def running?
      @current_build
    end

    def abort_if_timeout
      @current_build.abort('timeout') if @current_build.running? && @current_build.running_too_long?
    end

    def process_deployment
      do_cleanup = false

      LOGGER.info("Next iteration for #{@current_build.id}...")

      if @current_build.completed?
        @current_build.deployment_finished_at ||= Time.now 
        do_cleanup = true
      end

      cleanup if update_build && do_cleanup
    end

    def update_build
      case network.update_build(@current_build.id, @current_build.state, @current_build.stdout_trace, @current_build.stderr_trace, @current_build.deployment_finished_at)
      when :success
        true
      when :aborted
        @current_build.abort('aborted')
        true
      when :failure
        false
      end
    end

    def fetch_build_and_start_deployment
      LOGGER.info("Getting job...")

      build_data = network.get_build

      if build_data
        @current_build = Polytene::Build.new(build_data)
        LOGGER.info("Starting new deployment #{@current_build.id}")
        @current_build.run_deployment
        LOGGER.info("Deployment #{@current_build.id} started.")
      else
        LOGGER.info("Nothing found...")
        false
      end
    end

    def network
      @network ||= Network.new
    end

    private

    def cleanup
      LOGGER.info("Completed build #{@current_build.id}, #{@current_build.state}. Cleaning.")
      
      @current_build.cleanup
      @current_build = nil
    end
  end
end
