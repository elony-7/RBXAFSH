-- AutoReel.lua
local AutoReel = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Flag to track status
AutoReel.Enabled = false

-- Helper function for debugging
local function log(msg)
    print("[AutoReel] " .. msg)
end

-- Main function to start listening for minigame events
function AutoReel.Start()
    AutoReel.Enabled = true
    task.spawn(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        -- Wait for netFolder to exist
        local netFolder
        repeat
            local success
            success, netFolder = pcall(function()
                return ReplicatedStorage:WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_net@0.2.0").net
            end)
            if not success or not netFolder then
                log("⚠️ Net folder not found, retrying...")
                task.wait(1)
            end
        until netFolder

        -- Listen for server event that starts the fishing minigame
        local startRE = netFolder:FindFirstChild("RE/RequestFishingMinigameStarted")
        local completedRE = netFolder:FindFirstChild("RE/FishingCompleted")

        if not startRE or not completedRE then
            log("❌ Required RemoteEvents not found!")
            return
        end

        -- Connect to minigame start event
        startRE.OnClientEvent:Connect(function(...)
            if AutoReel.Enabled then
                log("🎣 Fishing minigame detected! Auto-reeling...")

                -- Fire the completion event
                pcall(function()
                    completedRE:FireServer()
                end)
                log("✅ Auto-reel sent!")
            end
        end)

        log("✅ AutoReel started, listening for server minigame events...")
    end)
end

function AutoReel.Stop()
    AutoReel.Enabled = false
    log("⏹ AutoReel stopped.")
end

return AutoReel
