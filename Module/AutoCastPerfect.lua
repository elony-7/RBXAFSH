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

-- Utility: screen center (now bottom-right)
local function getScreenCenter()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X - 1, viewportSize.Y - 1
end

-- Wait for UpdateChargeState with 6s timeout
local function waitForUpdateCharge(timeout)
    timeout = timeout or 6
    local fired = false
    local conn
    conn = updateChargeRE.OnClientEvent:Connect(function()
        fired = true
        if conn then
            conn:Disconnect()
            conn = nil
        end
    end)

    local startTime = tick()
    while running and not fired and tick() - startTime < timeout do
        task.wait(0.05)
    end

    -- Disconnect in case timeout occurred
    if conn then
        conn:Disconnect()
        conn = nil
    end

    if not fired then
        print("[AutoCastPerfect] UpdateChargeState timeout reached, starting next cycle")
    else
        task.wait(2.3) -- 2300ms delay after successful UpdateChargeState
    end
end

-- Perform one cast cycle
local function castCycle()
    if not running then return end

    local centerX, centerY = getScreenCenter()
    local chargeGui = player:WaitForChild("PlayerGui"):WaitForChild("Charge")
    local bar = chargeGui:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")
    local lastCheck = 0
    local checkInterval = 0.5
    local timeout = 8
    local startTime = tick()

    -- Hold mouse down at start
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    print("[AutoCastPerfect] Mouse held down for new cast cycle")

    -- RenderStepped loop for this cycle
    local connection
    local cycleDone = false
    connection = RunService.RenderStepped:Connect(function(delta)
        if not running or cycleDone then
            if connection then connection:Disconnect() end
            return
        end

        lastCheck = lastCheck + delta
        if lastCheck < checkInterval then return end
        lastCheck = 0

        local barScaleY = bar.Size.Y.Scale
        local firstDecimal = math.floor((barScaleY * 10) % 10)

        -- Release mouse on perfect bar
        if firstDecimal == 9 then
            VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            print("[AutoCastPerfect] Mouse released! Bar scale Y:", barScaleY)
            cycleDone = true
            if connection then connection:Disconnect() connection = nil end
            return
        end

        -- Timeout check
        if tick() - startTime >= timeout then
            VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            print("[AutoCastPerfect] Timeout reached, releasing mouse and starting next cycle")
            cycleDone = true
            if connection then connection:Disconnect() connection = nil end
            return
        end
    end)

    -- Wait until cycle done
    repeat task.wait(0.00) until cycleDone or not running
    if not running then return end

    -- Wait for UpdateChargeState before starting next cycle
    waitForUpdateCharge(timeout)
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
