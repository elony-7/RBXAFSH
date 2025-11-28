--========================================================
-- VDModule.lua (Option A - Clean + Leak Safe)
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

local attributeConnections = {}
local currentCharacter = nil
local charAddedConn = nil

--========================================================
-- UNIVERSAL ATTRIBUTE SETTER
--========================================================
local function setAttribute(character, attr, value)
    if value == nil or not character then return end

    local ok, exists = pcall(function()
        return character:GetAttribute(attr) ~= nil
    end)

    if ok and exists then
        local current = character:GetAttribute(attr)
        if current ~= value then
            character:SetAttribute(attr, value)
        end
        return
    end

    local folder = character:FindFirstChild("Attributes")
    if folder and folder:FindFirstChild(attr) then
        local vo = folder[attr]
        if vo.Value ~= value then
            vo.Value = value
        end
    end
end

--========================================================
-- APPLY ATTRIBUTES
--========================================================
local function applyAttributes(character)
    if not character then return end

    -- Killer
    setAttribute(character, "breakspeed", settings.killer.breakspeed)
    setAttribute(character, "speed", settings.killer.speed)
    setAttribute(character, "speedboost", settings.killer.speedboost)
    setAttribute(character, "Mask", settings.killer.mask)

    -- Survivor
    setAttribute(character, "speedboost", settings.survivor.speedboost)
end

--========================================================
-- CLEAN ATTRIBUTE ENFORCERS
--========================================================
local function clearConnections()
    for _, conn in ipairs(attributeConnections) do
        if conn and conn.Connected then
            pcall(function() conn:Disconnect() end)
        end
    end
    attributeConnections = {}
end

--========================================================
-- ENFORCE SINGLE ATTRIBUTE (ANTI SERVER OVERRIDE)
--========================================================
local function enforceAttribute(character, attrName, getScriptValue)
    local folder = character:FindFirstChild("Attributes")
    if not folder then return end

    local valObj = folder:FindFirstChild(attrName)
    if not valObj then return end

    -- Immediate enforcement
    local desired = getScriptValue()
    if desired ~= nil and valObj.Value ~= desired then
        valObj.Value = desired
    end

    local connection
    connection = valObj:GetPropertyChangedSignal("Value"):Connect(function()
        if not character or not character.Parent then
            pcall(function()
                if connection then connection:Disconnect() end
            end)
            return
        end

        local expected = getScriptValue()
        if expected ~= nil and valObj.Value ~= expected then
            valObj.Value = expected
        end
    end)

    table.insert(attributeConnections, connection)
end

--========================================================
-- ENFORCE ALL ATTRIBUTES
--========================================================
function enforceAll(character)
    clearConnections()

    -- Killer
    enforceAttribute(character, "breakspeed", function()
        return settings.killer.breakspeed
    end)
    enforceAttribute(character, "speed", function()
        return settings.killer.speed
    end)
    enforceAttribute(character, "speedboost", function()
        return settings.killer.speedboost
    end)
    enforceAttribute(character, "Mask", function()
        return settings.killer.mask
    end)

    -- Survivor
    enforceAttribute(character, "speedboost", function()
        return settings.survivor.speedboost
    end)
end

--========================================================
-- REMOVE SKILLCHECK
--========================================================
local function removeSkillChecks()
    if not settings.removeSkillcheck then return end

    local char = LocalPlayer.Character
    if not char then return end

    for _, name in ipairs({ "Skillcheck-gen", "Skillcheck-player" }) do
        local obj = char:FindFirstChild(name)
        if obj then
            pcall(function() obj:Destroy() end)
        end
    end
end

--========================================================
-- CHARACTER BIND
--========================================================
local function bindCharacter(character)
    if not character then return end

    currentCharacter = character

    task.wait(0.2)

    applyAttributes(character)
    removeSkillChecks()
    enforceAll(character)
end

local function safeBindCurrentCharacter()
    local char = LocalPlayer.Character
    if char then
        bindCharacter(char)
    end
end

-- CharacterAdded
if not charAddedConn then
    charAddedConn = LocalPlayer.CharacterAdded:Connect(bindCharacter)
end

if LocalPlayer.Character then
    bindCharacter(LocalPlayer.Character)
end

--========================================================
-- PUBLIC API
--========================================================
function VD.SetKillerBreakSpeed(v)
    settings.killer.breakspeed = tonumber(v)
    safeBindCurrentCharacter()
end

function VD.SetKillerSpeed(v)
    settings.killer.speed = tonumber(v)
    safeBindCurrentCharacter()
end

function VD.SetKillerSpeedBoost(v)
    settings.killer.speedboost = tonumber(v)
    safeBindCurrentCharacter()
end

function VD.SetKillerMask(maskName)
    settings.killer.mask = maskName
    safeBindCurrentCharacter()
end

function VD.SetSurvivorSpeedBoost(v)
    settings.survivor.speedboost = tonumber(v)
    safeBindCurrentCharacter()
end

function VD.ToggleRemoveSkillCheck(state)
    settings.removeSkillcheck = state
    safeBindCurrentCharacter()
end

function VD.GetMaskList()
    return masks
end

--========================================================
-- CLEANUP
--========================================================
function VD.Destroy()
    if charAddedConn and charAddedConn.Connected then
        pcall(function() charAddedConn:Disconnect() end)
    end
    charAddedConn = nil

    clearConnections()
    currentCharacter = nil
end

return VD
