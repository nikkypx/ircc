# frozen_string_literal: true

require "socket"

module Ircc
  class Connection
    def initialize(host:, port:)
      @host = host
      @port = port
      @socket = nil
    end

    def connect
      @socket = TCPSocket.new(@host, @port)
    end

    def write(data)
      @socket.write(data)
    end

    def read
      @socket.gets
    end

    def close
      @socket&.close
    end
  end
end
