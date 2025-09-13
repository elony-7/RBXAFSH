-- AutoTap.lua
local AutoTap = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local running = false
local tapping = false

-- Grab RemoteEvents correctly
local netFolder = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local fishingMinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local fishingStopped = netFolder:WaitForChild("RE/FishingStopped")

-- Utility: bottom-right corner
local function getScreenCorner()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X - 1, viewportSize.Y - 1
end

-- Perform instant tap
local function tapOnce()
    local x, y = getScreenCorner()
    VirtualInput:SendMouseButtonEvent(x, y, 0, true, game, 0)
    VirtualInput:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

-- Start tapping loop
local function startTapping()
    if tapping then return end
    tapping = true
    task.spawn(function()
        while running and tapping do
            tapOnce()
            task.wait(0.15) -- safe interval
        end
    end)
    print("[AutoTap] Started tapping")
end

-- Stop tapping loop
local function stopTapping()
    tapping = false
    print("[AutoTap] Stopped tapping")
end

-- Start module
function AutoTap.Start()
    if running then
        warn("[AutoTap] Already running")
        return
    end
    running = true

    fishingMinigameChanged.OnClientEvent:Connect(function(state)
        if running and state then
            startTapping()
        end
    end)

    fishingStopped.OnClientEvent:Connect(function()
        if running then
            stopTapping()
        end
    end)

    print("[AutoTap] Listening for fishing events...")
end

-- Stop module
function AutoTap.Stop()
    running = false
    stopTapping()
    print("[AutoTap] Fully stopped")
end

return AutoTap
