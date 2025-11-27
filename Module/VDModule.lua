--========================================================
-- VDModule.lua
--========================================================

local VD = {}

local Players = game:GetService("Players")
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

local attributeConnections = {} -- store connections to prevent leaks

--========================================================
-- UNIVERSAL ATTRIBUTE SETTER
--========================================================
local function setAttribute(character, attr, value)
    if value == nil or not character then return end

    -- Roblox attribute
    if character:GetAttribute(attr) ~= nil then
        character:SetAttribute(attr, value)
        return
    end

    -- ValueObject in Attributes folder
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
    setAttribute(character, "speed", settings.killer.speed)
    setAttribute(character, "speedboost", settings.killer.speedboost)
    setAttribute(character, "Mask", settings.killer.mask)

    -- Survivor attributes
    setAttribute(character, "speedboost", settings.survivor.speedboost)
end

--========================================================
-- REMOVE OLD CONNECTIONS TO PREVENT MEMORY LEAK
--========================================================
local function clearConnections()
    for _, conn in pairs(attributeConnections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    attributeConnections = {}
end

--========================================================
-- ENFORCE ATTRIBUTE VALUES (ANTI-SERVER OVERRIDE)
--========================================================
local function enforceAttribute(character, attrName, getValue)
    if not character then return end

    -- Folder ValueObject
    local folder = character:FindFirstChild("Attributes")
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

    -- Roblox internal attribute
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
    clearConnections()

    -- Killer
    enforceAttribute(character, "breakspeed", function() return settings.killer.breakspeed end)
    enforceAttribute(character, "speed", function() return settings.killer.speed end)
    enforceAttribute(character, "speedboost", function() return settings.killer.speedboost end)
    enforceAttribute(character, "Mask", function() return settings.killer.mask end)

    -- Survivor
    enforceAttribute(character, "speedboost", function() return settings.survivor.speedboost end)
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
    if not character then return end
    task.wait(0.2)
    applyAttributes(character)
    removeSkillChecks()
    enforceAll(character)
end

-- Character respawn listener
LocalPlayer.CharacterAdded:Connect(bindCharacter)

-- Apply immediately if character already exists
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
