--// SpeedModifier.lua
-- Modular speed management system for Roblox
-- Handles all speed-related logic internally

--// Dependencies
local Players = game:GetService("Players")

local SpeedModifier = {}
SpeedModifier.__index = SpeedModifier

--// Constructor
function SpeedModifier.new(player)
	local self = setmetatable({}, SpeedModifier)

	self.Player = player or Players.LocalPlayer
	self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")

	self.DefaultSpeed = 16
	self.CurrentSpeed = self.DefaultSpeed
	self.Enabled = false

	-- Reconnect when character respawns
	self.Player.CharacterAdded:Connect(function(char)
		self.Character = char
		self.Humanoid = char:WaitForChild("Humanoid")
		self:ApplyCurrentState()
	end)

	return self
end

--// Applies the current speed state
function SpeedModifier:ApplyCurrentState()
	if not self.Humanoid then return end
	if self.Enabled then
		self.Humanoid.WalkSpeed = self.CurrentSpeed
	else
		self.Humanoid.WalkSpeed = self.DefaultSpeed
	end
end

--// Public: Enable or disable the modifier
function SpeedModifier:SetEnabled(state: boolean)
	self.Enabled = state
	self:ApplyCurrentState()
end

--// Public: Set the walking speed value
function SpeedModifier:SetSpeed(value: number)
	self.CurrentSpeed = math.clamp(value, 0, 200)
	self:ApplyCurrentState()
end

--// Public: Reset to default
function SpeedModifier:Reset()
	self.Enabled = false
	self.CurrentSpeed = self.DefaultSpeed
	self:ApplyCurrentState()
end

return SpeedModifier
