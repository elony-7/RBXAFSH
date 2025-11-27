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

local masks = { "Richard", "Alex", "Brandon", "Cobra", "Rabbit", "Richter", "Tony" }

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

local attributeConnections = {} -- store all connections per attribute

local function clearConnections()
    for _, conn in pairs(attributeConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    attributeConnections = {}
end

local function enforceAttribute(character, attrName, getValue)
    if not character then return end
    local folder = character:FindFirstChild("Attributes")

    -- ValueObject event
    if folder and folder:FindFirstChild(attrName) then
        local valObj = folder[attrName]
        local conn = valObj:GetPropertyChangedSignal("Value"):Connect(function()
            local target = getValue()
            if target ~= nil and valObj.Value ~= target then
                valObj.Value = target
            end
        end)
        table.insert(attributeConnections, conn)
    end

    -- Internal attribute event
    if character:GetAttribute(attrName) ~= nil then
        local conn = character:GetAttributeChangedSignal(attrName):Connect(function()
            local target = getValue()
            if target ~= nil and character:GetAttribute(attrName) ~= target then
                character:SetAttribute(attrName, target)
            end
        end)
        table.insert(attributeConnections, conn)
    end
end

local function enforceAll(character)
    clearConnections() -- remove old connections to prevent leaks
    -- Killer
    enforceAttribute(character, "breakspeed", function() return settings.killer.breakspeed end)
    enforceAttribute(character, "speed", function() return settings.killer.speed end)
    enforceAttribute(character, "speedboost", function() return settings.killer.speedboost end)
    enforceAttribute(character, "Mask", function() return settings.killer.mask end)
    -- Survivor
    enforceAttribute(character, "speedboost", function() return settings.survivor.speedboost end)
end

-- Apply on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    applyAttributes(char)
    removeSkillChecks()
    enforceAll(char)
end)

if LocalPlayer.Character then
    bindCharacter(LocalPlayer.Character)
    enforceAll(LocalPlayer.Character)
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
