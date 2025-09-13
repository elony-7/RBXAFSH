-- AutoTap.lua
local AutoTap = {}
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local running = false
local connHeartbeat

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

-- Check if Fishing.Main GUI is active
local function isFishingActive()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return false end

    local fishing = gui:FindFirstChild("Fishing")
    if not fishing then return false end

    local main = fishing:FindFirstChild("Main")
    if not main then return false end

    return main.Visible == true -- tap only when visible
end

-- Main loop tied to Heartbeat
local function mainLoop()
    if connHeartbeat then connHeartbeat:Disconnect() end

    connHeartbeat = RunService.Heartbeat:Connect(function()
        if not running then return end

        if isFishingActive() then
            tapOnce()
        end
    end)
end

function AutoTap.Start()
    if running then
        print("[AutoTap] Already running")
        return
    end
    running = true
    mainLoop()
    print("[AutoTap] Started")
end

function AutoTap.Stop()
    if not running then return end
    running = false
    if connHeartbeat then
        connHeartbeat:Disconnect()
        connHeartbeat = nil
    end
    print("[AutoTap] Stopped")
end

return AutoTap
