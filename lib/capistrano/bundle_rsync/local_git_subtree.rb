require 'capistrano/bundle_rsync/scm'

class Capistrano::BundleRsync::LocalGitSubtree < Capistrano::BundleRsync::SCM
  def check
    raise ArgumentError.new('`repo_url` must be local path to use `local_git` scm') unless local_path?(repo_url)
    exit 1 unless execute("git ls-remote #{repo_url}")
    execute("mkdir -p #{config.local_base_path}")
  end

  def clone
    unless Dir.exist?("#{config.local_mirror_path}")
      execute "mkdir -p #{config.local_mirror_path}"
    end
  end

  def update
  end

  def create_release
    execute "mkdir -p #{config.local_release_path}"
    local_rsync_options = fetch(:bundle_rsync_local_rsync_options)
    within config.local_mirror_path do
      execute :rsync, "#{local_rsync_options} #{repo_url}/ #{config.local_release_path}/"
    end
  end

  def rsync_release
    hosts = release_roles(:all)
    rsync_options = config.rsync_options
    Parallel.each(hosts, in_threads: config.max_parallels(hosts)) do |host|
      ssh = config.build_ssh_command(host)
      execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{repo_url}/ #{host}:#{release_path}/"
    end
  end

  def set_current_revision
    within repo_url do
      set :current_revision, capture(:git, "rev-parse --short HEAD")
    end
  end

  private

  def local_path?(repo_url)
    return !(
      repo_url.start_with?('http://') or
      repo_url.start_with?('https://') or
      repo_url.start_with?('git://') or
      repo_url.start_with?('git@') or
      repo_url.start_with?('ssh://')
    )
  end
end
