--========================
-- SpeedModifier.lua
--========================
-- Handles player's walk speed logic modularly

local Players = game:GetService("Players")
local SpeedModifier = {}

SpeedModifier.DefaultSpeed = 16
SpeedModifier.CurrentSpeed = 16
SpeedModifier.Enabled = false

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Auto-update humanoid when respawned
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	if SpeedModifier.Enabled then
		humanoid.WalkSpeed = SpeedModifier.CurrentSpeed
	else
		humanoid.WalkSpeed = SpeedModifier.DefaultSpeed
	end
end)

--========================
-- Public Functions
--========================
function SpeedModifier.SetEnabled(state)
	SpeedModifier.Enabled = state
	if humanoid then
		humanoid.WalkSpeed = state and SpeedModifier.CurrentSpeed or SpeedModifier.DefaultSpeed
	end
end

function SpeedModifier.SetSpeed(value)
	SpeedModifier.CurrentSpeed = math.clamp(value, 0, 200)
	if SpeedModifier.Enabled and humanoid then
		humanoid.WalkSpeed = SpeedModifier.CurrentSpeed
	end
end

function SpeedModifier.Reset()
	SpeedModifier.Enabled = false
	SpeedModifier.CurrentSpeed = SpeedModifier.DefaultSpeed
	if humanoid then
		humanoid.WalkSpeed = SpeedModifier.DefaultSpeed
	end
end

return SpeedModifier
