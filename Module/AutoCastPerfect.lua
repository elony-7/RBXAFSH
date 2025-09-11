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

-- Utility: screen corner (bottom-right)
local function getScreenCorner()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X - 1, viewportSize.Y - 1
end

-- Wait for UpdateChargeState with 6s timeout
local function waitForUpdateCharge(timeout)
    timeout = timeout or 1
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
        task.wait(1.5) -- 2300ms delay after successful UpdateChargeState
    end
end

-- Perform one cast cycle
local function castCycle()
    if not running then return end

    local clickX, clickY = getScreenCorner()
    local chargeGui = player:WaitForChild("PlayerGui"):WaitForChild("Charge")
    local bar = chargeGui:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")
    local timeout = 1
    local startTime = tick()

    -- Hold mouse down at start
    VirtualInput:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
    print("[AutoCastPerfect] Mouse held down for new cast cycle")

    local cycleDone = false
    local conn

    -- Listen for Size property changes instead of looping
    conn = bar:GetPropertyChangedSignal("Size"):Connect(function()
        if not running or cycleDone then return end

        local barScaleY = bar.Size.Y.Scale
        if barScaleY >= 0.93 then
            VirtualInput:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
            print(string.format("[AutoCastPerfect] Mouse released! Bar scale Y: %.10f", barScaleY))
            cycleDone = true
            if conn then conn:Disconnect() conn = nil end
        end
    end)

    -- Timeout safeguard
    task.spawn(function()
        while running and not cycleDone and (tick() - startTime < timeout) do
            task.wait(0.05)
        end
        if not cycleDone and running then
            VirtualInput:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
            print("[AutoCastPerfect] Timeout reached, releasing mouse and starting next cycle")
            cycleDone = true
            if conn then conn:Disconnect() conn = nil end
        end
    end)

    -- Wait until cycle done
    repeat task.wait() until cycleDone or not running
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
    local clickX, clickY = getScreenCorner()
    VirtualInput:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
    print("[AutoCastPerfect] Stopped")
end

return AutoCastPerfect
