require 'redis'
require 'oj'
require_relative '../lib/message_store'

RSpec.describe MessageStore do
  let(:low_message) do
    { 'id' => '120-id', 'score' => '120' }
  end
  let(:high_message) do
    { 'id' => '240-id', 'score' => '240' }
  end
  let(:low_json) { Oj.dump(low_message) }
  let(:high_json) { Oj.dump(high_message) }
  let(:room) { 'testdefault' }

  before :all do
    @redis = Redis.new
  end

  after do
    @redis.zrange("#{room}:history", 0, -1).map do |id|
      @redis.del(id)
    end
    @redis.del("#{room}:history")
  end

  subject { MessageStore.new(@redis) }

  it 'stores messages by id as json and returns the json' do
    expect(subject.store_message(room, low_message)).to eq low_json
    expect(@redis.get('120-id')).to eq low_json
  end

  it 'stores messages in an ordered set' do
    subject.store_message(room, high_message)
    subject.store_message(room, low_message)
    expect(@redis.zrange("#{room}:history", 0, 1)).
      to eq(['120-id', '240-id'])
  end

  it 'knows if it contains a message' do
    subject.store_message(room, low_message)
    expect(subject.contains?(low_message)).to eq true
  end

  it 'can retreive all messages' do
    subject.store_message(room, high_message)
    subject.store_message(room, low_message)
    expect(subject.all(room)).to eq([low_message, high_message]);
  end
end
