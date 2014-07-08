# Capistrano::BundleRsync for Capistrano v3

Deploy an application and bundled gems via rsync

## What is this for?

Capistrano::BundleRsync builds (bundle) gems only once on a deploy machine and transfers gems to your production machines via rsync, which saves you from building gems on each your production machine. 

Also saves you from having to install Git and Build Tools on your production machine.

## How it works

Capistrano::BundleRsync works as followings:

1. Do `git clone --mirror URL .local_repo/repo` on a deploy (local) machine.
2. Extract a branch by `git archive {branch}` to `.local_repo/release_{time}`
4. Deploy the `release` directory to remote machines by `rsync`. 
3. Do `bundle --without development,test --path .local_repo/bundle` on a deploy (local) machine.
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
bundle_rsync_local_base_path   | `$(pwd)/.local_repo` | The working base directory
bundle_rsync_local_repo_path | `#{base_path}/repo"` | Path where to mirror your repository
bundle_rsync_local_release_path | `"#{base_path}/relase_#{Time.now.to_i}"` | Path where to checkout your repository
bundle_rsync_local_bundle_path | `"#{base_path}/bundle"` | Path where to bundle install gems.
bundle_rsync_local_bin_path | `"#{base_path}/bin"` | Path where to bundle install bin scripts.
bundle_rsync_config_files | `nil` | Additional files to rsync. Specified files are copied into `config` directory.
bundle_rsync_ssh_options | `ssh_options` | Configuration of ssh for rsync. Default uses the value of `ssh_options`
bundle_rsync_max_parallels | number of hosts | Number of concurrency. The default is the number of hosts to deploy.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-bundle_rsync'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-bundle_rsync

## Usage

Add followings to your Gemfile:

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
set :linked_dirs, %w(bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system tmp/run)
set :keep_releases, 5
set :scm, :bundle_rsync # Need this
set :bundle_rsync_max_parallels, ENV['PARA']
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

## FAQ

Q. What is difference with [capistrano-rsync](https://github.com/moll/capistrano-rsync)?

A. capistrano-bundle\_rsync does `bundle install` at the deploy machine, not on each remote machine. 

## ToDo

1. Support rsync_options
2. Support other SCMs than `git`. 

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
