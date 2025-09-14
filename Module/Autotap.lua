-- Autotap.lua
local AutoTap = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- References
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("Fishing"):WaitForChild("Main")
local fishingButton = gui:WaitForChild("Button") -- adjust if your fishing button has a different name

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
local net = netFolder:WaitForChild("net")
local fishingStopped = net:WaitForChild("RE/FishingStopped")

-- State
local running = false
local tapThread
local stopConn
local guiDestroyConn
local tapping = false

-- Function to simulate left click on the fishing button
local function sendTap()
    if not fishingButton then return end

    local buttonPos = fishingButton.AbsolutePosition + fishingButton.AbsoluteSize/2

    -- Press and release left mouse button immediately
    VirtualInputManager:SendMouseButtonEvent(buttonPos.X, buttonPos.Y, 0, true, game, 0) -- Begin
    VirtualInputManager:SendMouseButtonEvent(buttonPos.X, buttonPos.Y, 1, true, game, 0) -- End
end

-- Start AutoTap
function AutoTap.Start()
    if running then return end
    running = true
    print("[AutoTap] Started")

    -- Listen to FishingStopped to stop tapping immediately
    stopConn = fishingStopped.OnClientEvent:Connect(function()
        tapping = false
    end)

    -- Stop if GUI is destroyed
    guiDestroyConn = gui.Destroying:Connect(function()
        AutoTap.Stop()
    end)

    -- Persistent tap loop
    tapThread = task.spawn(function()
        while running do
            -- Wait while GUI position is 1.5
            while gui and gui.Position.Y.Scale == 1.5 and running do
                tapping = false
                task.wait(0.1)
            end

            -- Start tapping while GUI is not 1.5 and until FishingStopped fires
            tapping = true
            while gui and gui.Position.Y.Scale ~= 1.5 and tapping and running do
                sendTap()
                task.wait(0.25)
            end

            -- After stopping taps, go back to waiting
            tapping = false
            task.wait(0.1)
        end
    end)
end

-- Stop AutoTap completely
function AutoTap.Stop()
    if not running then return end
    running = false
    print("[AutoTap] Stopped")

    if stopConn then
        stopConn:Disconnect()
        stopConn = nil
    end

    if guiDestroyConn then
        guiDestroyConn:Disconnect()
        guiDestroyConn = nil
    end

    tapThread = nil
    tapping = false
end

return AutoTap
