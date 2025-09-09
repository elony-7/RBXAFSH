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

-- Helper: play an animation on the character using the full module path
local function playAnimation(character, animModulePath)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return nil end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animData = animModulePath
    if not animData or not animData.Animation then
        warn("Animation not found at path:", animModulePath:GetFullName())
        return nil
    end

    local track = animator:LoadAnimation(animData.Animation)
    track.Priority = animData.AnimationPriority or Enum.AnimationPriority.Action
    track:Play()
    return track
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
                task.wait(1)
                continue
            end

            -- Wait until the equipped tool is fully ready
            waitForEquip(char)
            log("✅ Fishing rod equipped, starting casting...")

            -- Play charging animation
            local chargeTrack = playAnimation(char, ReplicatedStorage.Modules.Animations.StartChargingRod1Hand)
            if chargeTrack then
                log("🎬 Playing charge animation...")
            end

            -- Notify server that we're charging
            local chargeRF = netFolder:FindFirstChild("RF/ChargeFishingRod")
            if chargeRF and chargeRF:IsA("RemoteFunction") then
                pcall(function()
                    chargeRF:InvokeServer(workspace:GetServerTimeNow())
                end)
                log("⚡ Charging rod (server notified)...")
            else
                log("⚠️ ChargeFishingRod not found!")
                task.wait(1)
                continue
            end

            -- Wait for charge animation to finish
            if chargeTrack then
                chargeTrack.Stopped:Wait()
            else
                task.wait(2.7) -- fallback wait
            end

            -- Play cast animation
            local castTrack = playAnimation(char, ReplicatedStorage.Modules.Animations.CastFromFullChargePosition1Hand)
            if castTrack then
                log("🎬 Playing cast animation...")
            end

            -- Start fishing minigame
            local startRF = netFolder:FindFirstChild("RF/RequestFishingMinigameStarted")
            if startRF and startRF:IsA("RemoteFunction") then
                log("🎮 Starting fishing minigame...")
                local success, result = pcall(function()
                    return startRF:InvokeServer(-1.2379989624023438, 1)
                end)
                if success then
                    log("✅ Minigame start acknowledged by server: " .. tostring(result))
                else
                    log("❌ Failed to start minigame: " .. tostring(result))
                end
            else
                log("⚠️ RequestFishingMinigameStarted not found!")
                task.wait(1)
                continue
            end

            task.wait(1) -- simulated minigame duration

            -- Complete fishing minigame
            local completedRE = netFolder:FindFirstChild("RE/FishingCompleted")
            if completedRE and completedRE:IsA("RemoteEvent") then
                pcall(function()
                    completedRE:FireServer()
                end)
                log("✅ Completing fishing minigame...")
            else
                log("⚠️ FishingCompleted not found!")
            end
        end
    end)
end

-- Stop auto fishing
function AutoFishing.Stop()
    AutoFishing.Enabled = false
end

return AutoFishing
