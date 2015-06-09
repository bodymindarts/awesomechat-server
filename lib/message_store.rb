require 'oj'

class MessageStore
  def initialize(redis)
    @redis = redis
  end

  def store_message(room_name, message)
    raw_message = Oj.dump(message)

    @redis.set(message['id'], raw_message)
    @redis.zadd(room_history_key(room_name), message['score'], message['id'])
    raw_message
  end

  def contains?(message)
    @redis.get(message['id']) != nil
  end

  def all(room_name)
    @redis.zrange(room_history_key(room_name), 0, -1).map do |id|
      Oj.load(@redis.get(id))
    end
  end

  private

  def room_history_key(room_name)
    "#{room_name}:history"
  end
end
