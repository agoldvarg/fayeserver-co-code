# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require 'uri'
require 'net/http'
require "redis"
require "faye"
require "private_pub"
require 'faye/redis'

Dir["faye/*.rb"].each {|file| load file }

load 'config/initializers/redis.rb'

Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "production")

options = {:mount => "/faye",
           :timeout => 25,
           :engine => {:type => Faye::Redis, :uri => ENV["REDISTOGO_URL"]}
         }

app = PrivatePub.faye_app(options)

  app.bind(:subscribe) do |client_id, channel|
    puts "Client SUBSCRIBE: #{client_id}:#{channel}"
    Subscribe.new(channel, client_id)
  end

  app.bind(:unsubscribe) do |client_id, channel|
    puts "Client UNSUBSCRIBE: #{client_id}:#{channel}"
    Unsubscribe.new(channel, client_id)
  end

  app.bind(:disconnect) do |client_id|
    puts "Client DISCONNECT: #{client_id}"
    Disconnect.new(client_id)
  end

run app
