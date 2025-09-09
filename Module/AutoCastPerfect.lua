-- AutoCastPerfect.lua
local AutoCastPerfect = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Module state
local running = false
local updateChargeRE = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RE/UpdateChargeState")

-- Utility: screen center
local function getScreenCenter()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X / 2, viewportSize.Y / 2
end

-- Wait for UpdateChargeState
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
    repeat task.wait(0.05) until fired or not running
    task.wait(1.5) -- 300ms delay after event
end

-- Perform one cast cycle
local function castCycle()
    if not running then return end

    local centerX, centerY = getScreenCenter()
    local chargeGui = player:WaitForChild("PlayerGui"):WaitForChild("Charge")
    local bar = chargeGui:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")
    local lastCheck = 0
    local checkInterval = 0.200

    -- Hold mouse down at start
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    print("[AutoCastPerfect] Mouse held down for new cast cycle")

    -- Use RenderStepped for this cycle
    local connection
    connection = RunService.RenderStepped:Connect(function(delta)
        if not running then
            if connection then connection:Disconnect() end
            return
        end

        lastCheck = lastCheck + delta
        if lastCheck < checkInterval then return end
        lastCheck = 0

        local barScaleY = bar.Size.Y.Scale
        local firstDecimal = math.floor((barScaleY * 10) % 10)
        if firstDecimal == 9 then
            -- Release mouse when perfect
            VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            print("[AutoCastPerfect] Mouse released! Bar scale Y:", barScaleY)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)

    -- Wait until mouse is released (perfect value reached)
    repeat task.wait(0.05) until not connection or not running
    if not running then return end

    -- Wait for UpdateChargeState event before next cycle
    waitForUpdateCharge()
end

-- Main loop
local function mainLoop()
    while running do
        castCycle()
    end
end

-- Start module
function AutoCastPerfect.Start()
    if running then
        print("[AutoCastPerfect] Already running")
        return
    end
    running = true
    task.spawn(mainLoop)
end

-- Stop module
function AutoCastPerfect.Stop()
    if not running then return end
    running = false

    -- Release mouse
    local centerX, centerY = getScreenCenter()
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    print("[AutoCastPerfect] Stopped")
end

return AutoCastPerfect
