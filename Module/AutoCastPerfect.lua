-- AutoCastPerfect.lua
local AutoCastPerfect = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser") -- swapped in!
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Module state
local running = false
local updateChargeRE = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RE/UpdateChargeState")

-- Utility: screen bottom-right
local function getScreenBottomRight()
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

    local chargeGui = player:WaitForChild("PlayerGui"):WaitForChild("Charge")
    local bar = chargeGui:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")
    local timeout = 8
    local startTime = tick()

    -- Hold mouse down at start (VirtualUser)
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new())
    print("[AutoCastPerfect] Mouse held down for new cast cycle")

    -- PropertyChangedSignal for bar size
    local cycleDone = false
    local connection
    connection = bar:GetPropertyChangedSignal("Size"):Connect(function()
        if not running or cycleDone then return end

        local barScaleY = bar.Size.Y.Scale
        if barScaleY >= 0.93 then
            -- Release mouse
            VirtualUser:Button1Up(Vector2.new())
            print("[AutoCastPerfect] Mouse released! Bar scale Y:", barScaleY)
            cycleDone = true
            if connection then connection:Disconnect() connection = nil end
        end
    end)

    -- Timeout safety
    task.delay(timeout, function()
        if not running or cycleDone then return end
        VirtualUser:Button1Up(Vector2.new())
        print("[AutoCastPerfect] Timeout reached, releasing mouse and starting next cycle")
        cycleDone = true
        if connection then connection:Disconnect() connection = nil end
    end)

    repeat task.wait() until cycleDone or not running
    if not running then return end

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

    -- Release mouse just in case
    VirtualUser:Button1Up(Vector2.new())
    print("[AutoCastPerfect] Stopped")
end

return AutoCastPerfect
