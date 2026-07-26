# frozen_string_literal: true

require "spec_helper"

RSpec.describe Ircc::Command do
  describe ".nickname" do
    it "creates an IRC NICK command" do
      command = described_class.nickname("nick")

      expect(command).to eq("NICK nick\r\n")
    end

    it "rejects a nickname that can inject another IRC command" do
      nickname = "nick\r\nJOIN #ruby"

      expect do
        described_class.nickname(nickname)
      end.to raise_error(
        ArgumentError,
        "nickname contains invalid characters"
      )
    end
  end

  describe ".user" do
    it "creates an IRC USER command" do
      expect(described_class.user("username", "Real Name")).to eq(
        "USER username 0 * :Real Name\r\n"
      )
      expect(described_class.user("alice", "Alice Smith")).to eq(
        "USER alice 0 * :Alice Smith\r\n"
      )
      expect(described_class.user("bob", "Bob")).to eq(
        "USER bob 0 * :Bob\r\n"
      )
    end

    it "rejects a username that can inject another IRC command" do
      username = "user\r\nJOIN #ruby"

      expect do
        described_class.user(username, "Real Name")
      end.to raise_error(
        ArgumentError,
        "username contains invalid characters"
      )
    end

    it "rejects a real name that can inject another IRC command" do
      realname = "Real Name\r\nJOIN #ruby"

      expect do
        described_class.user("username", realname)
      end.to raise_error(
        ArgumentError,
        "realname contains invalid characters"
      )
    end
  end

  describe ".pong" do
    it "creates an IRC PONG command" do
      expect(described_class.pong("12345")).to eq("PONG :12345\r\n")
      expect(described_class.pong("irc.example.com")).to eq("PONG :irc.example.com\r\n")
      expect(described_class.pong("abc")).to eq("PONG :abc\r\n")
    end

    it "rejects a token that can inject another IRC command" do
      token = "12345\r\nJOIN #ruby"

      expect do
        described_class.pong(token)
      end.to raise_error(
        ArgumentError,
        "token contains invalid characters"
      )
    end
  end

  describe ".join" do
    it "creates an IRC JOIN command" do
      expect(described_class.join("#ruby")).to eq("JOIN #ruby\r\n")
      expect(described_class.join("#ircc")).to eq("JOIN #ircc\r\n")
      expect(described_class.join("#test")).to eq("JOIN #test\r\n")
    end

    it "rejects a channel that can inject another IRC command" do
      channel = "#ruby\r\nPRIVMSG #ruby :hi"

      expect do
        described_class.join(channel)
      end.to raise_error(
        ArgumentError,
        "channel contains invalid characters"
      )
    end
  end
end
