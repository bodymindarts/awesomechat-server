require 'redis'
require_relative '../lib/message_store'

RSpec.describe MessageStore do
  before do
    @redis = Redis.new
  end

  it 'stores raw messages with their id as key' do
    message = double('message', id: 'unique_id', score: 0, raw: 'MESSAGE')
    MessageStore.new(@redis).store_message('testdefault', message)
    expect(@redis.get('unique_id')).to eq 'MESSAGE'
    @redis.del('unique_id')
  end

  it 'stores messages in an ordered set' do
    low_message = double(
      'low_message',
      id: 'low_key',
      score: 12.0,
      raw: 'MESSAGE'
    )
    high_message = double(
      'high_message',
      id: 'high_key',
      score: 24.0,
      raw: 'MESSAGE'
    )
    store = MessageStore.new(@redis)
    store.store_message('testdefault', high_message)
    store.store_message('testdefault', low_message)

    expect(@redis.zrevrange('testdefault:history', 0, 1)).
      to eq(['high_key', 'low_key'])
    @redis.del('testdefault:history')
  end
end
