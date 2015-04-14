require 'uri'
require 'net/http'

class Subscribe
  USER_COUNT = 'online_users'
  USER_MAPPING = 'user_client_mapping'

  def initialize(channel, client_id)
    @client_id = client_id
    @channel = channel
    if channel["/users/status/"]
      @channel_info = channel.gsub("/users/status/","")
      status_subscribe
    elsif channel[/rooms\/\d+/]
      @channel_info = channel[/rooms\/\d+/].gsub("rooms/","")
      room_subscribe
      # enter_room
      # send_faye_msg
    end
  end

  def status_subscribe
    increase_user_count
    add_user_mapping
  end

  def room_subscribe
    add_client_to_room
  end

  private
    def increase_user_count
      $redis.hincrby(USER_COUNT, @channel_info, 1)
    end

    def add_user_mapping
      $redis.hset(USER_MAPPING, @client_id, @channel_info)
    end

    def add_client_to_room
      $redis.sadd(@channel_info, @client_id)
    end

    def enter_room
      url = "http://localhost:3000"
      params = {client_id: @client_id}
      uri = URI.parse(url + @channel + "/enter")
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get_response(uri)
    end

    def send_faye_msg
       # PrivatePub.publish_to(@channel, "alert('hello world')")
    end
end

