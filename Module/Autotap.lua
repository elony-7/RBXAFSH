-- AutoTap.lua (with debug prints)
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
        print("[AutoTap] ConfirmFishingInput called")
        _G.confirmFishingInput()
    else
        warn("[AutoTap] _G.confirmFishingInput not available")
    end
end

-- Loop while running
local function startLoop()
    print("[AutoTap] Tap loop started")
    tapLoop = task.spawn(function()
        while running do
            doTap()
            task.wait(0.15) -- safe interval
        end
    end)
end

-- Stop the loop
local function stopLoop()
    print("[AutoTap] Tap loop stopping...")
    running = false
end

-- Hook RemoteEvents
FishingMinigameChanged.OnClientEvent:Connect(function(state)
    print("[AutoTap] FishingMinigameChanged received →", state)
    if state == "Start" then
        if not running then
            running = true
            print("[AutoTap] State = Start → Beginning AutoTap")
            startLoop()
        else
            print("[AutoTap] Already running, ignoring Start")
        end
    else
        print("[AutoTap] Unhandled state:", state)
    end
end)

FishingStopped.OnClientEvent:Connect(function()
    print("[AutoTap] FishingStopped received")
    if running then
        stopLoop()
        print("[AutoTap] AutoTap stopped by FishingStopped event")
    else
        print("[AutoTap] Was not running when FishingStopped fired")
    end
end)

-- API
function AutoTap.Start()
    if running then
        warn("[AutoTap] Start called but already running")
        return
    end
    running = true
    print("[AutoTap] Force started manually")
    startLoop()
end

function AutoTap.Stop()
    if running then
        print("[AutoTap] Force stop called")
        stopLoop()
    else
        print("[AutoTap] Stop called but already stopped")
    end
end

return AutoTap
