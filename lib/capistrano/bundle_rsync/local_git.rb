require 'capistrano/bundle_rsync/scm'

class Capistrano::BundleRsync::LocalGit < Capistrano::BundleRsync::SCM
  def check
    raise ArgumentError.new('`repo_url` must be local path to use `local_git` scm') unless local_path?(repo_url)
    exit 1 unless execute("git ls-remote #{repo_url}")
    execute("mkdir -p #{config.local_base_path}")
  end

  def clone
  end

  def update
  end

  def create_release
    execute "mkdir -p #{config.local_release_path}"
    local_base_dir = File.basename(config.local_base_path) # .local_repo
    rsync_options = %Q[-a --exclude=".git" --exclude="#{local_base_dir}/"]

    execute :rsync, "#{rsync_options} #{repo_url}/ #{config.local_release_path}"
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
