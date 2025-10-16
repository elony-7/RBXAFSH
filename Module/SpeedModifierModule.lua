--========================
-- SpeedModifier.lua
--========================
-- Modular player speed controller

local Players = game:GetService("Players")
local SpeedModifier = {}

SpeedModifier.DefaultSpeed = 16
SpeedModifier.CurrentSpeed = 16
SpeedModifier.Enabled = false

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Reapply settings when respawned
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	if SpeedModifier.Enabled then
		humanoid.WalkSpeed = SpeedModifier.CurrentSpeed
	else
		humanoid.WalkSpeed = SpeedModifier.DefaultSpeed
	end
end)

-- Public: Enable/disable
function SpeedModifier.SetEnabled(state)
	SpeedModifier.Enabled = state
	if humanoid then
		humanoid.WalkSpeed = state and SpeedModifier.CurrentSpeed or SpeedModifier.DefaultSpeed
	end
end

-- Public: Set custom speed
function SpeedModifier.SetSpeed(value)
	SpeedModifier.CurrentSpeed = math.clamp(value, 0, 300)
	if SpeedModifier.Enabled and humanoid then
		humanoid.WalkSpeed = SpeedModifier.CurrentSpeed
	end
end

-- Public: Reset speed
function SpeedModifier.Reset()
	SpeedModifier.Enabled = false
	SpeedModifier.CurrentSpeed = SpeedModifier.DefaultSpeed
	if humanoid then
		humanoid.WalkSpeed = SpeedModifier.DefaultSpeed
	end
end

-- Public: Temporary boost for X seconds
function SpeedModifier.Boost(tempSpeed, duration)
	local originalSpeed = SpeedModifier.CurrentSpeed
	local wasEnabled = SpeedModifier.Enabled

	SpeedModifier.SetEnabled(true)
	SpeedModifier.SetSpeed(tempSpeed)

	task.delay(duration, function()
		SpeedModifier.SetSpeed(originalSpeed)
		if not wasEnabled then
			SpeedModifier.SetEnabled(false)
		end
	end)
end

return SpeedModifier
