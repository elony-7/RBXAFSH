--========================================================
-- VDModule.lua (Updated - leak safe)
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

-- store active attribute connections so we can disconnect them
local attributeConnections = {}
local currentCharacter = nil

-- character added connection (so we can disconnect on destroy)
local charAddedConn = nil

--========================================================
-- UNIVERSAL ATTRIBUTE SETTER
--========================================================
local function setAttribute(character, attr, value)
    if value == nil or not character then return end

    -- Roblox attribute
    local ok, hasAttr = pcall(function() return character:GetAttribute(attr) ~= nil end)
    if ok and hasAttr then
        -- Only set if value differs (avoid spamming)
        local current = character:GetAttribute(attr)
        if current ~= value then
            character:SetAttribute(attr, value)
        end
        return
    end

    -- ValueObject in Attributes folder
    local folder = character:FindFirstChild("Attributes")
    if folder and folder:FindFirstChild(attr) then
        local vo = folder[attr]
        if vo.Value ~= value then
            vo.Value = value
        end
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
        if conn and conn.Connected then
            -- protect calls
            pcall(function() conn:Disconnect() end)
        end
    end
    attributeConnections = {}
end

--========================================================
-- ENFORCE ATTRIBUTE VALUES (ANTI-SERVER OVERRIDE)
--========================================================
local function enforceAttribute(character, attrName, getScriptValue)
    if not character then return end

    local folder = character:FindFirstChild("Attributes")
    if not folder then return end

    local valObj = folder:FindFirstChild(attrName)
    if not valObj then return end

    -- Enforce immediately
    local target = getScriptValue()
    if target ~= nil and valObj.Value ~= target then
        valObj.Value = target
    end

    -- Protect from server changes
    local connection
    connection = valObj:GetPropertyChangedSignal("Value"):Connect(function()
        if not character or not character.Parent then
            pcall(function()
                if connection then connection:Disconnect() end
            end)
            return
        end

        local desired = getScriptValue()
        if desired ~= nil and valObj.Value ~= desired then
            valObj.Value = desired
        end
    end)

    table.insert(attributeConnections, connection)
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

        if sc1 then
            pcall(function() sc1:Destroy() end)
        end
        if sc2 then
            pcall(function() sc2:Destroy() end)
        end
    end
end

--========================================================
-- APPLY EVERYTHING ON CHARACTER SPAWN
--========================================================
local function bindCharacter(character)
    if not character then return end

    -- If same character already bound, still ensure values are applied but avoid re-creating connections unnecessarily
    if currentCharacter == character then
        -- reapply attributes (keeps behavior same)
        task.wait(0.1)
        applyAttributes(character)
        removeSkillChecks()
        return
    end

    -- update currentCharacter
    currentCharacter = character

    -- small delay to ensure character is fully initialized (keep original behavior)
    task.wait(0.2)

    applyAttributes(character)
    removeSkillChecks()
    enforceAll(character)
end

-- safe wrapper for character binds (used both on respawn and manual calls)
local function safeBindCurrentCharacter()
    local char = LocalPlayer and LocalPlayer.Character
    if char then
        bindCharacter(char)
    end
end

-- Character respawn listener (store connection so we can clean up)
if not charAddedConn then
    charAddedConn = LocalPlayer.CharacterAdded:Connect(bindCharacter)
end

-- Apply immediately if character already exists
if LocalPlayer.Character then
    bindCharacter(LocalPlayer.Character)
end

--========================================================
-- PUBLIC API (CALLED FROM main.lua)
--========================================================
function VD.SetKillerBreakSpeed(val)
    settings.killer.breakspeed = tonumber(val)
    safeBindCurrentCharacter()
end

function VD.SetKillerSpeed(val)
    settings.killer.speed = tonumber(val)
    safeBindCurrentCharacter()
end

function VD.SetKillerSpeedBoost(val)
    settings.killer.speedboost = tonumber(val)
    safeBindCurrentCharacter()
end

function VD.SetKillerMask(maskName)
    settings.killer.mask = maskName
    safeBindCurrentCharacter()
end

function VD.SetSurvivorSpeedBoost(val)
    settings.survivor.speedboost = tonumber(val)
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
-- CLEANUP (exposed so main script can call on reload)
--========================================================
function VD.Destroy()
    -- disconnect CharacterAdded
    if charAddedConn and charAddedConn.Connected then
        pcall(function() charAddedConn:Disconnect() end)
    end
    charAddedConn = nil

    -- clear attribute connections
    clearConnections()

    -- stop referencing character
    currentCharacter = nil
end

return VD
