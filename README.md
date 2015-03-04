# Capistrano::BundleRsync for Capistrano v3

Deploy an application and bundled gems via rsync

## What is this for?

Capistrano::BundleRsync builds (bundle) gems only once on a deploy machine and transfers gems to your production machines via rsync, which saves you from building gems on each your production machine. 

Also saves you from having to install Git and Build Tools on your production machine.

## How it works

Capistrano::BundleRsync works as followings:

1. Do `git clone --mirror URL .local_repo/mirror` on a deploy (local) machine.
2. Extract a branch by `git archive {branch}` to `.local_repo/releases/{datetime}`
3. Do `bundle --without development test --path .local_repo/bundle` on a deploy (local) machine.
4. Deploy the `release` directory to remote machines by `rsync`. 
5. Deploy the `bundle` directory to remote machines by `rsync`.

## Prerequisites

The deploy machine and remote machines must be on same architectures (i386, x86\_64) because
C exntension gems are built on the deploy machine and transfered by rsync. 

Requiremens on remote machines:

1. rbenv (rvm should work, but not verified)
2. ruby

Requirements on a deploy machine:

1. rbenv (rvm should work, but not verified)
2. git
3. Build Tools required to build C exntension gems (like gcc).
4. A ruby to execute capistrano (you may use the ruby of 5.)
5. The same ruby used at your remote machines
6. A ssh key to login to your remote machines via ssh (Passowrd authentication is not supported)

Notice that it is not required to have Git and Build Tools on each remote machine. 

## Configuration

Set Capistrano variables with `set name, value`.

Name          | Default | Description
--------------|---------|------------
repo_url      | `.` | The path or URL to a Git repository to clone from.  
branch        | `master` | The Git branch to checkout.  
ssh_options   | `{}`  | Configuration of ssh :user and :keys.
keep\_releases | 5 | The number of releases to keep.
scm | nil | Must be `bundle_rsync` to use capistrano-bundle_rsync.
bundle_rsync_scm | `git` | SCM Strategy inside `bundle_rsync`. `git` uses git. `local_git` also uses git, but it enables to rsync the git repository located on local path directly without git clone. `repo_url` must be the local directory path to use `local_git`.
bundle_rsync_local_base_path   | `$(pwd)/.local_repo` | The base directory to clone repository
bundle_rsync_local_mirror_path | `#{base_path}/mirror"` | Path where to mirror your repository
bundle_rsync_local_releases_path | `"#{base_path}/releases"` | Path of the directory to checkout your repository
bundle_rsync_local_release_path | `"#{releases_path}/#{datetime}"` | Path to checkout your repository (releases_path + release_name). If you specify this, `keep_releases` for local releases path is disabled because `datetime` directories are no longer created. This parameter is set as `repo_url` in the case of `local_git` as default. 
bundle_rsync_local_bundle_path | `"#{base_path}/bundle"` | Path where to bundle install gems.
bundle_rsync_ssh_options | `ssh_options` | Configuration of ssh for rsync. Default uses the value of `ssh_options`
bundle_rsync_keep_releases | `keep_releases` | The number of releases to keep on .local_repo
bundle_rsync_max_parallels | number of hosts | Number of concurrency. The default is the number of hosts to deploy.
bundle_rsync_rsync_bwlimit | nil | Configuration of rsync --bwlimit (KBPS) option. Not Avabile if `bundle_rsync_rsync_options` is specified.
bundle_rsync_rsync_options | `-az --delete` | Configuration of rsync options.
bundle_rsync_config_files | `nil` | Additional files to rsync. Specified files are copied into `config` directory.
bundle_rsync_shared_dirs | `nil` | Additional directories to rsync. Specified directories are copied into `shared` directory.
bundle_rsync_skip_bundle | false | (Secret option) Do not `bundle` and rsync bundle.

## Task Orders

