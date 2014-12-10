unless defined?(Capistrano::BundleRsync::TASK_LOADED) # protect multiple loads
Capistrano::BundleRsync::TASK_LOADED = true
require 'fileutils'
require 'parallel'
require 'capistrano/bundle_rsync/bundler'

namespace :bundle_rsync do
  def config
    Capistrano::BundleRsync::Config
  end

  def bundler
    @bundler ||= Capistrano::BundleRsync::Bundler.new(self)
  end

  def scm
    @scm ||=
      if fetch(:bundle_rsync_scm).to_s == 'local_git'
        require 'capistrano/bundle_rsync/local_git'
        Capistrano::BundleRsync::LocalGit.new(self)
      else
        require 'capistrano/bundle_rsync/git'
        Capistrano::BundleRsync::Git.new(self)
      end
  end

  namespace :bundler do
    task :install do
      run_locally do
        if config.skip_bundle
          info "Skip bundle"
        else
          bundler.install
        end
      end
    end

    task :rsync do
      run_locally do
        if config.skip_bundle
          info "Skip bundle rsync"
        else
          bundler.rsync
        end
      end
    end
  end

  desc 'Check that the repository is reachable'
  task :check do
    run_locally do
      scm.check
    end
  end

  desc 'Clone the repo to the cache'
  task :clone do
    run_locally do
      scm.clone
    end
  end

  desc 'Update the repo mirror to reflect the origin state'
  task update: :'bundle_rsync:clone' do
    run_locally do
      scm.update
    end
  end

  desc 'Copy repo to releases'
  task create_release: :'bundle_rsync:update' do
    run_locally do
      scm.create_release
    end
  end

  # additional extra tasks of bundle_rsync scm
  desc 'Rsync releases'
  task :rsync_release do
    run_locally do
      scm.rsync_release
    end
  end

  # additional extra tasks of bundle_rsync scm
  desc 'Rsync shared'
  task :rsync_shared do
    run_locally do
      scm.rsync_shared
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    run_locally do
      scm.set_current_revision
    end
  end

  after 'bundle_rsync:create_release', 'bundle_rsync:bundler:install'
  after 'bundle_rsync:bundler:install', 'bundle_rsync:rsync_release'
  after 'bundle_rsync:rsync_release', 'bundle_rsync:rsync_shared'
  after 'bundle_rsync:rsync_shared', 'bundle_rsync:bundler:rsync'
end
end
