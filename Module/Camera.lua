-- Camera.lua (ModuleScript)

local CameraModule = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Saved state
local savedSubject = nil
local savedType = nil
local connection = nil
local camRot = Vector2.new(0, 0)
local speed = 2
local keys = {
	W = false, S = false, A = false, D = false,
	Q = false, E = false
}

-- Toggle flag (enabled by GUI button)
local freecamEnabled = false
local detached = false

-- Input handlers (only connected once)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not freecamEnabled then return end
	if input.KeyCode == Enum.KeyCode.W then keys.W = true end
	if input.KeyCode == Enum.KeyCode.S then keys.S = true end
	if input.KeyCode == Enum.KeyCode.A then keys.A = true end
	if input.KeyCode == Enum.KeyCode.D then keys.D = true end
	if input.KeyCode == Enum.KeyCode.Q then keys.Q = true end
	if input.KeyCode == Enum.KeyCode.E then keys.E = true end
	
	-- Hotkey toggle F
	if input.KeyCode == Enum.KeyCode.F then
		if detached then
			CameraModule.Attach()
		else
			CameraModule.Detach()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then keys.W = false end
	if input.KeyCode == Enum.KeyCode.S then keys.S = false end
	if input.KeyCode == Enum.KeyCode.A then keys.A = false end
	if input.KeyCode == Enum.KeyCode.D then keys.D = false end
	if input.KeyCode == Enum.KeyCode.Q then keys.Q = false end
	if input.KeyCode == Enum.KeyCode.E then keys.E = false end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and detached then
		camRot = camRot + Vector2.new(-input.Delta.y, -input.Delta.x) * 0.002
	end
end)

local function getMoveVector()
	local dir = Vector3.zero
	if keys.W then dir += Vector3.new(0,0,-1) end
	if keys.S then dir += Vector3.new(0,0,1) end
	if keys.A then dir += Vector3.new(-1,0,0) end
	if keys.D then dir += Vector3.new(1,0,0) end
	if keys.Q then dir += Vector3.new(0,-1,0) end
	if keys.E then dir += Vector3.new(0,1,0) end
	return dir
end

-- Detach camera into freecam
function CameraModule.Detach()
	if detached or not freecamEnabled then return end
	if not savedSubject then
		savedSubject = camera.CameraSubject
		savedType = camera.CameraType
	end
	
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(
		player.Character and player.Character:FindFirstChild("Head") and player.Character.Head.Position + Vector3.new(0, 5, 0) or Vector3.new(0,10,0)
	)

	connection = RunService.RenderStepped:Connect(function(dt)
		local cf = camera.CFrame
		local forward, right, up = cf.LookVector, cf.RightVector, cf.UpVector
		local move = getMoveVector()
		local moveVec = (right * move.X + up * move.Y + forward * move.Z) * speed * dt
		local rotCFrame = CFrame.Angles(0, camRot.Y, 0) * CFrame.Angles(camRot.X, 0, 0)
		
		camera.CFrame = CFrame.new(camera.CFrame.Position + moveVec) * rotCFrame
	end)
	detached = true
end

-- Reattach to character
function CameraModule.Attach()
	if not detached then return end
	if connection then
		connection:Disconnect()
		connection = nil
	end
	if savedSubject and savedType then
		camera.CameraSubject = savedSubject
		camera.CameraType = savedType
		savedSubject, savedType = nil, nil
	end
	detached = false
end

-- Public toggle for GUI button
function CameraModule.ToggleFreecam(state)
	freecamEnabled = state
	if not state and detached then
		CameraModule.Attach()
	end
end

return CameraModule
