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
      queue_online_script
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

    def find_channel_key_by_client_id
      $redis.hget(USER_MAPPING, @client_id)
    end

    def queue_online_script
      Resque.enqueue(OnlineUser, @channel, find_channel_key_by_client_id)
    end
end