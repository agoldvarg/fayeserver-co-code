require "bundler/setup"
Bundler.require

require "yaml"
require 'uri'
require 'net/http'
require "redis"
require "faye"

require_all "faye"
require_all "workers"

require './config/initializers/redis'
require './config/initializers/resque'
