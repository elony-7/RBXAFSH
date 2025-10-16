-- SpeedModifierModule.lua
-- Module: Handles walk speed logic independently

local SpeedModifier = {}
SpeedModifier.__index = SpeedModifier

function SpeedModifier.new(player)
	local self = setmetatable({}, SpeedModifier)
	self.Player = player
	self.Character = player.Character or player.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	
	self.DefaultSpeed = 16
	self.CurrentSpeed = 16
	self.Enabled = false

	return self
end

function SpeedModifier:SetEnabled(state)
	self.Enabled = state
	if not state then
		self.Humanoid.WalkSpeed = self.DefaultSpeed
	else
		self.Humanoid.WalkSpeed = self.CurrentSpeed
	end
end

function SpeedModifier:SetSpeed(speed)
	self.CurrentSpeed = speed
	if self.Enabled then
		self.Humanoid.WalkSpeed = speed
	end
end

function SpeedModifier:Reset()
	self.CurrentSpeed = self.DefaultSpeed
	self:SetEnabled(false)
end

return SpeedModifier
