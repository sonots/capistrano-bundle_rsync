require 'capistrano/bundle_rsync/base'
require 'capistrano/configuration/filter'

class Capistrano::BundleRsync::Bundler < Capistrano::BundleRsync::Base
  def install
    Bundler.with_clean_env do
      execute :bundle, "--gemfile #{config.local_release_path}/Gemfile --deployment --quiet --path #{config.local_bundle_path} --without development test"
      execute :rm, "#{config.local_release_path}/.bundle/config"
    end
  end

  def rsync
    hosts = release_roles(:all)
    on hosts, in: :groups, limit: config.max_parallels(hosts) do
      within release_path do
        execute :mkdir, '-p', '.bundle'
      end
    end

    lines = <<-EOS
---
BUNDLE_FROZEN: '1'
BUNDLE_PATH: #{shared_path.join('bundle')}
BUNDLE_WITHOUT: development:test
BUNDLE_DISABLE_SHARED_GEMS: '1'
BUNDLE_BIN: #{release_path.join('bin')}
    EOS
    # BUNDLE_BIN requires rbenv-binstubs plugin to make it effectively work
    bundle_config_path = "#{config.local_base_path}/bundle_config"
    File.open(bundle_config_path, "w") {|file| file.print(lines) }

    hosts = ::Capistrano::Configuration.env.filter(hosts)
    rsync_options = config.rsync_options
    Parallel.each(hosts, in_threads: config.max_parallels(hosts)) do |host|
      ssh = config.build_ssh_command(host)
      execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{config.local_bundle_path}/ #{host}:#{shared_path}/bundle/"
      execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{bundle_config_path} #{host}:#{release_path}/.bundle/config"
    end

    # Do not remove if :bundle_rsync_local_release_path is directly specified
    # because releases/#{datetime} directories are not created in such case. 
    # Note that :bundle_rsync_local_release_path is automatically set when `local_git` scm is used. 
    unless fetch(:bundle_rsync_local_release_path)
      releases = capture(:ls, '-x', config.local_releases_path).split
      if releases.count >= config.keep_releases
        directories = (releases - releases.last(config.keep_releases))
        if directories.any?
          directories_str = directories.map do |release|
            File.join(config.local_releases_path, release)
          end.join(" ")
          execute :rm, '-rf', directories_str
        end
      end
    end
  end
end
