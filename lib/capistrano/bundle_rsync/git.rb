require 'capistrano/bundle_rsync/scm'
require 'capistrano/configuration/filter'

class Capistrano::BundleRsync::Git < Capistrano::BundleRsync::SCM
  def check
    exit 1 unless execute("git ls-remote #{repo_url} HEAD")
    execute("mkdir -p #{config.local_base_path}")
  end

  def clone
    if File.exist?("#{config.local_mirror_path}/HEAD")
      info t(:mirror_exists, at: config.local_mirror_path)
    else
      execute :git, :clone, '--mirror', repo_url, config.local_mirror_path
    end
  end

  def update
    within config.local_mirror_path do
      execute :git, :remote, :update, '--prune'
    end
  end

  def create_release
    execute "mkdir -p #{config.local_release_path}"

    within config.local_mirror_path do
      if tree = fetch(:repo_tree)
        stripped = tree.slice %r#^/?(.*?)/?$#, 1 # strip both side /
        num_components = stripped.count('/') + 1
        execute :git, :archive, fetch(:branch), tree, "| tar -x --strip-components #{num_components} -f - -C ", "#{config.local_release_path}"
      else
        execute :git, :archive, fetch(:branch), '| tar -x -C', "#{config.local_release_path}"
      end
    end
  end

  def clean_release
    # Do not remove if :bundle_rsync_local_release_path is directly specified
    # because releases/#{datetime} directories are no longer created.
    return if fetch(:bundle_rsync_local_release_path)
    releases = capture(:ls, '-x', config.local_releases_path).split
    if releases.count >= config.keep_releases
      directories = (releases - releases.last(config.keep_releases))
      if directories.any?
        directories_str = directories.map do |release|
          File.join(config.local_releases_path, release)
        end.join(" ")
        execute :rm, '-rf', directories_str
      end
    end
  end

  def rsync_release
    hosts = ::Capistrano::Configuration.env.filter(release_roles(:all))
    rsync_options = config.rsync_options
    Parallel.each(hosts, in_threads: config.max_parallels(hosts)) do |host|
      ssh = config.build_ssh_command(host)
      execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{config.local_release_path}/ #{host}:#{release_path}/"
    end
  end

  def set_current_revision
    within config.local_mirror_path do
      set :current_revision, capture(:git, "rev-list --max-count=1 #{fetch(:branch)}")
    end
  end
end
