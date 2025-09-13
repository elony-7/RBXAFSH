-- AutoTap.lua (RemoteEvent-driven)
local AutoTap = {}
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local running = false
local tapLoop

-- Net package reference
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

-- RemoteEvents
local FishingMinigameChanged = net:WaitForChild("RE/FishingMinigameChanged")
local FishingStopped = net:WaitForChild("RE/FishingStopped")

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
    print("[AutoTap] Tap sent")
end

-- Loop
local function startLoop()
    if tapLoop then return end
    print("[AutoTap] Tap loop started")
    tapLoop = task.spawn(function()
        while running do
            tapOnce()
            task.wait(0.15) -- adjust tap speed here
        end
    end)
end

-- Stop loop
local function stopLoop()
    print("[AutoTap] Tap loop stopping...")
    running = false
    tapLoop = nil
end

-- Hook RemoteEvents
FishingMinigameChanged.OnClientEvent:Connect(function(state)
    print("[AutoTap] FishingMinigameChanged →", state)
    if state == "Start" and not running then
        running = true
        startLoop()
    end
end)

FishingStopped.OnClientEvent:Connect(function()
    print("[AutoTap] FishingStopped received")
    if running then
        stopLoop()
        print("[AutoTap] AutoTap stopped")
    end
end)

-- API
function AutoTap.Start()
    if running then
        warn("[AutoTap] Already running")
        return
    end
    running = true
    startLoop()
    print("[AutoTap] Force started manually")
end

function AutoTap.Stop()
    if running then
        stopLoop()
        print("[AutoTap] Force stopped manually")
    else
        print("[AutoTap] Stop called but not running")
    end
end

return AutoTap
