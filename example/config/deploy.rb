set :user, `whoami`.chomp
set :ssh_options, user: ENV['USER'], keys: [File.expand_path('~/.ssh/id_rsa')]
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

set :linked_dirs, %w(log tmp/pids vendor/bundle)
set :keep_releases, 5
set :rbenv_type, :user
set :rbenv_ruby, RUBY_VERSION # '2.1.5'
set :deploy_to, "#{ENV['HOME']}/sample"

if Gem::Version.new(Capistrano::VERSION) < Gem::Version.new('3.7.0')
  set :scm, :bundle_rsync
end

set :bundle_rsync_max_parallels, ENV['PARA']
set :bundle_rsync_rsync_bwlimit, ENV['BWLIMIT'] # like 20000
set :bundle_rsync_shared_dirs, File.expand_path('..', __dir__) # rsync example to shared/example
set :bundle_rsync_rsync_options, "-az --delete --exclude=.git"

namespace :deploy do
  desc 'Restart web application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # execute some restart code
    end
  end

  after :finishing, 'deploy:cleanup'
  # after :publishing, :restart
end
