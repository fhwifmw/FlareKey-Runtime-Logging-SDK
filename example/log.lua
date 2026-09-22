local Runtime = loadstring(game:HttpGet("https://YOUR-FLAREKEY-HOST/v1/sdk/runtime.lua"))()

local telemetry = Runtime.new({
    apiBase = "https://flarekey.xyz",
    serviceId = "svc_...",
    scriptId = "scr_...",
    sessionToken = FlareKey._session
})

telemetry:log("started", "Script started")
