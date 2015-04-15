class Disconnect
  USER_MAPPING = 'user_client_mapping'

  def initialize(client_id)
    @client_id = client_id
    remove_user_mapping
  end

  def remove_user_mapping
    $redis.hdel('user_client_mapping', @client_id)
  end
end
