require 'capistrano/bundle_rsync/base'
require 'capistrano/configuration/filter'

class Capistrano::BundleRsync::Bundler < Capistrano::BundleRsync::Base
  def install
    within config.local_release_path do
      Bundler.with_clean_env do
        with bundle_app_config: config.local_base_path, rbenv_version: nil, rbenv_dir: nil do
          bundle_commands = if test :rbenv, 'version'
            %w[rbenv exec bundle]
          else
            %w[bundle]
          end

          execute *bundle_commands, 'config', '--local', 'deployment', 'true'
          execute *bundle_commands, 'config', '--local', 'path', config.local_bundle_path
          execute *bundle_commands, 'config', '--local', 'without', *config.bundle_without

          opts = ['--quiet']
          if jobs = config.bundle_install_jobs
            opts.push('--jobs', jobs)
          end

          if standalone = config.bundle_install_standalone_option
            opts.push(standalone)
          end

          execute *bundle_commands, *opts
          execute :rm, "#{config.local_base_path}/config"
        end
      end
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
BUNDLE_WITHOUT: #{config.bundle_without.join(':')}
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
  end
end
