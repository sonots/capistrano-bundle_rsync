unless defined?(Capistrano::BundleRsync::TASK_LOADED) # protect multiple loads
Capistrano::BundleRsync::TASK_LOADED = true
require 'fileutils'
require 'parallel'

namespace :bundle_rsync do
  def config
    Capistrano::BundleRsync::Config
  end

  namespace :bundler do
    task :install do
      hosts = release_roles(:all)
      on hosts, in: :groups, limit: config.max_parallels(hosts) do
        within release_path do
          execute :mkdir, '-p', '.bundle'
        end
      end

      run_locally do
        Bundler.with_clean_env do
          execute :bundle, "--gemfile #{config.local_release_path}/Gemfile --deployment --quiet --path #{config.local_bundle_path} --without development test --binstubs=#{config.local_bin_path}"
        end

        lines = <<-EOS
---
BUNDLE_FROZEN: '1'
BUNDLE_PATH: #{shared_path.join('bundle')}
BUNDLE_WITHOUT: development:test
BUNDLE_DISABLE_SHARED_GEMS: '1'
BUNDLE_BIN: #{shared_path.join('bin')}
        EOS
        bundle_config_path = "#{config.local_base_path}/bundle_config"
        File.open(bundle_config_path, "w") {|file| file.print(lines) }

        rsync_options = config.rsync_options
        Parallel.each(hosts, in_processes: config.max_parallels(hosts)) do |host|
          ssh = config.build_ssh_command(host)
          if config_files = config.config_files
            config_files.each do |config_file|
              basename = File.basename(config_file)
              execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{config_file} #{host}:#{release_path}/config/#{basename}"
            end
          end

          execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{config.local_bundle_path}/ #{host}:#{shared_path}/bundle/"
          execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{config.local_bin_path}/ #{host}:#{shared_path}/bin/"
          execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{bundle_config_path} #{host}:#{release_path}/.bundle/config"
        end

        FileUtils.rm_rf(config.local_release_path)
      end
    end
  end

  desc 'Check that the repository is reachable'
  task :check do
    fetch(:branch)
    run_locally do
      exit 1 unless execute("git ls-remote #{repo_url}")
      execute("mkdir -p #{config.local_base_path}")
    end
  end

  desc 'Clone the repo to the cache'
  task :clone do
    run_locally do
      if File.exist?("#{config.local_repo_path}/HEAD")
        info t(:mirror_exists, at: config.local_repo_path)
      else
        execute :git, :clone, '--mirror', repo_url, config.local_repo_path
      end
    end
  end

  desc 'Update the repo mirror to reflect the origin state'
  task update: :'bundle_rsync:clone' do
    run_locally do
      within config.local_repo_path do
        execute :git, :remote, :update
      end
    end
  end

  desc 'Copy repo to releases'
  task create_release: :'bundle_rsync:update' do
    hosts = release_roles(:all)
    run_locally do
      execute "mkdir -p #{config.local_release_path}"

      within config.local_repo_path do
        execute :git, :archive, fetch(:branch), '| tar -x -C', "#{config.local_release_path}"
      end

      rsync_options = config.rsync_options
      Parallel.each(hosts, in_processes: config.max_parallels(hosts)) do |host|
        ssh = config.build_ssh_command(host)
        execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{config.local_release_path}/ #{host}:#{release_path}/"
      end
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    run_locally do
      within config.local_repo_path do
        set :current_revision, capture(:git, "rev-parse --short #{fetch(:branch)}")
      end
    end
  end

  before 'deploy:updated', 'bundle_rsync:bundler:install'
end

namespace :load do
  task :defaults do
    set :bundle_rsync_local_base_path, nil
    set :bundle_rsync_local_repo_path, nil
    set :bundle_rsync_local_release_path, nil
    set :bundle_rsync_local_bundle_path, nil
    set :bundle_rsync_local_bin_path, nil
    set :bundle_rsync_config_files, nil
    set :bundle_rsync_ssh_options, nil # Default to be ssh_options. Note: :password is not supported.
    set :bundle_rsync_max_parallels, nil
  end
end
end
