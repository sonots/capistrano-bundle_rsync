set :bundle_rsync_scm, 'local_git'
set :repo_url, "#{ENV['HOME']}/src/github.com/sonots/try_rails4"

role :app, ['127.0.0.1']
