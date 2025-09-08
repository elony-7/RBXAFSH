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
    print("♾️ Unlimited Jump " .. (val and "ENABLED" or "DISABLED"))

    if val then
        if not connections["_jump"] then
            local lastJump = 0
            connections["_jump"] = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid and tick() - lastJump > 0.1 then
                    lastJump = tick()
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    else
        if connections["_jump"] then
            connections["_jump"]:Disconnect()
            connections["_jump"] = nil
        end
    end
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
