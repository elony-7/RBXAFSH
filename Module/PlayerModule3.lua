-- PlayerModule.lua
local PlayerModule = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Flags
PlayerModule.UnlimitedJumpEnabled = false
PlayerModule.NoClipEnabled = false

-- All connections stored here
local connections = {}

-- Log helper
local function log(msg)
    print(msg)
end

------------------------------------------------------------
-- PART 1: Unlimited Jump (already safe, no memory leaks)
------------------------------------------------------------
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

function PlayerModule.SetUnlimitedJump(val)
    PlayerModule.UnlimitedJumpEnabled = val
    log("♾️ Unlimited Jump " .. (val and "ENABLED" or "DISABLED"))
end


------------------------------------------------------------
-- PART 2: Optimized NoClip (NO more per-frame scanning)
------------------------------------------------------------

-- Apply NoClip to all existing parts
local function applyNoClip(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Apply NoClip to any newly added parts
local function listenDescendants(char)
    -- cleanup old listener
    if connections["_noclip_char"] then
        connections["_noclip_char"]:Disconnect()
        connections["_noclip_char"] = nil
    end

    connections["_noclip_char"] = char.DescendantAdded:Connect(function(part)
        if PlayerModule.NoClipEnabled and part:IsA("BasePart") then
            part.CanCollide = false
        end
    end)
end

-- Reapply NoClip on respawn
local function hookCharacterAdded()
    if connections["_char_added"] then return end

    connections["_char_added"] = LocalPlayer.CharacterAdded:Connect(function(newChar)
        if PlayerModule.NoClipEnabled then
            task.wait(0.1) -- wait for parts to load
            applyNoClip(newChar)
            listenDescendants(newChar)
        end
    end)
end

-- Main NoClip function
function PlayerModule.SetNoClip(val)
    PlayerModule.NoClipEnabled = val
    log("🚫 NoClip " .. (val and "ENABLED" or "DISABLED"))

    local char = LocalPlayer.Character
    if not char then return end

    if val then
        -- enable NoClip
        applyNoClip(char)
        listenDescendants(char)
        hookCharacterAdded()

    else
        -- disable NoClip listeners
        if connections["_noclip_char"] then
            connections["_noclip_char"]:Disconnect()
            connections["_noclip_char"] = nil
        end
    end
end

return PlayerModule
