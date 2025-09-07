-- AutoFishing.lua
local AutoFishing = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Flag to track status
AutoFishing.Enabled = false

-- Helper function to wait for the tool to equip
local function waitForEquip()
    local char = Players.LocalPlayer.Character
    if not char then return end
    local tool
    repeat
        tool = char:FindFirstChildOfClass("Tool")
        task.wait(0.1)
    until tool or not AutoFishing.Enabled
end

-- Main loop for auto fishing
function AutoFishing.Start()
    AutoFishing.Enabled = true
    task.spawn(function()
        while AutoFishing.Enabled do
            task.wait(0.5)

            -- Get net folder
            local ok, netFolder = pcall(function()
                return ReplicatedStorage:WaitForChild("Packages")
                    :WaitForChild("_Index")
                    :WaitForChild("sleitnick_net@0.2.0").net
            end)
            if not ok or not netFolder then
                warn("⚠️ Net folder not found, retrying...")
                task.wait(1)
                continue
            end

            -- Equip fishing rod
            local equipRE = netFolder:FindFirstChild("RE/EquipToolFromHotbar")
            if equipRE then
                pcall(function() equipRE:FireServer(1) end)
                waitForEquip()
            else
                warn("⚠️ EquipToolFromHotbar not found!")
            end

            -- Charge fishing rod
            local chargeRF = netFolder:FindFirstChild("RF/ChargeFishingRod")
            if chargeRF and chargeRF:IsA("RemoteFunction") then
                pcall(function()
                    chargeRF:InvokeServer(workspace:GetServerTimeNow())
                end)
            end

            -- Start fishing minigame
            local startRF = netFolder:FindFirstChild("RF/RequestFishingMinigameStarted")
            if startRF and startRF:IsA("RemoteFunction") then
                pcall(function()
                    startRF:InvokeServer(-1.2379989624023438, 1)
                end)
            end

            task.wait(2.5)

            -- Complete fishing minigame
            local completedRE = netFolder:FindFirstChild("RE/FishingCompleted")
            if completedRE and completedRE:IsA("RemoteEvent") then
                pcall(function() completedRE:FireServer() end)
            end
        end
    end)
end

function AutoFishing.Stop()
    AutoFishing.Enabled = false
end

return AutoFishing
