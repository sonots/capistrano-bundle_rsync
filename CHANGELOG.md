# 0.5.2 (2019/02/14)

Fixes:

* Fix num_components by tree_repo (thanks to Hiroaki Kubota)

# 0.5.1 (2017/05/29)

Changes:

* Use git rev-list instead of git rev-parse to get current_version as https://github.com/capistrano/capistrano/pull/1339 (thanks to aeroastro)

# 0.5.0 (2017/04/21)

Enhancements:

* Support capistrano-3.7 (thanks to troter)

# 0.4.9 (2017/02/26)

Fixes:

* Fix `local_git` was not working because of a change in 0.4.7 (thanks to hkobayash)

# 0.4.8 (2016/11/18)

Enhancements:

* Suppress ls-remote log by filtering remote refs with HEAD (thanks to aeroastro)

# 0.4.7 (2016/07/22)

Fixes:

* Fix cleaning .local_repo/releases was not working if skip_bundle is specified (thanks to @kozyty)

# 0.4.6 (2016/02/03)

Enhancements:

* Support repo_tree with local_git (thanks to @mizzy)

# 0.4.5 (2015/08/06)

Enhancements:

* Support bundle install with --standalone option (thanks to @niku4i)

# 0.4.4 (2015/07/09)

Enhancements:

* Avoid to remove existing .bundle/config using BUNDLE_APP_CONFIG (thanks to @hkobayash)

# 0.4.3 (2015/03/16)

Fixes:

* Avoid possible name conflictions

# 0.4.2 (2015/03/16)

Fixes7

* Fix bugs incorporated with v0.4.1

# 0.4.1 (2015/03/16)

Fixes:

* Fix --hosts and --roles options to work (thanks to @niku4i)
* Fix to config.bundle_rsync_max_parallels to be integer always (thanks to @niku4i)
* Fix for the case `bundle_rsync_ssh_options` and `ssh_options` are not configured (thanks to @niku4i)

# 0.4.0 (2015/03/04)

Enhancements:

* Support `repo_tree` to deploy subtree of a repository (thanks @lecoueyl)

# 0.3.3 (2015/01/30)

Fixes:

* Fix to cleanup .local_repo/releases with keep_releases

# 0.3.2 (2014/12/11)

Changes:

* Remove `.bundle/config` to make it possible to install development gems before rake assets:precompile

# 0.3.1 (2014/08/05)

Changes:

* Remove `bundle_rsync_shared_rsync_options` to reduce complexity

# 0.3.0 (2014/08/05)

Enhancements:

* Add `bundle_rsync_shared_dirs` and `bundle_rsync_shared_rsync_options` options

Fixes:

* Fix `bundle_rsync_config_files`

# 0.2.4 (2014/07/28)

Changes:

* Change process parallel to thread parallel to save memory usage as capistrano/sshkit does

# 0.2.3 (2014/07/18)

Enhancements:

* Add `bundle_rsync_skip_bundle` option

# 0.2.2 (2014/07/17)

Changes:

* Split rsync tasks and reorder tasks to be better

# 0.2.1 (2014/07/11)

Fixes:

* Stop to rsync binstubs not to override bin of rails 4

# 0.2.0 (2014/07/11)

Enhancements:

* Support `bundle_rsync_keep_releases` configuration
* Newly add `set :bundle_rsync_scm 'local_git'` configuration

Changes:

* Rename `bundle_rsync_local_repo_path` to `bundle_rsync_local_mirror_path`

# 0.1.1 (2014/07/09)

Enhancements:

* Support `bundle_rsync_rsync_options` configuration
* Support `bundle_rsync_rsync_bwlimit` configuration

# 0.1.0 (2014/07/08)

First version

