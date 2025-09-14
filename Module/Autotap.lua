--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// References
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("Fishing"):WaitForChild("Main")

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
local net = netFolder:WaitForChild("net")
local fishingStopped = net:WaitForChild("RE/FishingStopped")

--// Auto Tap Control
local running = false
local tapThread

-- Function to send a tap
local function sendTap()
	-- put your real tap action here:
	print("TAP sent")
	-- example if it's a RemoteEvent:
	-- game:GetService("ReplicatedStorage").TapEvent:FireServer()
end

-- Function to start auto tap
local function startAutoTap()
	if running then return end
	running = true
	print("Auto Tap Started")

	-- Run taps every 0.25s in a loop
	tapThread = task.spawn(function()
		while running do
			sendTap()
			task.wait(0.25) -- 250ms
		end
	end)
end

-- Function to stop auto tap
local function stopAutoTap()
	if not running then return end
	running = false
	print("Auto Tap Stopped")
end

-- Listen for GUI size changes
gui:GetPropertyChangedSignal("Size"):Connect(function()
	local yScale = gui.Size.Y.Scale
	if yScale ~= 1.5 then
		startAutoTap()
	else
		stopAutoTap()
	end
end)

-- Also listen for FishingStopped event
fishingStopped.OnClientEvent:Connect(function()
	stopAutoTap()
end)
