-- AutoTap.lua
local AutoTap = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

-- Perform one "tap" using the game's function
local function doTap()
    if _G.confirmFishingInput then
        _G.confirmFishingInput()
    end
end

-- Loop while running
local function startLoop()
    tapLoop = task.spawn(function()
        while running do
            doTap()
            task.wait(0.15) -- safe interval
        end
    end)
end

-- Stop the loop
local function stopLoop()
    running = false
end

-- Hook RemoteEvents
FishingMinigameChanged.OnClientEvent:Connect(function(state)
    if state == "Start" then
        if not running then
            running = true
            startLoop()
            print("[AutoTap] Fishing started → AutoTap running")
        end
    end
end)

FishingStopped.OnClientEvent:Connect(function()
    if running then
        stopLoop()
        print("[AutoTap] Fishing stopped → AutoTap stopped")
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
    print("[AutoTap] Force started")
end

function AutoTap.Stop()
    if running then
        stopLoop()
        print("[AutoTap] Force stopped")
    end
end

return AutoTap
