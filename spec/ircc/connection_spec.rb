# frozen_string_literal: true

require "socket"

RSpec.describe Ircc::Connection do
  describe "#write" do
    it "sends bytes through a TCP connection" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        client = server.accept

        begin
          client.gets
        ensure
          client.close
        end
      end

      connection = described_class.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        connection.write("NICK nick\r\n")

        received = server_thread.value

        expect(received).to eq("NICK nick\r\n")
      ensure
        connection.close
        server.close
      end
    end
  end

  describe "#read" do
    it "receives a line from a TCP connection" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        client = server.accept

        begin
          client.write("PING :12345\r\n")
        ensure
          client.close
        end
      end

      connection = described_class.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        received = connection.read
        server_thread.join

        expect(received).to eq("PING :12345\r\n")
      ensure
        connection.close
        server.close
      end
    end
  end
end
