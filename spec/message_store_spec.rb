require 'redis'
require 'oj'
require_relative '../lib/message_store'

RSpec.describe MessageStore do
  let(:low_message) do
    { 'id' => 'low_key', 'score' => '120' }
  end
  let(:high_message) do
    { 'id' => 'high_key', 'score' => '240' }
  end
  let(:low_json) { Oj.dump(low_message) }
  let(:high_json) { Oj.dump(high_message) }
  let(:room) { 'testdefault' }

  before :all do
    @redis = Redis.new
  end

  after do
    @redis.del("#{room}:history")
  end

  subject { MessageStore.new(@redis) }

  it 'stores raw messages with their id as key' do
    message = { 'id' => 'unique_id', 'score' => 0 }
    subject.store_message(room, message, 'MESSAGE')
    expect(@redis.get('unique_id')).to eq 'MESSAGE'
    @redis.del('unique_id')
  end

  it 'stores messages in an ordered set' do
    subject.store_message(room, high_message, 'HIGH')
    subject.store_message(room, low_message, 'LOW')

    expect(@redis.zrevrange('testdefault:history', 0, 1)).
      to eq(['high_key', 'low_key'])
  end

  it 'knows if it contains a message' do
    message = { 'id' => 'unique_id', 'score' => 0 }
    subject.store_message(room, message, 'MESSAGE')
    expect(subject.contains?(message)).to eq true
    @redis.del('unique_id')
  end

  it 'can retreive all messages' do
    subject.store_message(room, high_message, low_json)
    subject.store_message(room, low_message, high_json)
    expect(subject.all(room)).to eq("[#{low_json}, #{high_json}]");
  end
end
