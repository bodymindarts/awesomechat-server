require_relative '../lib/chat_room'

RSpec.describe ChatRoom do
  it 'broadcasts a message' do
    clients = double('client_list')
    expect(clients).to receive(:broadcast).with('MESSAGE')
    ChatRoom.new(clients).receive_message('MESSAGE')
  end
end
