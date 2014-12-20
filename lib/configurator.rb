module Polytene
  class Configurator

    REQUIRED_CONFIG_KEYS = %w(ssh_private_key_path polytene_url token)

    def configure
      configure_polytene_url
      configure_polytene_token
      configure_ssh_keys

      if valid?
        print "Runner has been successfully configured. Feel free to start it. Sending proof of life..."
        puts send_proof_of_life ? 'Proved.' : 'Cant send proof.'
        exit 0
      else
        puts "Runner is not configured. Configure him before start"
        exit 1
      end
    end

    def valid?
      (REQUIRED_CONFIG_KEYS - config.config.keys).count > 0 ? false : true
    end

    def validate
      missing_keys = (REQUIRED_CONFIG_KEYS - config.config.keys)
      if missing_keys.count > 0
        puts "Config is not ok. You need to set following elements: #{missing_keys.join(", ")}"
      else
        puts "Config is ok. Feel free to start runner."
      end
    end

    private

    def send_proof_of_life
      Polytene::Network.new.proof_of_life
    end

    def configure_ssh_keys
      puts 'Please provide path to ssh private key path'
      ssh_private_key_path = $stdin.gets.chomp

      if File.file?(ssh_private_key_path)
        begin
          Polytene::SSHKey.valid_key?(ssh_private_key_path)
          config.write('ssh_private_key_path', File.absolute_path(ssh_private_key_path))
        rescue
          puts "Provided path do not represent ssh private key"
          exit 1
        end
      else
        puts "Provided path do not represent file"
        exit 1
      end
    end

    def configure_polytene_url
      puts 'Please enter the polytene URL (e.g. http://polytene.some.place.org )'
      url = $stdin.gets.chomp

      config.write('polytene_url', url)
    end

    def configure_polytene_token
      puts 'Please enter the private token for this runner generated in polytene panel'
      token = $stdin.gets.chomp

      config.write('token', token)
    end

    def config
      @config ||= Polytene::Config.new
    end
  end
end
