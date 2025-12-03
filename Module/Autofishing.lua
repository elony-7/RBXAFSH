local AutoFishing = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Flag to track status
AutoFishing.Enabled = false

-- Helper: log messages
local function log(msg)
    print(msg)
end

-- Wait for the equipped fishing tool
local function waitForEquip(character)
    -- Check if tool already exists and has 'Main'
    local equippedTool = character:FindFirstChild("!!!EQUIPPED_TOOL!!!")
    if equippedTool and equippedTool:FindFirstChild("Main") then
        log("✅ Equipped tool with 'Main' already present.")
        return
    end

    log("⏳ Waiting for equipped tool with 'Main'...")

    while AutoFishing.Enabled do
        local child = character.ChildAdded:Wait()
        log("Child added to character:", child.Name)

        if child.Name == "!!!EQUIPPED_TOOL!!!" then
            local mainChild = child:FindFirstChild("Main")
            if mainChild then
                log("✅ Equipped tool with 'Main' detected immediately.")
                break
            else
                log("Waiting for 'Main' inside equipped tool...")
                mainChild = child.ChildAdded:Wait()
                while mainChild.Name ~= "Main" do
                    mainChild = child.ChildAdded:Wait()
                end
                log("✅ 'Main' detected inside equipped tool.")
                break
            end
        end
    end
end

-- Start auto fishing
function AutoFishing.Start()
    AutoFishing.Enabled = true
    task.spawn(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

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
            else
                log("⚠️ EquipToolFromHotbar not found!")
                task.wait(0.05)
                continue
            end

            -- Wait until the equipped tool is fully ready
            waitForEquip(char)
            log("✅ Fishing rod equipped, starting casting...")

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
                log("🎮 Starting fishing minigame...") -- log immediately before sending

                local success, result = pcall(function()
                    return startRF:InvokeServer(1, 1)
                end)

                if success then
                    log("✅ Minigame start acknowledged by server: " .. tostring(result))
                else
                    log("❌ Failed to start minigame: " .. tostring(result))
                end

                log("⏳ Waiting for fishing minigame to complete...")
            end

            task.wait(1) -- Wait for the minigame duration

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

-- Stop auto fishing
function AutoFishing.Stop()
    AutoFishing.Enabled = false
end

return AutoFishing
