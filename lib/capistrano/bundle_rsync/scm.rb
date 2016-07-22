require 'capistrano/bundle_rsync/base'
require 'capistrano/configuration/filter'

# Base class for SCM strategy providers.
#
# @abstract
class Capistrano::BundleRsync::SCM < Capistrano::BundleRsync::Base
  # @abstract
  #
  # Your implementation should check the existence of a cache repository on
  # the deployment target
  #
  # @return [Boolean]
  #
  def test
    raise NotImplementedError.new(
      "Your SCM strategy module should provide a #test method"
    )
  end

  # @abstract
  #
  # Your implementation should check if the specified remote-repository is
  # available.
  #
  # @return [Boolean]
  #
  def check
    raise NotImplementedError.new(
      "Your SCM strategy module should provide a #check method"
    )
  end

  # @abstract
  #
  # Create a (new) clone of the remote-repository on the deployment target
  #
  # @return void
  #
  def clone
    raise NotImplementedError.new(
      "Your SCM strategy module should provide a #clone method"
    )
  end

  # @abstract
  #
  # Update the clone on the deployment target
  #
  # @return void
  #
  def update
    raise NotImplementedError.new(
      "Your SCM strategy module should provide a #update method"
    )
  end

  # @abstract
  #
  # Copy the contents of the cache-repository onto the release path
  #
  # @return void
  #
  def create_release
    raise NotImplementedError.new(
      "Your SCM strategy module should provide a #create_release method"
    )
  end

  # @abstract
  #
  # Clean the contents of the cache-repository onto the release path
  #
  # @return void
  #
  def clean_release
    raise NotImplementedError.new(
      "Your SCM strategy module should provide a #clean_release method"
    )
  end

  # @abstract
  #
  # Rsync the contents of the release path
  #
  # This is an additional task endpoint provided by capistrano-bundle_rsync
  #
  # @return void
  #
  def rsync_release
    raise NotImplementedError.new(
      "Your SCM strategy module should provide a #rsync_release method"
    )
  end

  # @abstract
  #
  # Rsync arbitrary contents to shared directory
  #
  # This is an additional task endpoint provided by capistrano-bundle_rsync
  #
  # @return void
  def rsync_shared
    hosts = ::Capistrano::Configuration.env.filter(release_roles(:all))
    rsync_options = config.rsync_options

    if config_files = config.config_files
      Parallel.each(hosts, in_threads: config.max_parallels(hosts)) do |host|
        ssh = config.build_ssh_command(host)
        config_files.each do |config_file|
          basename = File.basename(config_file)
          execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{config_file} #{host}:#{release_path}/config/#{basename}"
        end
      end
    end

    if shared_dirs = config.shared_dirs
      Parallel.each(hosts, in_threads: config.max_parallels(hosts)) do |host|
        ssh = config.build_ssh_command(host)
        shared_dirs.each do |shared_dir|
          basename = File.basename(shared_dir)
          execute :rsync, "#{rsync_options} --rsh='#{ssh}' #{shared_dir}/ #{host}:#{shared_path}/#{basename}/"
        end
      end
    end
  end

  # @abstract
  #
  # Identify the SHA of the commit that will be deployed.  This will most likely involve SshKit's capture method.
  #
  # @return void
  #
  def set_current_revision
    raise NotImplementedError.new(
      "Your SCM strategy module should provide a #set_current_revision method"
    )
  end
end
