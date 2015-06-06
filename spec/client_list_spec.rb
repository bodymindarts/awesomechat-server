require_relative '../lib/client_list.rb'

RSpec.describe ClientList do
  it 'broadcasts to multiple clients' do
    clients = [ double('client1'), double('client2') ]
    clients.each do |client|
      expect(client).to receive(:send).with('MESSAGE')
    end
    ClientList.new(clients).broadcast('MESSAGE')
  end

  it 'can add a client' do
    client = double('client')
    list = ClientList.new.add_client(client)
    expect(client).to receive(:send).with('MESSAGE')
    list.broadcast('MESSAGE')
  end

  it 'can remove a client' do
    client = double('client')
    list = ClientList.new([client]).remove_client(client)
    expect(client).not_to receive(:send).with('MESSAGE')
    list.broadcast('MESSAGE')
  end
end
