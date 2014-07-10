require 'delegate'
require 'capistrano/bundle_rsync/config'

module Capistrano::BundleRsync
  class Base < SimpleDelegator
    def initialize(delegator)
      super(delegator)
    end

    def config
      Capistrano::BundleRsync::Config
    end
  end
end
