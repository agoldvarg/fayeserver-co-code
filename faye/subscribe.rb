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
      send_faye_msg
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
      # Resque.enqueue(OnlineUsersJob, @channel)
      # puts PrivatePub.message(@channel, "alert('hello world')")
      # PrivatePub.publish_to(@channel, "alert('hello world')")
      # binding.pry
      # puts "CONFIGURATION: #{PrivatePub.config}"
      # HTTP.get("http://localhost:3000/sandbox?channel=#{@channel}")
    end
end

# PrivatePub.publish_to("/ruby/problem-2/rooms/3", "alert('hello world')")


# def publish_to(channel, data)
#   publish_message(message(channel, data))
# end

# # Sends the given message hash to the Faye server using Net::HTTP.
# def publish_message(message)
#   raise Error, "No server specified, ensure private_pub.yml was loaded properly." unless config[:server]
#   url = URI.parse(config[:server])

#   form = Net::HTTP::Post.new(url.path.empty? ? '/' : url.path)
#   form.set_form_data(:message => message.to_json)

#   http = Net::HTTP.new(url.host, url.port)
#   http.use_ssl = url.scheme == "https"
#   http.start {|h| h.request(form)}
# end

# # Returns a message hash for sending to Faye
# def message(channel, data)
#   message = {:channel => channel, :data => {:channel => channel}, :ext => {:private_pub_token => config[:secret_token]}}
#   if data.kind_of? String
#     message[:data][:eval] = data
#   else
#     message[:data][:data] = data
#   end
#   message
# end