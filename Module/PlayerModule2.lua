-- PlayerModule.lua
local PlayerModule = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Flags
PlayerModule.UnlimitedJumpEnabled = false
PlayerModule.NoClipEnabled = false

-- Connections table for cleanup
local connections = {}

-- Log
local function log(msg)
    print(msg)
end

-- Ensure JumpRequest is only connected once
if not connections["_jump"] then
    connections["_jump"] = UserInputService.JumpRequest:Connect(function()
        if PlayerModule.UnlimitedJumpEnabled then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- Unlimited Jump
function PlayerModule.SetUnlimitedJump(val)
    PlayerModule.UnlimitedJumpEnabled = val
    log("♾️ Unlimited Jump " .. (val and "ENABLED" or "DISABLED"))
end

-- NoClip
function PlayerModule.SetNoClip(val)
    PlayerModule.NoClipEnabled = val
    log("🚫 NoClip " .. (val and "ENABLED" or "DISABLED"))

    if val then
        -- Prevent duplicate Stepped connections
        if connections["_noclip"] then return end

        connections["_noclip"] = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- Prevent unnecessary writes
                    if part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)

    else
        -- Disable NoClip
        if connections["_noclip"] then
            connections["_noclip"]:Disconnect()
            connections["_noclip"] = nil
        end
    end
end

return PlayerModule
