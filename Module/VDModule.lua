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
-- UNIVERSAL ATTRIBUTE SETTER
-- Supports:
--   ✔ character:SetAttribute("name")
--   ✔ character.Attributes.name.Value
--========================================================
local function setAttribute(character, attr, value)
    if value == nil then return end
    if not character then return end

    -- Case A — true Roblox attribute
    local current = character:GetAttribute(attr)
    if current ~= nil then
        character:SetAttribute(attr, value)
        return
    end

    -- Case B — folder Attributes with ValueObjects
    local folder = character:FindFirstChild("Attributes")
    if folder and folder:FindFirstChild(attr) then
        folder[attr].Value = value
        return
    end
end

--========================================================
-- APPLY ATTRIBUTES
--========================================================
local function applyAttributes(character)
    if not character then return end

    -- Killer attributes
    setAttribute(character, "breakspeed", settings.killer.breakspeed)
    setAttribute(character, "Speed", settings.killer.speed)
    setAttribute(character, "speedboost", settings.killer.speedboost)
    setAttribute(character, "Mask", settings.killer.mask)

    -- Survivor attributes
    setAttribute(character, "speedboost", settings.survivor.speedboost)
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
