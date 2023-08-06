module Capistrano
  module BundleRsync
  end
end

require 'capistrano/bundle_rsync/defaults'
Capistrano::BundleRsync::Defaults.set_defaults

load File.expand_path('../tasks/bundle_rsync.rake', __FILE__)
