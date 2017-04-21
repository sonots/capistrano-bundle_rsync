require 'capistrano/bundle_rsync'
require 'capistrano/scm/plugin'

module Capistrano
  module BundleRsync
    class Plugin < Capistrano::SCM::Plugin
      def register_hooks
        after "deploy:new_release_path", "bundle_rsync:create_release"
        before "deploy:check", "bundle_rsync:check"
        before "deploy:set_current_revision", "bundle_rsync:set_current_revision"
      end
    end
  end
end
