# frozen_string_literal: true

module Ircc
  class Client
    def initialize(connection)
      @connection = connection
    end

    def register(nickname:, username:, realname:)
      @connection.write(Command.nickname(nickname))
      @connection.write(Command.user(username, realname))
    end

    def handle(line)
      return unless line.start_with?("PING :")

      token = line.delete_prefix("PING :").delete_suffix("\r\n")
      @connection.write(Command.pong(token))
    end

    def process_next
      line = @connection.read
      handle(line)
      line
    end

    def join(channel)
      @connection.write(Command.join(channel))
    end
  end
end
