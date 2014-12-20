module Polytene
  class SSHKey
    def initialize
      @key = ::SSHKey.new(File.read(config.ssh_private_key_path))
    end

    def ssh_public_key
      @key.ssh_public_key
    end

    def private_key
      @key.private_key
    end

    def config
      @config ||= Polytene::Config.new
    end

    def self.valid_key?(path)
      ::SSHKey.new(File.read(ssh_private_key_path)) rescue false
    end
  end
end
