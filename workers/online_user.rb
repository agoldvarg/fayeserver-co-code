class OnlineUser

  @queue = :online_user_queue

  def self.perform(channel, channel_key)
    PrivatePub.load_config(File.expand_path("../../config/private_pub.yml", __FILE__), "development")

    PrivatePub.publish_to(channel, "refreshUsers('#{channel}', '#{channel_key}', 'entered')")
  end
end

