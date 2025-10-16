-- speedmodifier.lua
-- Handles both walk and run speed logic

local SpeedModifier = {}
SpeedModifier.enabled = false
SpeedModifier.walkSpeed = 16
SpeedModifier.runSpeed = 24
SpeedModifier.currentModifier = 1.0

local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")

-- internal flag
local isRunning = false

-- function to update the humanoid's speed
local function updateSpeed()
	if not player.Character or not player.Character:FindFirstChild("Humanoid") then
		return
	end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	local baseSpeed = isRunning and SpeedModifier.runSpeed or SpeedModifier.walkSpeed
	humanoid.WalkSpeed = baseSpeed * SpeedModifier.currentModifier
end

-- toggle on/off
function SpeedModifier:SetEnabled(state)
	self.enabled = state
	updateSpeed()
end

-- change modifier (e.g. slider value)
function SpeedModifier:SetModifier(value)
	self.currentModifier = value
	updateSpeed()
end

-- listen to Shift key to detect running
userInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not SpeedModifier.enabled then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = true
		updateSpeed()
	end
end)

userInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = false
		updateSpeed()
	end
end)

-- if character respawns, reapply the speed
player.CharacterAdded:Connect(function()
	task.wait(1)
	updateSpeed()
end)

return SpeedModifier
