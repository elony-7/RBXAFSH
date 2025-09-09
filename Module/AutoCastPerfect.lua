-- AutoCastPerfect.lua
local AutoCastPerfect = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Module state
local running = false
local connection
local lastCheck = 0
local checkInterval = 0.200 -- 200ms

-- RemoteEvent for UpdateChargeState
local updateChargeRE = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RE/UpdateChargeState")

-- Utility to get screen center
local function getScreenCenter()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X / 2, viewportSize.Y / 2
end

-- Wait for UpdateChargeState event
local function waitForUpdateCharge()
    local fired = false
    local conn
    conn = updateChargeRE.OnClientEvent:Connect(function()
        fired = true
        if conn then
            conn:Disconnect()
            conn = nil
        end
    end)

    -- Wait until the event fires or toggle is off
    repeat task.wait(0.05) until fired or not running
    task.wait(0.3) -- 300ms delay after event
end

-- Main detection loop
local function detectionLoop()
    while running do
        local centerX, centerY = getScreenCenter()

        -- Wait for GUI
        local chargeGui = player:WaitForChild("PlayerGui"):WaitForChild("Charge")
        local bar = chargeGui:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")

        -- Hold mouse down
        VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        print("[AutoCastPerfect] Mouse held down")

        lastCheck = 0

        -- Disconnect previous connection if any
        if connection then
            connection:Disconnect()
            connection = nil
        end

        -- Detection loop for this cast
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
            end
        end)

        -- Wait for UpdateChargeState before next cast
        waitForUpdateCharge()
    end
end

-- Start module
function AutoCastPerfect.Start()
    if running then
        print("[AutoCastPerfect] Already running")
        return
    end
    running = true
    task.spawn(detectionLoop)
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

    -- Release mouse
    local centerX, centerY = getScreenCenter()
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    print("[AutoCastPerfect] Stopped")
end

return AutoCastPerfect
