unless defined?(Capistrano::BundleRsync::TASK_LOADED) # protect multiple loads
Capistrano::BundleRsync::TASK_LOADED = true
require 'fileutils'
require 'parallel'
require 'capistrano/bundle_rsync/bundler'

namespace :bundle_rsync do
  def bundler
    @bundler ||= Capistrano::BundleRsync::Bundler.new(self)
  end

  def scm
    @scm ||=
      if fetch(:bundle_rsync_scm).to_s == 'local_git'
        require 'capistrano/bundle_rsync/local_git'
        set :bundle_rsync_local_release_path, repo_url
        Capistrano::BundleRsync::LocalGit.new(self)
      else
        require 'capistrano/bundle_rsync/git'
        Capistrano::BundleRsync::Git.new(self)
      end
  end

  namespace :bundler do
    task :install do
      bundler.prepare
      run_locally do
        bundler.install
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

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    run_locally do
      scm.set_current_revision
    end
  end

  before 'deploy:updated', 'bundle_rsync:bundler:install'
end
end
