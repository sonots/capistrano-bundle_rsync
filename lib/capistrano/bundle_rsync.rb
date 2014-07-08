module Capistrano
  module BundleRsync
  end
end

require 'capistrano/bundle_rsync/config'
load File.expand_path('../tasks/bundle_rsync.rake', __FILE__)
