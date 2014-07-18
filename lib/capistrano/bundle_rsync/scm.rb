require 'capistrano/bundle_rsync/base'

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
