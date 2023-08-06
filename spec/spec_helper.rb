$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# Emulate cap command
# https://github.com/capistrano/capistrano/blob/31e142d56f8d894f28404fb225dcdbe7539bda18/bin/cap
require "capistrano/all"

# Emulate Capfile

# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

if Gem::Version.new(Capistrano::VERSION) >= Gem::Version.new('3.7')
  require 'capistrano/bundle_rsync/plugin'
  install_plugin Capistrano::BundleRsync::Plugin
else
  require 'capistrano/bundle_rsync'
end
