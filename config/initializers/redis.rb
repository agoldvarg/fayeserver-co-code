$redis = Redis.new(:url => ENV['REDISTOGO_URL'])
Resque.redis = $redis