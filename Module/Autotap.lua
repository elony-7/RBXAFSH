-- Autotap.lua
local AutoTap = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- References
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("Fishing"):WaitForChild("Main")

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
local net = netFolder:WaitForChild("net")
local fishingStopped = net:WaitForChild("RE/FishingStopped")

-- State
local running = false
local mainThread
local stopConn
local guiDestroyConn

-- Function to simulate mouse click
local function sendTap()
    -- Click at position (0,0); you can adjust X,Y if needed
    VirtualInputManager:SendMouseButtonEvent(0, 0, Enum.UserInputState.Begin, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, Enum.UserInputState.End, true, game, 0)
end

-- Start AutoTap
function AutoTap.Start()
    if running then return end
    running = true
    print("[AutoTap] Started")

    -- Main loop: wait for GUI to change, tap, then wait again
    mainThread = task.spawn(function()
        while running do
            -- Wait until GUI Y.Scale is not 1.5
            while gui and gui.Position.Y.Scale == 1.5 and running do
                task.wait(0.1)
            end

            -- Start tapping until GUI goes back to 1.5
            while gui and gui.Position.Y.Scale ~= 1.5 and running do
                sendTap()
                task.wait(0.25) -- 250ms tap interval
            end
        end
    end)

    -- Stop when FishingStopped event fires
    stopConn = fishingStopped.OnClientEvent:Connect(function()
        AutoTap.Stop()
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

    if stopConn then
        stopConn:Disconnect()
        stopConn = nil
    end

    if guiDestroyConn then
        guiDestroyConn:Disconnect()
        guiDestroyConn = nil
    end

    mainThread = nil
end

return AutoTap
