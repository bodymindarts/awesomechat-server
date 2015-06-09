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
    message = Oj.load(message_string)

    puts "received message: " + message_string
    puts "message sent al now: #{@storage.all(@room_name)}"
    return if @storage.contains? message

    puts "didnt contain" + message_string

    message['pending'] = false

    raw_message = @storage.store_message(@room_name, message)
    @clients.broadcast(raw_message)
    puts "message sent al now: #{@storage.all(@room_name)}"
  end

  def sync_history(connection)
    connection.send(Oj.dump(@storage.all(@room_name)))
  end
end
