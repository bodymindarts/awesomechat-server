require 'oj'
require_relative 'client_list'

class ChatRoom
  def initialize(room_name, storage, client_list = ClientList.new)
    @room_name = room_name
    @storage = storage
    @clients = client_list
  end

  def add_connection(connection)
    @clients.add_client(connection)

    connection.onopen do
      sync_history(connection)
    end

    connection.onclose do
      @clients.remove_client(connection)
    end

    connection.onmessage do |message|
      handle_message(message)
    end
  end

  private

  def handle_message(message_string)
    return if @storage.contains? message = Oj.load(message_string)

    message['pending'] = false
    raw_message = @storage.store_message(@room_name, message)

    @clients.broadcast(raw_message)
  end

  def sync_history(connection)
    connection.send(Oj.dump(@storage.all(@room_name)))
  end
end
