-- PlayerModule.lua
local PlayerModule = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Flags
PlayerModule.UnlimitedJumpEnabled = false
PlayerModule.NoClipEnabled = false

-- Connections and per-part listeners
local connections = {
    _jump = nil,
    _char_added = nil,
    _noclip_descendant = nil,
}
local partConnections = {} -- [part] = { Changed = conn, Ancestry = conn }

-- Log helper
local function log(msg)
    print(msg)
end

-- Helper to safely disconnect a connection
local function safeDisconnect(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        pcall(function() conn:Disconnect() end)
    end
end

-- Clean up all per-part listeners (used when disabling NoClip or on character change)
local function cleanupPartConnections()
    for part, t in pairs(partConnections) do
        if t.Changed then safeDisconnect(t.Changed) end
        if t.Ancestry then safeDisconnect(t.Ancestry) end
        partConnections[part] = nil
    end
end

-- Enforce noclip on a single part and attach watchers to keep it enforced
local function enforceNoClipOnPart(part)
    if not part or not part:IsA("BasePart") then return end
    -- Apply immediately
    if part.CanCollide then
        -- pcall in case property is locked briefly
        pcall(function() part.CanCollide = false end)
    end

    -- If already watching this part, nothing to do
    if partConnections[part] then return end

    -- Watch property changes to revert CanCollide to false if changed
    local changedConn
    changedConn = part:GetPropertyChangedSignal("CanCollide"):Connect(function()
        if not PlayerModule.NoClipEnabled then
            -- if noclip disabled, disconnect this watcher (cleanup will handle)
            safeDisconnect(changedConn)
            return
        end
        -- If something set CanCollide true, immediately set false
        if part and part.Parent and part:IsA("BasePart") and part.CanCollide then
            pcall(function() part.CanCollide = false end)
        end
    end)

    -- Watch ancestry to clean up when the part is removed from the world
    local ancestryConn
    ancestryConn = part.AncestryChanged:Connect(function(_, parent)
        if not part:IsDescendantOf(game) then
            -- part removed: disconnect watchers and remove entry
            safeDisconnect(changedConn)
            safeDisconnect(ancestryConn)
            partConnections[part] = nil
        end
    end)

    partConnections[part] = {
        Changed = changedConn,
        Ancestry = ancestryConn,
    }
end

-- Apply NoClip to all current parts in a character
local function applyNoClipToCharacter(char)
    if not char then return end
    -- First clean up any existing part watchers (they belong to previous char)
    cleanupPartConnections()

    for _, descendant in ipairs(char:GetDescendants()) do
        if descendant:IsA("BasePart") then
            enforceNoClipOnPart(descendant)
        end
    end
end

-- Listen for newly added parts and enforce NoClip on them
local function listenForNewParts(char)
    -- Disconnect previous listener if present
    if connections._noclip_descendant then
        safeDisconnect(connections._noclip_descendant)
        connections._noclip_descendant = nil
    end

    if not char then return end

    connections._noclip_descendant = char.DescendantAdded:Connect(function(part)
        if not PlayerModule.NoClipEnabled then return end
        if part and part:IsA("BasePart") then
            -- Slight delay to allow accessories/tools to fully initialize, helpful in practice
            task.defer(function()
                -- Double-check still enabled
                if PlayerModule.NoClipEnabled then
                    enforceNoClipOnPart(part)
                end
            end)
        end
    end)
end

-- Re-hook CharacterAdded to reapply NoClip on respawn
local function hookCharacterAdded()
    if connections._char_added then return end

    connections._char_added = LocalPlayer.CharacterAdded:Connect(function(newChar)
        -- small wait to allow parts to load
        task.wait(0.05)
        if PlayerModule.NoClipEnabled then
            applyNoClipToCharacter(newChar)
            listenForNewParts(newChar)
        end
    end)
end

------------------------------------------------------------
-- Unlimited Jump (safe, single connection)
------------------------------------------------------------
if not connections._jump then
    connections._jump = UserInputService.JumpRequest:Connect(function()
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
-- NoClip API
------------------------------------------------------------
function PlayerModule.SetNoClip(val)
    PlayerModule.NoClipEnabled = val
    log("🚫 NoClip " .. (val and "ENABLED" or "DISABLED"))

    -- If enabling
    if val then
        local char = LocalPlayer.Character
        if char then
            applyNoClipToCharacter(char)
            listenForNewParts(char)
        end
        hookCharacterAdded()
    else
        -- disabling: disconnect descendant watcher and character hook and cleanup part watchers
        if connections._noclip_descendant then
            safeDisconnect(connections._noclip_descendant)
            connections._noclip_descendant = nil
        end
        if connections._char_added then
            safeDisconnect(connections._char_added)
            connections._char_added = nil
        end
        cleanupPartConnections()
    end
end

-- Clean shutdown helper (in case module reloaded/garbage collected)
function PlayerModule._Shutdown()
    -- disconnect jump
    if connections._jump then
        safeDisconnect(connections._jump)
        connections._jump = nil
    end
    -- disconnect other hooks
    if connections._noclip_descendant then safeDisconnect(connections._noclip_descendant); connections._noclip_descendant = nil end
    if connections._char_added then safeDisconnect(connections._char_added); connections._char_added = nil end
    cleanupPartConnections()
end

return PlayerModule
