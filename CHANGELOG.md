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

