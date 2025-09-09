-- AutoCastPerfect.lua
local AutoCastPerfect = {}
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Module state
local running = false
local connection
local lastCheck = 0
local checkInterval = 0.500 -- 100ms

-- Utility to get screen center
local function getScreenCenter()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X / 2, viewportSize.Y / 2
end

-- Main detection function
local function detectionLoop()
    local centerX, centerY = getScreenCenter()

    -- Wait for GUI
    local chargeGui = player:WaitForChild("PlayerGui"):WaitForChild("Charge")
    local bar = chargeGui:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")

    -- Reset lastCheck every start
    lastCheck = 0

    -- Hold mouse down
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    print("[AutoCastPerfect] Mouse held down")

    -- Disconnect any existing connection to prevent duplicates
    if connection then
        connection:Disconnect()
        connection = nil
    end

    -- Detection loop
    connection = RunService.RenderStepped:Connect(function(delta)
        if not running then return end

        lastCheck = lastCheck + delta
        if lastCheck < checkInterval then return end
        lastCheck = 0

        local barScaleY = bar.Size.Y.Scale
        local firstDecimal = math.floor((barScaleY * 10) % 10)
        if firstDecimal == 9 then
            VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            print("[AutoCastPerfect] Mouse released! Detected bar scale Y:", barScaleY)
            AutoCastPerfect.Stop()
        end
    end)
end

-- Start module
function AutoCastPerfect.Start()
    if running then
        print("[AutoCastPerfect] Already running")
        return
    end
    running = true
    detectionLoop()
end

-- Stop module
function AutoCastPerfect.Stop()
    if not running then return end
    running = false

    -- Disconnect connection
    if connection then
        connection:Disconnect()
        connection = nil
    end

    -- Reset lastCheck for next start
    lastCheck = 0

    -- Release mouse
    local centerX, centerY = getScreenCenter()
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    print("[AutoCastPerfect] Stopped")
end

return AutoCastPerfect
