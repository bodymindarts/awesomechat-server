class MessageStore
  def initialize(redis)
    @redis = redis
  end

  def store_message(room_name, message, raw)
    @redis.set(message['id'], raw)
    @redis.zadd(room_history_key(room_name), message['score'], message['id'])
  end

  def all
  end

  private

  def room_history_key(room_name)
    "#{room_name}:history"
  end
end
