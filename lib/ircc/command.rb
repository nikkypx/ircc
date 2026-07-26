# frozen_string_literal: true

module Ircc
  class Command
    class << self
      def nickname(nickname)
        raise ArgumentError, "nickname contains invalid characters" if nickname.match?(/[\r\n]/)

        "NICK #{nickname}\r\n"
      end

      def user(username, realname)
        raise ArgumentError, "username contains invalid characters" if username.match?(/[\r\n]/)
        raise ArgumentError, "realname contains invalid characters" if realname.match?(/[\r\n]/)

        "USER #{username} 0 * :#{realname}\r\n"
      end

      def pong(token)
        raise ArgumentError, "token contains invalid characters" if token.match?(/[\r\n]/)

        "PONG :#{token}\r\n"
      end

      def join(channel)
        raise ArgumentError, "channel contains invalid characters" if channel.match?(/[\r\n]/)

        "JOIN #{channel}\r\n"
      end
    end
  end
end
