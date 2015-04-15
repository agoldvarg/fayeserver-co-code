# Run with: rackup private_pub.ru -s thin -E production
require_relative './config/environment'

Faye::WebSocket.load_adapter('thin')

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), "development")

options = {:mount => "/faye",
           :timeout => 25,
           :engine => {:type => Faye::Redis, :uri => ENV["REDISTOGO_URL"]}
         }

app = PrivatePub.faye_app(options)

  app.bind(:subscribe) do |client_id, channel|
    puts "SUBSCRIBED: #{client_id} -- #{channel}"
    Subscribe.new(channel, client_id)
  end

  app.bind(:unsubscribe) do |client_id, channel|
    puts "UNSUBSCRIBED: #{client_id} -- #{channel}"
    Unsubscribe.new(channel, client_id)
  end

  app.bind(:disconnect) do |client_id|
    puts "DISCONNECTED: #{client_id}"
    Disconnect.new(client_id)
  end

  app.bind(:publish) do |client_id, channel, data|
    puts "PUBLISHED: CLIENT #{client_id} ON CHANNEL #{channel} DATA #{data}"
  end

run app
