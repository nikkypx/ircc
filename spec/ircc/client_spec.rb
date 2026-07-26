# frozen_string_literal: true

require "spec_helper"
require "socket"

RSpec.describe Ircc::Client do
  describe "#register" do
    it "sends NICK and USER through the connection" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          [peer.gets, peer.gets]
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        client.register(
          nickname: "nick",
          username: "alice",
          realname: "Alice Smith"
        )

        expect(server_thread.value).to eq(
          [
            "NICK nick\r\n",
            "USER alice 0 * :Alice Smith\r\n"
          ]
        )
      ensure
        connection.close
        server.close
      end
    end

    it "sends registration commands for the given identity" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          [peer.gets, peer.gets]
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        client.register(
          nickname: "bob",
          username: "bobby",
          realname: "Bob"
        )

        expect(server_thread.value).to eq(
          [
            "NICK bob\r\n",
            "USER bobby 0 * :Bob\r\n"
          ]
        )
      ensure
        connection.close
        server.close
      end
    end
  end

  describe "#join" do
    it "sends JOIN through the connection" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          peer.gets
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        client.join("#ruby")

        expect(server_thread.value).to eq("JOIN #ruby\r\n")
      ensure
        connection.close
        server.close
      end
    end

    it "sends JOIN for the given channel" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          peer.gets
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        client.join("#ircc")

        expect(server_thread.value).to eq("JOIN #ircc\r\n")
      ensure
        connection.close
        server.close
      end
    end
  end

  describe "#handle" do
    it "replies to PING with PONG" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          peer.gets
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        client.handle("PING :12345\r\n")

        expect(server_thread.value).to eq("PONG :12345\r\n")
      ensure
        connection.close
        server.close
      end
    end

    it "replies with a PONG for the given token" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          peer.gets
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        client.handle("PING :irc.example.com\r\n")

        expect(server_thread.value).to eq("PONG :irc.example.com\r\n")
      ensure
        connection.close
        server.close
      end
    end
  end

  describe "#process_next" do
    it "reads a line from the connection and handles it" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          peer.write("PING :12345\r\n")
          peer.gets
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        line = client.process_next

        expect(line).to eq("PING :12345\r\n")
        expect(server_thread.value).to eq("PONG :12345\r\n")
      ensure
        connection.close
        server.close
      end
    end

    it "handles the line that was read" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          peer.write("PING :irc.example.com\r\n")
          peer.gets
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        line = client.process_next

        expect(line).to eq("PING :irc.example.com\r\n")
        expect(server_thread.value).to eq("PONG :irc.example.com\r\n")
      ensure
        connection.close
        server.close
      end
    end

    it "returns non-PING lines without writing a reply" do
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new do
        peer = server.accept

        begin
          peer.write(":irc.example.com NOTICE * :Welcome\r\n")
        ensure
          peer.close
        end
      end

      connection = Ircc::Connection.new(
        host: "127.0.0.1",
        port: port
      )

      begin
        connection.connect
        client = described_class.new(connection)
        line = client.process_next
        server_thread.join

        expect(line).to eq(":irc.example.com NOTICE * :Welcome\r\n")
      ensure
        connection.close
        server.close
      end
    end
  end
end
