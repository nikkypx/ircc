# ircc

A minimal Ruby IRC client.

## What it does

- Opens a TCP connection to an IRC server
- Registers with `NICK` / `USER`
- Joins channels
- Auto-replies to `PING` with `PONG`
- Prints raw server lines

## Setup

```bash
bin/setup
```

## Try it

Edit `bin/test` with your own nick and channel, then:

```bash
./bin/test
```

You should see Libera's welcome / MOTD scroll by, then a `JOIN` confirmation.

## Library usage

```ruby
require "ircc"

connection = Ircc::Connection.new(host: "irc.libera.chat", port: 6667)
connection.connect

client = Ircc::Client.new(connection)
client.register(nickname: "mynick", username: "mynick", realname: "Me")
client.join("#some-channel")

loop do
  line = client.process_next
  break if line.nil?

  puts line
end
```

## Layout

| Piece | Role |
|---|---|
| `Ircc::Connection` | TCP connect / read / write / close |
| `Ircc::Command` | Build IRC command strings (`NICK`, `USER`, `PONG`, `JOIN`) |
| `Ircc::Client` | Register, join, handle `PING`, read the next line |

## Development

```bash
bundle exec rspec
bundle exec rubocop
bin/console
```

## License

[MIT](LICENSE.txt)
