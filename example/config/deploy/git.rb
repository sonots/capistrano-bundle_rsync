if Gem::Version.new(Capistrano::VERSION) < Gem::Version.new('3.7.0')
  set :scm, :bundle_rsync
end

set :bundle_rsync_scm, 'git'
set :repo_url, 'https://github.com/sonots/try_rails4'
set :branch, 'master'

role :app, ['127.0.0.1']

task :precompile do
  config = Capistrano::BundleRsync::Config
  run_locally do
    Bundler.with_clean_env do
      within config.local_release_path do
        execute :bundle, 'install' # install development gems
        execute :bundle, 'exec rake assets:precompile'
      end
    end

    hosts = release_roles(:all)
    Parallel.each(hosts, in_threads: config.max_parallels(hosts)) do |host|
      execute "rsync -az -e ssh #{config.local_release_path}/public/ #{host}:#{fetch(:deploy_to)}/shared/public"
    end
  end
end

before "bundle_rsync:rsync_release", "precompile"
