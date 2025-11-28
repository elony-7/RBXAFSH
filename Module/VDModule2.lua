--========================================================
-- VDModule.lua (Repaired: reapply user settings when server updates / recreates attributes)
-- Minimal changes from your reverted version, focused on reliability.
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

-- store connections so we can disconnect them
local attributeConnections = {} -- { [1] = conn, ... }
-- small helper to add connection
local function pushConn(conn)
    if conn then
        table.insert(attributeConnections, conn)
    end
end

--========================================================
-- UNIVERSAL ATTRIBUTE SETTER
--========================================================
local function setAttribute(character, attr, value)
    if value == nil or not character then return end

    -- Roblox attribute (pcall to be safe in some contexts)
    local ok, has = pcall(function() return character:GetAttribute(attr) ~= nil end)
    if ok and has then
        -- Only set if value differs (avoid spam)
        local cur = character:GetAttribute(attr)
        if cur ~= value then
            pcall(function() character:SetAttribute(attr, value) end)
        end
        return
    end

    -- ValueObject in Attributes folder
    local folder = character:FindFirstChild("Attributes")
    if folder then
        local vo = folder:FindFirstChild(attr)
        if vo and vo.Value ~= value then
            pcall(function() vo.Value = value end)
        end
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
            pcall(function() conn:Disconnect() end)
        end
    end
    attributeConnections = {}
end

--========================================================
-- ENFORCE ATTRIBUTE VALUES (ANTI-SERVER OVERRIDE)
-- (ensures we reapply the saved script setting when server overwrites)
--========================================================
local function enforceAttribute(character, attrName, getValue)
    if not character then return end

    -- helper to attempt to get ValueObject and enforce immediately
    local function tryAttach()
        if not character or not character.Parent then
            return false
        end

        -- Folder ValueObject enforcement
        local folder = character:FindFirstChild("Attributes")
        if folder then
            local valObj = folder:FindFirstChild(attrName)
            if valObj then
                -- Immediately reapply desired value (in case server already changed it)
                local desired = getValue()
                if desired ~= nil then
                    pcall(function() valObj.Value = desired end)
                end

                -- Watch for later server changes to this ValueObject
                local conn = valObj:GetPropertyChangedSignal("Value"):Connect(function()
                    -- reapply desired value if server changed it
                    local target = getValue()
                    if target ~= nil and valObj.Value ~= target then
                        pcall(function() valObj.Value = target end)
                    end
                end)
                pushConn(conn)
                return true
            end
        end

        -- Roblox internal attribute enforcement
        local ok, exists = pcall(function() return character:GetAttribute(attrName) ~= nil end)
        if ok and exists then
            -- Immediately reapply desired value
            local desired2 = getValue()
            if desired2 ~= nil then
                pcall(function() character:SetAttribute(attrName, desired2) end)
            end

            local conn2 = character:GetAttributeChangedSignal(attrName):Connect(function()
                local target = getValue()
                if target ~= nil and character:GetAttribute(attrName) ~= target then
                    pcall(function() character:SetAttribute(attrName, target) end)
                end
            end)
            pushConn(conn2)
            return true
        end

        return false
    end

    -- Try to attach now; if not possible because Attributes/valueobject doesn't exist yet,
    -- set up a watcher on the character to detect when Attributes or the specific ValueObject is created,
    -- then attach enforcement then.
    local attached = tryAttach()
    if attached then
        return
    end

    -- If not attached, listen for creation of Attributes folder or the ValueObject
    local childAddedConn
    childAddedConn = character.ChildAdded:Connect(function(child)
        -- If Attributes folder appears, or some ValueObject is created, attempt to attach again
        if child.Name == "Attributes" then
            -- small delay to let its children initialize
            task.delay(0.05, function()
                if tryAttach() then
                    -- once attached, disconnect this watcher
                    if childAddedConn and childAddedConn.Connected then
                        pcall(function() childAddedConn:Disconnect() end)
                    end
                end
            end)
        else
            -- sometimes the Attributes folder exists and server creates the ValueObject directly
            -- so when any child is added, attempt attach (safe)
            task.delay(0.05, function()
                if tryAttach() then
                    if childAddedConn and childAddedConn.Connected then
                        pcall(function() childAddedConn:Disconnect() end)
                    end
                end
            end)
        end
    end)

    pushConn(childAddedConn)
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

        if sc1 then pcall(function() sc1:Destroy() end) end
        if sc2 then pcall(function() sc2:Destroy() end) end
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
    -- apply immediately to current character (if exists)
    local char = LocalPlayer.Character
    if char then
        setAttribute(char, "breakspeed", settings.killer.breakspeed)
    end
end

function VD.SetKillerSpeed(val)
    settings.killer.speed = tonumber(val)
    local char = LocalPlayer.Character
    if char then
        setAttribute(char, "speed", settings.killer.speed)
    end
end

function VD.SetKillerSpeedBoost(val)
    settings.killer.speedboost = tonumber(val)
    local char = LocalPlayer.Character
    if char then
        setAttribute(char, "speedboost", settings.killer.speedboost)
    end
end

function VD.SetKillerMask(maskName)
    settings.killer.mask = maskName
    local char = LocalPlayer.Character
    if char then
        setAttribute(char, "Mask", settings.killer.mask)
    end
end

function VD.SetSurvivorSpeedBoost(val)
    settings.survivor.speedboost = tonumber(val)
    local char = LocalPlayer.Character
    if char then
        setAttribute(char, "speedboost", settings.survivor.speedboost)
    end
end

function VD.ToggleRemoveSkillCheck(state)
    settings.removeSkillcheck = state
    local char = LocalPlayer.Character
    if char then
        removeSkillChecks()
    end
end

function VD.GetMaskList()
    return masks
end

return VD
