# FlareKey Runtime SDK

The FlareKey Runtime SDK sends authenticated runtime events from a Roblox loader to the FlareKey activity log.

It is used after a FlareKey loader has finished authentication. It does not verify keys, download scripts, change access, or make tamper decisions.

## Requirements

- A FlareKey service
- A script belonging to that service
- A loader that has completed the normal FlareKey authentication flow
- A request function provided by the executor

## Installation

Copy `flarekey-runtime-sdk.lua` into your public SDK repository or serve it from your own host. The FlareKey dashboard provides the hosted SDK URL in the service Runtime API section.

## Basic usage

```lua
local Runtime = loadstring(game:HttpGet("https://YOUR-FLAREKEY-HOST/v1/sdk/runtime.lua"))()

local telemetry = Runtime.new({
    apiBase = "https://YOUR-FLAREKEY-HOST",
    serviceId = "svc_...",
    scriptId = "scr_...",
    sessionToken = FlareKey._session
})

telemetry:log("started", "Script started")
```

`FlareKey._session` comes from the authenticated loader session. Do not create a replacement token and do not put a runtime secret in a loader.

## Custom events

```lua
telemetry:log("feature_used", "Feature activated", {
    feature = "example",
    enabled = true,
    amount = 1
})
```

Event names, messages, and custom fields are limited and sanitized before they are sent. Custom fields may contain strings, numbers, or booleans. Sensitive field names containing `token` or `secret` are ignored.

## Data sent by default

Each event includes the runtime context available to the client:

- Roblox username
- Roblox display name
- Roblox user ID
- Place ID
- Game ID
- Job ID
- Game name when available
- Executor when available

The event also includes the service ID, script ID, event name, message, and selected custom fields.

## Authentication

The SDK sends the authenticated session in the `Authorization` header and includes the service ID in `x-service-id`. The FlareKey server checks the session before accepting the event and applies its own field limits and sanitization.

If the SDK is not configured, the executor does not provide a request function, or the server rejects the session, `log` returns `false` and an error string.

## License

This project is licensed under the MIT License. See `LICENSE`.
