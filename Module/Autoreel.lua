-- AutoReel.lua
local AutoReel = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Flag to track status
AutoReel.Enabled = false

-- Connections table for cleanup
local connections = {}

-- Helper function for debugging
local function log(msg)
    print("[AutoReel] " .. msg)
end

-- Safe WaitForChild with timeout
local function WaitForChildRecursive(parent, childName, timeout)
    local obj
    local success = pcall(function()
        obj = parent:WaitForChild(childName, timeout)
    end)
    return success and obj or nil
end

-- Safe polling for RE folder
local function WaitForREFolder(netFolder, retryDelay, maxRetries)
    retryDelay = retryDelay or 0.5
    maxRetries = maxRetries or 20 -- total 10 seconds by default
    local retries = 0
    local reFolder
    while retries < maxRetries do
        reFolder = netFolder:FindFirstChild("RE")
        if reFolder then
            return reFolder
        end
        task.wait(retryDelay)
        retries = retries + 1
    end
    return nil
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

        -- Wait for net folder
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

        -- Wait for RemoteEvents safely
        local reFolder = WaitForREFolder(netFolder, 0.5, 20)
        if not reFolder then
            log("❌ RE folder not found after timeout")
            AutoReel.Enabled = false
            return
        end

        local minigameRE = reFolder:FindFirstChild("FishingMinigameChanged")
        local completedRE = reFolder:FindFirstChild("FishingCompleted")
        if not minigameRE or not completedRE then
            log("❌ Required RemoteEvents not found!")
            AutoReel.Enabled = false
            return
        end

        log("✅ RemoteEvents found, listening for minigame events...")

        -- Connect to minigame state changes
        connections["_autoreel"] = minigameRE.OnClientEvent:Connect(function(state, ...)
            if not AutoReel.Enabled then return end

            log("Minigame state:", state, ...)

            -- Start auto-reeling when minigame is in "reeling" state
            if state == "Started" or state == "Reeling" then
                log("🎣 Reeling detected! Auto-reeling...")

                -- Spawn a loop to continuously fire FishingCompleted while reeling
                if not connections["_reelLoop"] then
                    connections["_reelLoop"] = RunService.RenderStepped:Connect(function()
                        if AutoReel.Enabled and completedRE then
                            pcall(function()
                                completedRE:FireServer()
                            end)
                        end
                    end)
                end

            -- Stop auto-reel when minigame ends
            elseif state == "Ended" or state == "Stopped" then
                if connections["_reelLoop"] then
                    connections["_reelLoop"]:Disconnect()
                    connections["_reelLoop"] = nil
                    log("⏹ Minigame ended, auto-reel stopped.")
                end
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
    if connections["_reelLoop"] then
        connections["_reelLoop"]:Disconnect()
        connections["_reelLoop"] = nil
    end
    log("⏹ AutoReel fully stopped.")
end

return AutoReel
