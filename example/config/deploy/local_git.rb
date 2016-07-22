set :bundle_rsync_scm, 'local_git'
set :repo_url, "#{ENV['PWD']}/try_rails4" # git clone git@github.com:sonots/try_rails4.git

role :app, ['127.0.0.1']
