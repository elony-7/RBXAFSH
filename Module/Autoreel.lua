-- AutoReel.lua
local AutoReel = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Flags
AutoReel.Enabled = false
local connections = {}

local function log(msg)
    print("[AutoReel] " .. msg)
end

-- Utility to wait for objects safely
local function WaitForPath(root, pathArray, timeout)
    local current = root
    for _, name in ipairs(pathArray) do
        current = current:WaitForChild(name, timeout or 5)
        if not current then return nil end
    end
    return current
end

-- Build DisplayName → Player map
local function BuildDisplayNameMap()
    local map = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        map[plr.DisplayName] = plr
    end
    return map
end

function AutoReel.Start()
    if AutoReel.Enabled then
        log("⚠️ AutoReel already running")
        return
    end
    AutoReel.Enabled = true

    local displayNameMap = BuildDisplayNameMap()
    -- Update map whenever a new player joins
    Players.PlayerAdded:Connect(function(plr)
        displayNameMap[plr.DisplayName] = plr
    end)
    Players.PlayerRemoving:Connect(function(plr)
        displayNameMap[plr.DisplayName] = nil
    end)

    task.spawn(function()
        -- Path into net folder
        local netFolder = WaitForPath(ReplicatedStorage, {
            "Packages", "_Index", "sleitnick_net@0.2.0", "net"
        }, 10)

        if not netFolder then
            log("❌ Could not find net folder")
            AutoReel.Enabled = false
            return
        end

        -- Grab events directly
        local playEffectRE = netFolder:FindFirstChild("RE/PlayFishingEffect")
        local textEffectRE = netFolder:FindFirstChild("RE/ReplicateTextEffect")
        local completedRE = netFolder:FindFirstChild("RE/FishingCompleted")

        if not playEffectRE or not textEffectRE or not completedRE then
            log("❌ Missing required RemoteEvents (PlayFishingEffect / ReplicateTextEffect / FishingCompleted)")
            AutoReel.Enabled = false
            return
        end

        log("✅ Listening for RE/PlayFishingEffect...")

        -- Step 1: when PlayFishingEffect fires
        connections["_autoreel_play"] = playEffectRE.OnClientEvent:Connect(function(playerDisplayName, partName, quality)
            if not AutoReel.Enabled then return end

            local plr = displayNameMap[playerDisplayName]
            if plr ~= LocalPlayer then
                log(("⏩ Ignored PlayFishingEffect from %s"):format(tostring(playerDisplayName)))
                return
            end

            log(("🎣 PlayFishingEffect (for me): %s, %s, quality=%s"):format(
                tostring(playerDisplayName),
                tostring(partName),
                tostring(quality)
            ))

            -- Step 2: wait for ReplicateTextEffect before sending FishingCompleted
            local conn
            conn = textEffectRE.OnClientEvent:Connect(function(textPlayerDisplayName, ...)
                if not AutoReel.Enabled then return end

                local plr2 = displayNameMap[textPlayerDisplayName]
                if plr2 ~= LocalPlayer then
                    log(("⏩ Ignored ReplicateTextEffect from %s"):format(tostring(textPlayerDisplayName)))
                    return
                end

                log("💡 ReplicateTextEffect received, conditions met — finishing reel...")

                log("💡 Waited 1 sec")
                local start = tick()
                while AutoReel.Enabled and (tick() - start < 3) do
                    pcall(function()
                        completedRE:FireServer()
                    end)
                    log("✅ AutoReel: Sent RE/FishingCompleted (spam)")
                    task.wait(0.00) -- 5ms delay
                end
                log("✅ AutoReel: DONE")

                -- disconnect after firing once for this cycle
                if conn then
                    conn:Disconnect()
                    conn = nil
                end
            end)
        end)
    end)
end

function AutoReel.Stop()
    AutoReel.Enabled = false
    for name, conn in pairs(connections) do
        if conn.Disconnect then
            conn:Disconnect()
        end
        connections[name] = nil
    end
    log("⏹ AutoReel stopped")
end

return AutoReel
