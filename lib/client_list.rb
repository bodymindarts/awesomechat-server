class ClientList
  def initialize(clients = [])
    @clients = clients
  end

  def broadcast(message)
    @clients.each do |client|
      client.send(message)
    end
  end

  def add_client(client)
    ClientList.new(@clients + [client])
  end

  def remove_client(client)
    ClientList.new(@clients.reject { |c| c == client })
  end
end
