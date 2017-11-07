# Oberon Server

## Deployment

Create an environmental variable file. An example one is provided:

```
cp .envrc.example .envrc
```

Read through `.envrc` and follow any instructions on regenerating secure
values.

## Development

### Development Environment

The Oberon chat server requires the following packages to be installed:

- Elixir >= 1.5
- Postgres >= 9.6

### Development Server

To start the Oberon chat server:

1. Create a `.envrc` file. Use the example file as a starting point: `cp .envrc.example .envrc`.

1. (Optional) Update values in `.envrc` to match the development environment.

1. Start the server `bin/start`.

1. To ensure client websocket connections work correctly, configure a DNS
   service to route traffic from `localhost:4484` to `chat-server.dev`. We
   recommend using [puma-dev](https://github.com/puma/puma-dev).
