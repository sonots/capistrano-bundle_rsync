set :bundle_rsync_scm, 'git'
set :repo_url, 'https://github.com/sonots/try_rails4'
set :branch, 'master'
set :bundle_rsync_skip_bundle, true

role :app, ['127.0.0.1']
