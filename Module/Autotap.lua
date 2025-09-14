-- Autotap.lua
local AutoTap = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
local stopConn
local guiDestroyConn

-- Function to simulate mouse click
local function sendTap()
	-- Simulate left mouse button down and up
	UserInputService.InputBegan:Fire({
		UserInputType = Enum.UserInputType.MouseButton1,
		KeyCode = Enum.KeyCode.Unknown,
		UserInputState = Enum.UserInputState.Begin
	})
	UserInputService.InputEnded:Fire({
		UserInputType = Enum.UserInputType.MouseButton1,
		KeyCode = Enum.KeyCode.Unknown,
		UserInputState = Enum.UserInputState.End
	})
end

-- Start AutoTap
function AutoTap.Start()
	if running then return end
	running = true
	print("[AutoTap] Started")

	-- Persistent tap loop
	tapThread = task.spawn(function()
		while running do
			if gui and gui.Position.Y.Scale ~= 1.5 then
				sendTap()
			end
			task.wait(0.25) -- 250ms tap interval
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

	tapThread = nil
end

return AutoTap
