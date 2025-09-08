-- AutoReel.lua
local AutoReel = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Flag to track status
AutoReel.Enabled = false

-- Connections table
local connections = {}

-- Helper function for debugging
local function log(msg)
    print("[AutoReel] " .. msg)
end

-- Function to safely wait for a child with optional timeout
local function WaitForChildRecursive(parent, childName, timeout)
    local obj
    local success, err = pcall(function()
        obj = parent:WaitForChild(childName, timeout)
    end)
    if success then
        return obj
    else
        return nil
    end
end

-- Main function to start listening for minigame events
function AutoReel.Start()
    if AutoReel.Enabled then
        log("⚠️ AutoReel already running")
        return
    end
    AutoReel.Enabled = true

    task.spawn(function()
        -- Wait for character
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        -- Wait for netFolder
        local netFolder
        repeat
            local packages = WaitForChildRecursive(ReplicatedStorage, "Packages", 5)
            local index = packages and WaitForChildRecursive(packages, "_Index", 5)
            local sleitnick = index and WaitForChildRecursive(index, "sleitnick_net@0.2.0", 5)
            netFolder = sleitnick and sleitnick:FindFirstChild("net")
            if not netFolder then
                log("⚠️ Net folder not found, retrying...")
                task.wait(1)
            end
        until netFolder

        log("✅ Net folder found")

        -- Wait for RemoteEvents
        local startRE, completedRE
        repeat
            local reFolder = netFolder:FindFirstChild("RE")
            startRE = reFolder and reFolder:FindFirstChild("RequestFishingMinigameStarted")
            completedRE = reFolder and reFolder:FindFirstChild("FishingCompleted")
            if not startRE or not completedRE then
                
                task.wait(0)
            end
        until startRE and completedRE

        log("✅ RemoteEvents found, listening for minigame events...")

        -- Connect to minigame start event
        connections["_autoreel"] = startRE.OnClientEvent:Connect(function(...)
            if AutoReel.Enabled then
                log("🎣 Fishing minigame detected! Auto-reeling...")

                -- Fire the completion event
                pcall(function()
                    completedRE:FireServer()
                end)
                log("✅ Auto-reel sent!")
            end
        end)
    end)
end

-- Stop function
function AutoReel.Stop()
    AutoReel.Enabled = false
    if connections["_autoreel"] then
        connections["_autoreel"]:Disconnect()
        connections["_autoreel"] = nil
    end
    log("⏹ AutoReel stopped.")
end

return AutoReel
