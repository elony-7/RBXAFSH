--========================================================
-- VDModule.lua
--========================================================

local VD = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--========================================================
-- INTERNAL STATE
--========================================================
local settings = {
    killer = {
        breakspeed = nil,
        speed = nil,
        speedboost = nil,
        mask = nil
    },
    survivor = {
        speedboost = nil
    },
    removeSkillcheck = false
}

local masks = { "Richard", "Alex", "Brandon", "Cobra", "Rabbit", "Ritcher", "Tony" }

local characterConnection = nil

--========================================================
-- SAFE ATTRIBUTE SETTER
--========================================================
local function applyAttributes(character)
    if not character then return end

    local attrs = character:FindFirstChild("Attributes")
    if not attrs then return end

    -- Killer Attributes
    if settings.killer.breakspeed then
        if attrs:FindFirstChild("breakspeed") then
            attrs.breakspeed.Value = settings.killer.breakspeed
        end
    end

    if settings.killer.speed then
        if attrs:FindFirstChild("speed") then
            attrs.speed.Value = settings.killer.speed
        end
    end

    if settings.killer.speedboost then
        if attrs:FindFirstChild("speedboost") then
            attrs.speedboost.Value = settings.killer.speedboost
        end
    end

    if settings.killer.mask then
        if attrs:FindFirstChild("Mask") then
            attrs.Mask.Value = settings.killer.mask
        end
    end

    -- Survivor Attributes
    if settings.survivor.speedboost then
        if attrs:FindFirstChild("speedboost") then
            attrs.speedboost.Value = settings.survivor.speedboost
        end
    end
end

--========================================================
-- REMOVE SKILLCHECK
--========================================================
local function removeSkillChecks()
    local char = LocalPlayer.Character
    if not char then return end

    if settings.removeSkillcheck then
        local sc1 = char:FindFirstChild("Skillcheck-gen")
        local sc2 = char:FindFirstChild("Skillcheck-player")

        if sc1 then sc1:Destroy() end
        if sc2 then sc2:Destroy() end
    end
end

--========================================================
-- APPLY EVERYTHING ON CHARACTER SPAWN
--========================================================
local function bindCharacter(character)
    task.wait(0.2)
    applyAttributes(character)
    removeSkillChecks()
end

-- Character respawn listener
LocalPlayer.CharacterAdded:Connect(bindCharacter)
if LocalPlayer.Character then
    bindCharacter(LocalPlayer.Character)
end

--========================================================
-- PUBLIC API (CALLED FROM main.lua)
--========================================================

function VD.SetKillerBreakSpeed(val)
    settings.killer.breakspeed = tonumber(val)
    bindCharacter(LocalPlayer.Character)
end

function VD.SetKillerSpeed(val)
    settings.killer.speed = tonumber(val)
    bindCharacter(LocalPlayer.Character)
end

function VD.SetKillerSpeedBoost(val)
    settings.killer.speedboost = tonumber(val)
    bindCharacter(LocalPlayer.Character)
end

function VD.SetKillerMask(maskName)
    settings.killer.mask = maskName
    bindCharacter(LocalPlayer.Character)
end

function VD.SetSurvivorSpeedBoost(val)
    settings.survivor.speedboost = tonumber(val)
    bindCharacter(LocalPlayer.Character)
end

function VD.ToggleRemoveSkillCheck(state)
    settings.removeSkillcheck = state
    bindCharacter(LocalPlayer.Character)
end

function VD.GetMaskList()
    return masks
end

return VD
