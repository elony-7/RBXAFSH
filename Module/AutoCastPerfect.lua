-- AutoCastPerfect.lua
local AutoCastPerfect = {}
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Module state
local running = false
local loopThread

-- Utility to get screen center
local function getScreenCenter()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X / 2, viewportSize.Y / 2
end

-- Main detection function using task.wait
local function detectionLoop()
    local centerX, centerY = getScreenCenter()

    -- Wait for GUI
    local chargeGui = player:WaitForChild("PlayerGui"):WaitForChild("Charge")
    local bar = chargeGui:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")

    -- Hold mouse down
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    print("[AutoCastPerfect] Mouse held down")

    -- Detection loop with hardcoded delay
    loopThread = task.spawn(function()
        while running do
            task.wait(0.1) -- hardcoded delay ~100ms

            if not running then break end

            local barScaleY = bar.Size.Y.Scale
            local firstDecimal = math.floor((barScaleY * 10) % 10)
            if firstDecimal == 9 then
                VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                print("[AutoCastPerfect] Mouse released! Detected bar scale Y:", barScaleY)
                AutoCastPerfect.Stop()
                break
            end
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

    -- Release mouse
    local centerX, centerY = getScreenCenter()
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)

    print("[AutoCastPerfect] Stopped")
end

return AutoCastPerfect
