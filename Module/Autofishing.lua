-- AutoFishing.lua
local AutoFishing = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Flag to track status
AutoFishing.Enabled = false

local function waitForEquip()
    -- Check if "!!!EQUIPPED_TOOL!!!" exists and has a child named "main"
    local equippedTool = character:FindFirstChild("!!!EQUIPPED_TOOL!!!")
    if equippedTool and equippedTool:FindFirstChild("main") then
        print("✅ Equipped tool with 'main' already present.")
        return
    end

    print("⏳ Waiting for equipped tool with 'main' to appear...")

    while true do
        local child = character.ChildAdded:Wait()
        print("Child added to character:", child.Name)

        if child.Name == "!!!EQUIPPED_TOOL!!!" then
            -- Wait for "main" to appear inside "!!!EQUIPPED_TOOL!!!"
            local mainChild = child:FindFirstChild("Main")
            if mainChild then
                print("✅ Equipped tool with 'main' detected immediately.")
                break
            else
                print("Waiting for 'main' inside equipped tool...")
                mainChild = child.ChildAdded:Wait()
                while mainChild.Name ~= "Main" do
                    mainChild = child.ChildAdded:Wait()
                end
                print("✅ 'main' detected inside equipped tool.")
                break
            end
        end
    end
end

-- Notification helper (use print for now)
local function log(msg)
    print(msg)
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
                log("⚠️ Net folder not found, retrying...")
                task.wait(1)
                continue
            end

            -- Equip fishing rod
            local equipRE = netFolder:FindFirstChild("RE/EquipToolFromHotbar")
            if equipRE then
                pcall(function()
                    equipRE:FireServer(1)
                end)
                log("🎯 Tried to equip fishing rod (slot 1)")
                waitForEquip()
            else
                log("⚠️ EquipToolFromHotbar not found!")
            end

            -- Charge fishing rod
            local chargeRF = netFolder:FindFirstChild("RF/ChargeFishingRod")
            if chargeRF and chargeRF:IsA("RemoteFunction") then
                pcall(function()
                    chargeRF:InvokeServer(workspace:GetServerTimeNow())
                end)
                log("⚡ Charging rod...")
            end

            -- Start fishing minigame
            local startRF = netFolder:FindFirstChild("RF/RequestFishingMinigameStarted")
            if startRF and startRF:IsA("RemoteFunction") then
                pcall(function()
                    startRF:InvokeServer(-1.2379989624023438, 1)
                end)
                log("🎮 Starting fishing minigame...")
            end

            task.wait(2.5)

            -- Complete fishing minigame
            local completedRE = netFolder:FindFirstChild("RE/FishingCompleted")
            if completedRE and completedRE:IsA("RemoteEvent") then
                pcall(function()
                    completedRE:FireServer()
                end)
                log("✅ Completing fishing minigame...")
            end
        end
    end)
end

function AutoFishing.Stop()
    AutoFishing.Enabled = false
end

return AutoFishing
