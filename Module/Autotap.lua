-- Autotap.lua
local AutoTap = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- References
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("Fishing"):WaitForChild("Main")

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
local net = netFolder:WaitForChild("net")
local fishingStopped = net:WaitForChild("RE/FishingStopped")

-- State
local running = false
local tapThread
local guiConn
local stopConn

-- Function to send tap
local function sendTap()
	-- Replace this with actual tap action
	print("TAP sent")
	-- Example:
	-- ReplicatedStorage.TapEvent:FireServer()
end

-- Start function
function AutoTap.Start()
	if running then return end
	running = true
	print("[AutoTap] Started")

	-- Persistent tap loop
	tapThread = task.spawn(function()
		while running do
			if gui and gui.Size.Y.Scale ~= 1.5 then
				sendTap()
			end
			task.wait(0.25)
		end
	end)

	-- Listen for FishingStopped
	stopConn = fishingStopped.OnClientEvent:Connect(function()
		AutoTap.Stop()
	end)
end

-- Stop function
function AutoTap.Stop()
	if not running then return end
	running = false
	print("[AutoTap] Stopped")

	if stopConn then
		stopConn:Disconnect()
		stopConn = nil
	end

	-- Stop loop
	tapThread = nil
end

return AutoTap
