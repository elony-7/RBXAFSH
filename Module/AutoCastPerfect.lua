-- AutoCastPerfect.lua
local AutoCastPerfect = {}
local Players = game:GetService("Players")
local VirtualInput = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Module state
local running = false
local loopThread

-- Screen center utility
local function getScreenCenter()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return viewportSize.X / 2, viewportSize.Y / 2
end

-- Start module
function AutoCastPerfect.Start()
    if running then
        print("[AutoCastPerfect] Already running")
        return
    end
    running = true

    local centerX, centerY = getScreenCenter()

    -- Wait for GUI
    local chargeGui = player:WaitForChild("PlayerGui"):WaitForChild("Charge")
    local bar = chargeGui:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")

    -- Hold mouse down
    VirtualInput:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
    print("[AutoCastPerfect] Mouse held down")

    -- Run detection in a separate thread
    loopThread = task.spawn(function()
        while running do
            -- Hardcoded delay
            task.wait(0.067) -- ~15 times per second

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