```
$ cap stage deploy --trace | grep Execute
** Execute bundle_rsync:check
** Execute bundle_rsync:clone
** Execute bundle_rsync:update
** Execute bundle_rsync:create_release
** Execute bundle_rsync:bundler:install
** Execute bundle_rsync:rsync_release
** Execute bundle_rsync:rsync_shared
** Execute bundle_rsync:bundler:rsync
** Execute bundle_rsync:set_current_revision
```

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-bundle_rsync'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-bundle_rsync

## Usage

Add followings to your Gemfile (capistrano-rvm should work, but not verified):

```ruby
gem 'capistrano'
gem 'capistrano-rbenv'
gem 'capistrano-bundle_rsync'
```

Run `bundle exec cap install`. 

```bash
$ bundle
$ bundle exec cap install
```

This creates the following files:

```
├── Capfile
├── config
│   ├── deploy
│   │   ├── production.rb
│   │   └── staging.rb
│   └── deploy.rb
└── lib
    └── capistrano
            └── tasks
```

To create different stages:

```bash
$ bundle exec cap install STAGES=localhost,sandbox,qa,production
```

Edit Capfile:

```ruby
# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
require 'capistrano/rbenv'
require 'capistrano/bundle_rsync'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
```

Edit `config/deploy/localhost.rb` as followings for example:

```ruby
set :branch, ENV['BRANCH'] || 'master'
set :rbenv_type, :user
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle tmp/run)
set :keep_releases, 5
set :scm, :bundle_rsync # Need this
set :bundle_rsync_max_parallels, ENV['PARA']
set :bundle_rsync_rsync_bwlimit, ENV['BWLIMIT'] # like 20000
set :bundle_rsync_config_files, ['~/config/database.yml']

set :application, 'sample'
set :repo_url, "git@github.com:sonots/rails-sample.git"
set :deploy_to, "/home/sonots/sample"
set :rbenv_ruby, "2.1.2" # Required on both deploy machine and remote machines
set :ssh_options, user: 'sonots', keys: [File.expand_path('~/.ssh/id_rsa'), File.expand_path('~/.ssh/id_dsa')]

role :app, ['127.0.0.1']
```

Deploy by following command:

```bash
$ bundle exec cap localhost deploy
```

## Run a custom task before rsyncing

For example, if you want to precompile rails assets before rsyncing,
you may add your own task before `bundle_rsync:rsync_release`.

```ruby
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
      execute "rsync -az -e ssh #{config.release_path}/public/ #{host}:#{fetch(:deploy_to)}/shared/public"
    end
  end
end

before "bundle_rsync:rsync_release", "precompile"
```

## local_git scm

`bundle_rsync` supports `local_git` SCM strategy in addition to `git`.

`local_git` strategy enables to rsync the git repository located on a local path without git clone. You may find as this is useful when you need to replace files locally without commit beforehand (for example, for password embedding). 

Following is an example of `config/deploy/xxxx.rb`:

Please note that `repo_url` should be a different path with the path running cap. 
This strategy probably fits with a rare situation, you should use the default `git` strategy usually. 

```ruby
set :branch, ENV['BRANCH'] || 'master'
set :rbenv_type, :user
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle tmp/run)
set :keep_releases, 5
set :scm, :bundle_rsync
set :bundle_rsync_scm, 'local_git' # Set `local_git`

set :application, 'sample'
set :repo_url, "/path/to/app/local" # Need to git clone your repository to this path beforehand.
                                    # This path should be different with the path running cap.
set :deploy_to, "/path/to/app/production"
set :rbenv_ruby, "2.1.2" # Required the same ruby on both deploy machine and remote machines
set :ssh_options, user: 'sonots', keys: File.expand_path('~/.ssh/id_rsa')

role :app, ['127.0.0.1']
```

## FAQ

Q. What is difference with [capistrano-rsync](https://github.com/moll/capistrano-rsync)?

A. capistrano-bundle\_rsync does `bundle install` at the deploy machine, not on each remote machine. 

## ToDo

1. Support other SCMs than `git`. 

## ChangeLog

[CHANGELOG.md](./CHANGELOG.md)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

See [LICENSE.txt](./LICENSE.txt) for details.

## Special Thanks

capistrano-bundle_rsync was originally created by [@tohae](https://github.com/tohae). Thank you very much!
