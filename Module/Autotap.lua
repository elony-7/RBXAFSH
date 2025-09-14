-- AutoTap.lua
local AutoTap = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Network reference for stopping
local netFolder = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
local net = netFolder:WaitForChild("net")
local fishingStopped = net:WaitForChild("RE/FishingStopped")

-- State
local running = false
local tapThread
local stopConn

-- Bottom-right screen position
local function getScreenCorner()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X - 1, viewportSize.Y - 1
end

-- Send a quick tap (mouse down + up)
local function sendTap()
    local clickX, clickY = getScreenCorner()
    -- Mouse down
    VirtualInput:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
    -- Mouse up
    VirtualInput:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
end

-- Start AutoTap
function AutoTap.Start()
    if running then return end
    running = true
    print("[AutoTap] Started")

    -- Persistent tap loop
    tapThread = task.spawn(function()
        while running do
            sendTap()
            task.wait(0.25) -- 250ms interval
        end
    end)

    -- Stop when fishing stops
    stopConn = fishingStopped.OnClientEvent:Connect(function()
        AutoTap.Stop()
    end)
end

-- Stop AutoTap
function AutoTap.Stop()
    if not running then return end
    running = false
    print("[AutoTap] Stopped")

    -- Ensure mouse is released
    local clickX, clickY = getScreenCorner()
    VirtualInput:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)

    if stopConn then
        stopConn:Disconnect()
        stopConn = nil
    end

    tapThread = nil
end

return AutoTap
