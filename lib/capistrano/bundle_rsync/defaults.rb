module Capistrano
  module BundleRsync
    module Defaults
      def self.set_defaults
        set_if_empty :bundle_rsync_scm, 'git'

        set_if_empty :bundle_rsync_local_base_path, "#{Dir::pwd}/.local_repo"
        set_if_empty :bundle_rsync_local_mirror_path, -> { "#{fetch(:bundle_rsync_local_base_path)}/mirror" }
        set_if_empty :bundle_rsync_local_releases_path, -> { "#{fetch(:bundle_rsync_local_base_path)}/releases" }
        set_if_empty :bundle_rsync_local_release_path, -> {
          if fetch(:bundle_rsync_scm).to_s == 'local_git'
            repo_url
          else # git (default)
            "#{fetch(:bundle_rsync_local_releases_path)}/#{Time.new.strftime('%Y%m%d%H%M%S')}"
          end
        }
        set_if_empty :bundle_rsync_local_bundle_path, -> { "#{fetch(:bundle_rsync_local_base_path)}/bundle" }

        set_if_empty :bundle_rsync_ssh_options, -> { fetch(:ssh_options, {}) }
        set_if_empty :bundle_rsync_keep_releases, -> { fetch(:keep_releases) }

        set_if_empty :bundle_rsync_rsync_bwlimit, nil
        set_if_empty :bundle_rsync_rsync_options, -> {
          bwlimit = fetch(:bundle_rsync_rsync_bwlimit)

          bwlimit_option = bwlimit ? " --bwlimit #{bwlimit}" : ""
          "-az --delete#{bwlimit_option}"
        }

        set_if_empty :bundle_rsync_config_files, nil
        set_if_empty :bundle_rsync_shared_dirs, nil

        set_if_empty :bundle_rsync_skip_bundle, false # NOTE: This is secret option
        set_if_empty :bundle_rsync_bundle_install_jobs, nil
        set_if_empty :bundle_rsync_bundle_install_standalone, nil
        set_if_empty :bundle_rsync_bundle_without, [:development, :test]
      end
    end
  end
end
