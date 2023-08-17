require 'pathname'
require 'capistrano/bundle_rsync/scm'

# Make Deployment Super-Fast by Utilizing Hardlink and Rsync
class Capistrano::BundleRsync::GitTurbo < Capistrano::BundleRsync::SCM
  def check
    execute :git, 'ls-remote', repo_url, 'HEAD'
    execute :mkdir, '-p', config.local_base_path
  end

  def clone
    if test "[ -f #{config.local_mirror_path}/HEAD ]"
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
    set_current_revision

    worktree = local_worktree_path
    if test "[ -f #{worktree.join('.git')} ]"
      within worktree do
        execute :git, 'checkout', '--detach', fetch(:current_revision)
        execute :git, 'reset', '--hard'
        execute :git, 'clean', '--force', '-x'
      end
    else
      within config.local_mirror_path do
        execute :git, 'worktree', 'add', '-f', '--detach', worktree, fetch(:current_revision)
      end
    end

    source = fetch(:repo_tree) ? worktree.join(fetch(:repo_tree)) : worktree
    within config.local_base_path do
      execute :cp, '-al', source, config.local_release_path
    end

    within config.local_release_path do
      execute :rm, '-f', '.git'
    end
  end

  def clean_release
    releases = capture(:ls, '-x', config.local_releases_path).split
    if releases.count >= config.keep_releases
      directories = (releases - releases.last(config.keep_releases))
      if directories.any?
        directories_str = directories.map do |release|
          File.join(config.local_releases_path, release)
        end.join(' ')
        execute :rm, '-rf', directories_str
      end
    end
  end

  def rsync_release
    hosts = release_roles(:all)
    c = config
    on hosts, in: :groups, limit: config.max_parallels(hosts), wait: 0 do |host|
      execute :mkdir, '-p', releases_path

      if source = capture(:ls, '-x', releases_path).split.last
        execute :cp, '-al', releases_path.join(source), release_path
      else
        execute :mkdir, '-p', release_path
      end

      run_locally do
        ssh = c.build_ssh_command(host)
        execute :rsync, "#{c.rsync_options} --rsh='#{ssh}' #{c.local_release_path}/ #{host}:#{release_path}/"
      end
    end
  end

  def set_current_revision
    within config.local_mirror_path do
      set :current_revision, capture(:git, "rev-list --max-count=1 #{fetch(:branch)}")
    end
  end

  private

  def local_worktree_path
    Pathname.new("#{fetch(:bundle_rsync_local_base_path)}/git_turbo_worktree")
  end
end

