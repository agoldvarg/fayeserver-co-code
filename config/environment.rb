require "bundler/setup"
Bundler.require

require "yaml"
require 'uri'
require 'net/http'
require "redis"
require "faye"
require "private_pub"
require 'faye/redis'

require_all "faye"

require './config/initializers/redis'
