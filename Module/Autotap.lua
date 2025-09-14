-- Autotap.lua
local AutoTap = {}

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// References
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("Fishing"):WaitForChild("Main")

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
local net = netFolder:WaitForChild("net")
local fishingStopped = net:WaitForChild("RE/FishingStopped")

--// State
local running = false
local tapThread
local guiConn
local stopConn

-- Function to send tap
local function sendTap()
	-- Replace this with actual action
	print("TAP sent")
	-- Example:
	-- ReplicatedStorage.TapEvent:FireServer()
end

-- Start function
function AutoTap.Start()
	if running then return end
	running = true
	print("[AutoTap] Started")

	-- Listen for GUI size changes
	guiConn = gui:GetPropertyChangedSignal("Size"):Connect(function()
		local yScale = gui.Size.Y.Scale
		if yScale ~= 1.5 and not tapThread then
			-- start tapping loop
			tapThread = task.spawn(function()
				while running and gui.Size.Y.Scale ~= 1.5 do
					sendTap()
					task.wait(0.25) -- 250ms
				end
				tapThread = nil
			end)
		elseif yScale == 1.5 then
			-- stop tapping loop
			if tapThread then
				tapThread = nil
			end
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

	if guiConn then
		guiConn:Disconnect()
		guiConn = nil
	end
	if stopConn then
		stopConn:Disconnect()
		stopConn = nil
	end

	-- ensure tap loop stops
	tapThread = nil
end

return AutoTap
