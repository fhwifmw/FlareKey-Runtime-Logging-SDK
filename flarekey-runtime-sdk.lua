local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Runtime = {}

local function text(value, max)
    local valueText = tostring(value or "")
    valueText = valueText:gsub("[%z\1-\31\127]", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return valueText:sub(1, max or 160)
end

local function context()
    local player = Players.LocalPlayer
    local out = {
        robloxUsername = player and text(player.Name, 80) or "",
        displayName = player and text(player.DisplayName, 80) or "",
        robloxUserId = player and tostring(player.UserId or "") or "",
        placeId = tostring(game.PlaceId or ""),
        gameId = tostring(game.GameId or ""),
        jobId = text(game.JobId, 80),
        executor = ""
    }
    pcall(function()
        if type(identifyexecutor) == "function" then out.executor = text(identifyexecutor(), 80) end
    end)
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        if type(info) == "table" then out.gameName = text(info.Name, 160) end
    end)
    return out
end

local function bodyOf(response)
    if type(response) == "table" then return tostring(response.Body or response.body or response.Data or response.data or "") end
    return tostring(response or "")
end

function Runtime.new(options)
    options = options or {}
    local self = {
        apiBase = text(options.apiBase, 300):gsub("/$", ""),
        serviceId = text(options.serviceId, 128),
        scriptId = text(options.scriptId, 128),
        sessionToken = text(options.sessionToken, 512),
        debug = options.debug == true
    }

    function self:collect(extra)
        local out = context()
        if type(extra) == "table" then
            for key, value in pairs(extra) do
                if key == "gameName" or key == "jobId" or key == "executor" or key == "clientVersion" then
                    out[key] = text(value, key == "gameName" and 160 or 80)
                end
            end
        end
        return out
    end

    function self:log(eventName, message, fields)
        if self.apiBase == "" or self.serviceId == "" or self.scriptId == "" or self.sessionToken == "" or type(request) ~= "function" then
            return false, "telemetry_not_configured"
        end
        local safeFields = {}
        if type(fields) == "table" then
            local count = 0
            for key, value in pairs(fields) do
                if count >= 12 then break end
                local cleanKey = text(key, 48):gsub("[^A-Za-z0-9_.:-]", "_")
                if cleanKey ~= "" and not cleanKey:lower():find("token", 1, true) and not cleanKey:lower():find("secret", 1, true) then
                    if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
                        safeFields[cleanKey] = type(value) == "string" and text(value, 180) or value
                        count = count + 1
                    end
                end
            end
        end
        local payload = {
            serviceId = self.serviceId,
            scriptId = self.scriptId,
            eventName = text(eventName or "runtime", 64):lower():gsub("[^a-z0-9_.:-]", "_"),
            message = text(message, 240),
            context = self:collect(),
            fields = safeFields
        }
        local ok, response = pcall(request, {
            Url = self.apiBase .. "/v1/runtime/log",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. self.sessionToken,
                ["x-service-id"] = self.serviceId
            },
            Body = HttpService:JSONEncode(payload)
        })
        if not ok then return false, "request_failed" end
        local decodedOk, data = pcall(function() return HttpService:JSONDecode(bodyOf(response)) end)
        if not decodedOk or type(data) ~= "table" or data.ok ~= true then return false, tostring(data and data.error or "log_rejected") end
        return true
    end

    return self
end

return Runtime
