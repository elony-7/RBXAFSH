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

-- Start tapping loop
local function startTapping(mainGui)
    if connHeartbeat then connHeartbeat:Disconnect() end
    connHeartbeat = RunService.Heartbeat:Connect(function()
        if running and mainGui and mainGui.Visible then
            tapOnce()
        end
    end)
end

-- Main watcher loop
local function watcherLoop()
    task.spawn(function()
        while running do
            local fishing = player:WaitForChild("PlayerGui"):FindFirstChild("Fishing")

            if fishing then
                local main = fishing:WaitForChild("Main")

                -- Wait until it's visible
                main:GetPropertyChangedSignal("Visible"):Wait()
                while running and main.Visible do
                    startTapping(main)
                    task.wait(0.1) -- small wait so it doesn't lock loop
                end

                -- Stop tapping when it's gone/hidden
                if connHeartbeat then
                    connHeartbeat:Disconnect()
                    connHeartbeat = nil
                end
            else
                task.wait(0.5) -- wait before checking again
            end
        end
    end)
end

function AutoTap.Start()
    if running then
        print("[AutoTap] Already running")
        return
    end
    running = true
    watcherLoop()
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
