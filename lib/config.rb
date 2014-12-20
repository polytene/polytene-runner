module Polytene
  class Config
    attr_reader :config

    def initialize
      if File.exists?(config_path)
        @config = Psych.load_file(config_path)
      else
        @config = {}
      end
    end

    def ssh_public_key_path
      @config['ssh_public_key_path']
    end

    def ssh_private_key_path
      @config['ssh_private_key_path']
    end

    def token
      @config['token']
    end

    def polytene_url
      @config['polytene_url']
    end

    def write(key, value)
      @config[key] = value

      File.open(config_path, "w") do |f|
        f.write(Psych.dump(@config))
      end
    end

    def builds_dir
      File.join(ROOT_PATH, 'tmp', 'builds')
    end

    def config_path
      File.join(ROOT_PATH, 'config.yml')
    end
  end
end
