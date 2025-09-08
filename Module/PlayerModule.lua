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

-- Helper log function (replace with Fluent:Notify if needed)
local function log(msg)
    print(msg)
end

-- Unlimited Jump toggle function
function PlayerModule.SetUnlimitedJump(val)
    PlayerModule.UnlimitedJumpEnabled = val
    log("♾️ Unlimited Jump " .. (val and "ENABLED" or "DISABLED"))
end

-- NoClip toggle function
function PlayerModule.SetNoClip(val)
    PlayerModule.NoClipEnabled = val
    log("🚫 NoClip " .. (val and "ENABLED" or "DISABLED"))

    if val then
        connections["_noclip"] = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if connections["_noclip"] then
            connections["_noclip"]:Disconnect()
            connections["_noclip"] = nil
        end
    end
end

-- Hook JumpRequest for Unlimited Jump
UserInputService.JumpRequest:Connect(function()
    if PlayerModule.UnlimitedJumpEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


return PlayerModule
