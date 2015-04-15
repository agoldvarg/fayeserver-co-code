class OfflineUser

  @queue = :offline_user_queue

  def self.perform(channel, channel_key)
    PrivatePub.load_config(File.expand_path("../../config/private_pub.yml", __FILE__), ENV["RACK_ENV"] || "development")

    PrivatePub.publish_to(channel, "refreshUsers('#{channel}', '#{channel_key}', 'left')")
  end
end