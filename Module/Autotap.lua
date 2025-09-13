-- AutoTap.lua (safe _G.confirmFishingInput detection)
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

-- Perform one "tap"
local function doTap()
    if _G.confirmFishingInput then
        print("[AutoTap] ConfirmFishingInput called")
        _G.confirmFishingInput()
    else
        warn("[AutoTap] confirmFishingInput not available yet, waiting...")
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
            -- Wait until confirmFishingInput exists
            task.spawn(function()
                local waited = 0
                while not _G.confirmFishingInput and waited < 5 do
                    print("[AutoTap] Waiting for confirmFishingInput...")
                    task.wait(0.2)
                    waited += 0.2
                end

                if _G.confirmFishingInput then
                    running = true
                    print("[AutoTap] confirmFishingInput found → Starting AutoTap")
                    startLoop()
                else
                    warn("[AutoTap] confirmFishingInput never appeared (timeout)")
                end
            end)
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
