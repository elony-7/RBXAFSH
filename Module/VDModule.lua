--========================================================
-- VDModule.lua (FINAL VERSION - NO MEMORY LEAK + TRUE SERVER OVERRIDE BLOCK)
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

-- SINGLE connection table (never stacks duplicates)
local enforcementConnections = {}

-- helper
local function addConnection(name, conn)
    if enforcementConnections[name] then
        pcall(function() enforcementConnections[name]:Disconnect() end)
    end
    enforcementConnections[name] = conn
end

--========================================================
-- UNIVERSAL SETTER
--========================================================
local function setAttribute(character, attr, value)
    if not character or value == nil then return end

    -- Roblox attribute
    local ok, exists = pcall(function() return character:GetAttribute(attr) ~= nil end)
    if ok and exists then
        if character:GetAttribute(attr) ~= value then
            pcall(function() character:SetAttribute(attr, value) end)
        end
        return
    end

    -- ValueObject fallback
    local folder = character:FindFirstChild("Attributes")
    if folder then
        local vo = folder:FindFirstChild(attr)
        if vo and vo.Value ~= value then
            pcall(function() vo.Value = value end)
        end
    end
end

--========================================================
-- ENFORCER (only 1 per attribute)
--========================================================
local function enforceAttribute(character, attrName, getValue)
    if not character then return end

    local folder = character:FindFirstChild("Attributes")
    local vo = folder and folder:FindFirstChild(attrName)

    -- If ValueObject exists → enforce it
    if vo then
        local desired = getValue()
        if desired ~= nil then
            pcall(function() vo.Value = desired end)
        end

        addConnection(attrName, vo:GetPropertyChangedSignal("Value"):Connect(function()
            local target = getValue()
            if target ~= nil and vo.Value ~= target then
                pcall(function() vo.Value = target end)
            end
        end))

        return
    end

    -- If roblox attribute exists → enforce it
    local ok, exists = pcall(function() return character:GetAttribute(attrName) ~= nil end)
    if ok and exists then
        local desired = getValue()
        if desired ~= nil then
            pcall(function() character:SetAttribute(attrName, desired) end)
        end

        addConnection(attrName, character:GetAttributeChangedSignal(attrName):Connect(function()
            local target = getValue()
            if target ~= nil and character:GetAttribute(attrName) ~= target then
                pcall(function() character:SetAttribute(attrName, target) end)
            end
        end))

        return
    end

    -- If neither exists, wait for creation
    addConnection(attrName .. "_wait", character.ChildAdded:Connect(function(child)
        task.defer(function()
            enforceAttribute(character, attrName, getValue)
        end)
    end))
end

--========================================================
-- APPLY ALL USER SETTINGS TO CHARACTER
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
-- REMOVE SKILLCHECK
--========================================================
local function removeSkillChecks()
    local char = LocalPlayer.Character
    if not char or not settings.removeSkillcheck then return end

    local sc1 = char:FindFirstChild("Skillcheck-gen")
    local sc2 = char:FindFirstChild("Skillcheck-player")

    if sc1 then pcall(function() sc1:Destroy() end) end
    if sc2 then pcall(function() sc2:Destroy() end) end
end

--========================================================
-- BIND CHARACTER (runs once per respawn)
--========================================================
local function bindCharacter(character)
    task.wait(0.3)

    applyAttributes(character)
    removeSkillChecks()

    -- Killer enforce
    enforceAttribute(character, "breakspeed", function() return settings.killer.breakspeed end)
    enforceAttribute(character, "speed", function() return settings.killer.speed end)
    enforceAttribute(character, "speedboost", function() return settings.killer.speedboost end)
    enforceAttribute(character, "Mask", function() return settings.killer.mask end)

    -- Survivor enforce
    enforceAttribute(character, "speedboost", function() return settings.survivor.speedboost end)
end

LocalPlayer.CharacterAdded:Connect(bindCharacter)
if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end

--========================================================
-- PUBLIC API
--========================================================
function VD.SetKillerBreakSpeed(v)
    settings.killer.breakspeed = tonumber(v)
    local char = LocalPlayer.Character
    if char then setAttribute(char, "breakspeed", v) end
end

function VD.SetKillerSpeed(v)
    settings.killer.speed = tonumber(v)
    local char = LocalPlayer.Character
    if char then setAttribute(char, "speed", v) end
end

function VD.SetKillerSpeedBoost(v)
    settings.killer.speedboost = tonumber(v)
    local char = LocalPlayer.Character
    if char then setAttribute(char, "speedboost", v) end
end

function VD.SetKillerMask(m)
    settings.killer.mask = m
    local char = LocalPlayer.Character
    if char then setAttribute(char, "Mask", m) end
end

function VD.SetSurvivorSpeedBoost(v)
    settings.survivor.speedboost = tonumber(v)
    local char = LocalPlayer.Character
    if char then setAttribute(char, "speedboost", v) end
end

function VD.ToggleRemoveSkillCheck(state)
    settings.removeSkillcheck = state
    removeSkillChecks()
end

function VD.GetMaskList()
    return masks
end

return VD
