module Capistrano::BundleRsync
  class Config
    def self.local_base_path
      @local_base_path ||= fetch(:bundle_rsync_local_base_path) || "#{Dir::pwd}/.local_repo"
    end

    def self.local_repo_path
      @local_repo_path ||= fetch(:bundle_rsync_local_repo_path) || "#{local_base_path}/repo"
    end

    def self.local_release_path
      @local_release_path ||= fetch(:bundle_rsync_local_release_path) || "#{local_base_path}/release_#{Time.now.to_i}"
    end

    def self.local_bundle_path
      @local_bundle_path ||= fetch(:bundle_rsync_local_bundle_path) || "#{local_base_path}/bundle"
    end

    def self.local_bin_path
      @local_bin_path ||= fetch(:bundle_rsync_local_bin_path) || "#{local_base_path}/bin"
    end

    def self.config_files
      return nil unless config_files = fetch(:bundle_rsync_config_files)
      config_files.is_a?(Array) ? config_files : [config_files]
    end

    # Build ssh command options for rsync
    #
    # First, search available user and keys configurations for each role:
    #
    #     role :app, ['hostname'], {
    #       user: username,
    #       keys: File.expand_path('~/.ssh/id_rsa'),
    #       port: 22,
    #     }
    #
    # If not available, look :bundle_rsync_ssh_options:
    #
    #     set :bundle_rsync_ssh_options {
    #       user: username,
    #       keys: [File.expand_path('~/.ssh/id_rsa')],
    #       port: 22,
    #     }
    #
    # If :bundle_rsync_ssh_options are not available also, look :ssh_options finally:
    #
    #     set :ssh_options {
    #       user: username,
    #       keys: [File.expand_path('~/.ssh/id_rsa')],
    #       port: 22,
    #     }
    #
    # `keys` can be a string or an array.
    # NOTE: :password is not supported.
    def self.build_ssh_command(host)
      user_opt, key_opt, port_opt = "", "", ""
      ssh_options = fetch(:bundle_rsync_ssh_options) || fetch(:ssh_options)
      if user = host.user || ssh_options[:user]
        user_opt = " -l #{user}"
      end
      if keys = (host.keys.empty? ? ssh_options[:keys] : host.keys)
        keys = keys.is_a?(Array) ? keys : [keys]
        key_opt = keys.map {|key| " -i #{key}" }.join("")
      end
      if port = host.port || ssh_options[:port]
        port_opt = " -p #{port}"
      end
      "ssh#{user_opt}#{key_opt}#{port_opt}"
    end

    # Fetch the :bundle_rsync_max_parallels,
    # where the default is the number of hosts
    def self.max_parallels(hosts)
      fetch(:bundle_rsync_max_parallels) || hosts.size
    end
  end
end
