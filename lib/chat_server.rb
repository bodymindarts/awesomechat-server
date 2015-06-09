require 'em-websocket'
require 'redis'
require_relative 'message_store'
require_relative 'chat_room'

class ChatServer
  def initialize(host: '0.0.0.0', port: 8080)
    @host = host
    @port = port
    @clients = []
    @storage = MessageStore.new(Redis.new)
    @chat_room = ChatRoom.new('default', @storage)
  end

  def run
    puts "ChatServer Started"
    EM::WebSocket.run(host: @host, port: @port) do |ws|
      @chat_room.add_connection(ws)
    end
  end
end
