require "bundler/setup"
Bundler.require

require "yaml"
require 'uri'
require 'net/http'

require_all "faye"
require_all "workers"

require './config/initializers/redis'
