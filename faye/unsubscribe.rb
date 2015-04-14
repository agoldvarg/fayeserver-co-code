class Unsubscribe
  USER_COUNT = 'online_users'
  USER_MAPPING = 'user_client_mapping'

  def initialize(channel, client_id)
    @client_id = client_id
    if channel["/users/status/"]
      @channel_info = channel.gsub("/users/status/","")
      status_unsubscribe
    elsif channel[/rooms\/\d+/]
      @channel_info = channel[/rooms\/\d+/].gsub("rooms/","")
      room_unsubscribe
    end
  end

  def status_unsubscribe
    remove_active_user if decrease_user_count <= 0
  end

  def room_unsubscribe
    remove_client_from_room
  end

  private
    def decrease_user_count
      $redis.hincrby(USER_COUNT, @channel_info, -1)
    end

    def remove_client_from_room
      $redis.srem(@channel_info, @client_id)
    end

    def remove_active_user
      $redis.hdel(USER_COUNT, @channel_info)
    end

end