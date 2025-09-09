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
        if child.Name == "!!!EQUIPPED_TOOL!!!" then
            local mainChild = child:FindFirstChild("Main")
            if mainChild then break end
            mainChild = child.ChildAdded:Wait()
            while mainChild.Name ~= "Main" do
                mainChild = child.ChildAdded:Wait()
            end
            break
        end
    end
end

-- Corrected function to play animation from module
local function playAnimation(character, animData, looped)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return nil end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    -- animData must have AnimationId
    if not animData or not animData.AnimationId then
        warn("AnimationId missing in module", animData)
        return nil
    end

    -- Create Animation instance
    local animation = Instance.new("Animation")
    animation.AnimationId = animData.AnimationId

    -- Load it into Animator safely
    local track
    local ok, err = pcall(function()
        track = animator:LoadAnimation(animation)
    end)
    if not ok then
        warn("Failed to load animation:", err)
        return nil
    end

    -- Set track properties safely
    track.Priority = animData.AnimationPriority or Enum.AnimationPriority.Action
    track.Looped = looped or animData.Looped or false

    if animData.PlaybackSpeed then
        track:AdjustSpeed(animData.PlaybackSpeed)
    end

    track:Play()
    return track
end

-- Handle linked markers for animations
local function handleLinkedMarkers(track, animData, character, AnimationsFolder)
    if animData.LinkedMarkers then
        for markerName, linkedName in pairs(animData.LinkedMarkers) do
            track:GetMarkerReachedSignal(markerName):Connect(function()
                local linkedAnim = AnimationsFolder:FindFirstChild(linkedName)
                if linkedAnim then
                    playAnimation(character, linkedAnim, true) -- loop reel idle
                end
            end)
        end
    end
end

-- Start auto fishing
function AutoFishing.Start()
    AutoFishing.Enabled = true
    task.spawn(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local AnimationsFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations")

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

            -- Wait until the equipped tool is ready
            waitForEquip(char)

            -- 1️⃣ Start charging animation
            local chargeAnimData = AnimationsFolder:WaitForChild("StartChargingRod1Hand")
            local chargeTrack = playAnimation(char, chargeAnimData)
            log("🎬 Playing charge animation...")

            -- 2️⃣ Hold charge for desired time (simulate mouse hold)
            local chargeHoldTime = chargeAnimData.Length or 2.5
            task.wait(chargeHoldTime)

            -- 3️⃣ Release charge → tell server
            local chargeRF = netFolder:FindFirstChild("RF/ChargeFishingRod")
            if chargeRF then
                pcall(function()
                    chargeRF:InvokeServer(workspace:GetServerTimeNow())
                end)
                log("⚡ Released charge (server notified)")
            end

            -- 4️⃣ Play cast animation
            local castAnimData = AnimationsFolder:WaitForChild("CastFromFullChargePosition1Hand")
            local castTrack = playAnimation(char, castAnimData)
            handleLinkedMarkers(castTrack, castAnimData, char, AnimationsFolder)
            log("🎬 Playing cast animation...")
            if castTrack then castTrack.Stopped:Wait() end

            -- 5️⃣ Start FishingRodReelIdle looped animation
            local reelAnimData = AnimationsFolder:WaitForChild("FishingRodReelIdle")
            local reelTrack = playAnimation(char, reelAnimData, true)
            log("🎣 Playing reel idle animation (looping)...")

            -- Start fishing minigame
            local startRF = netFolder:FindFirstChild("RF/RequestFishingMinigameStarted")
            if startRF then
                pcall(function()
                    startRF:InvokeServer(-1.2379989624023438, 1)
                end)
                log("🎮 Minigame started")
            end

            task.wait(1) -- simulated minigame duration

            -- Stop reel idle when finished
            if reelTrack then
                reelTrack:Stop()
            end

            -- Complete fishing minigame
            local completedRE = netFolder:FindFirstChild("RE/FishingCompleted")
            if completedRE then
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
