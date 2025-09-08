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

function AutoReel.Start()
    if AutoReel.Enabled then
        log("⚠️ AutoReel already running")
        return
    end
    AutoReel.Enabled = true

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

        local reFolder = netFolder:FindFirstChild("RE")
        if not reFolder then
            log("❌ Could not find RE folder in net")
            AutoReel.Enabled = false
            return
        end

        local playEffectRE = reFolder:FindFirstChild("PlayFishingEffect")
        local completedRE = reFolder:FindFirstChild("FishingCompleted")

        if not playEffectRE or not completedRE then
            log("❌ Missing required RemoteEvents (PlayFishingEffect / FishingCompleted)")
            AutoReel.Enabled = false
            return
        end

        log("✅ Listening for PlayFishingEffect...")

        -- When PlayFishingEffect fires, we spoof "perfect" and auto-complete
        connections["_autoreel"] = playEffectRE.OnClientEvent:Connect(function(playerName, partName, quality)
            if not AutoReel.Enabled then return end

            log(("🎣 PlayFishingEffect: %s, %s, quality=%s"):format(tostring(playerName), tostring(partName), tostring(quality)))

            -- Wait a tiny bit to mimic human timing
            task.wait(0.2)

            -- Fire FishingCompleted to end the minigame instantly
            pcall(function()
                completedRE:FireServer()
            end)

            log("✅ AutoReel: Sent FishingCompleted (auto-finished reeling)")
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
