-- Autotap.lua
local AutoTap = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("Fishing"):WaitForChild("Main")

-- State
local running = false
local tapThread
local guiDestroyConn

-- Function to simulate tap at bottom-right
local function sendTap()
    -- Get screen size
    local screenSize = workspace.CurrentCamera.ViewportSize
    local tapPosition = Vector2.new(screenSize.X - 10, screenSize.Y - 10) -- bottom-right corner, 10px offset

    -- Find GuiObject under that position
    local target = UserInputService:GetGuiObjectsAtPosition(tapPosition.X, tapPosition.Y)[1]
    if target and target:IsA("GuiButton") then
        target:Activate()
    end
end

-- Start AutoTap
function AutoTap.Start()
    if running then return end
    running = true
    print("[AutoTap] Started")

    tapThread = task.spawn(function()
        while running do
            sendTap()
            task.wait(0.25) -- 250ms tap interval
        end
    end)

    -- Stop if GUI is destroyed
    guiDestroyConn = gui.Destroying:Connect(function()
        AutoTap.Stop()
    end)
end

-- Stop AutoTap
function AutoTap.Stop()
    if not running then return end
    running = false
    print("[AutoTap] Stopped")

    if guiDestroyConn then
        guiDestroyConn:Disconnect()
        guiDestroyConn = nil
    end

    tapThread = nil
end

return AutoTap
