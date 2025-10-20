--==================================================
-- Player ESP (Highlight-based)
--==================================================

local ESPPlayer = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

ESPPlayer.Enabled = false
local highlights = {}

--== Create Highlight for Player ==--
local function createESP(player)
    if not player.Character then return end
    if highlights[player] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP_Highlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 0) -- green
    highlight.FillTransparency = 0.7 -- transparent body glow
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = player.Character
    highlight.Parent = game.CoreGui -- ensures it’s always visible

    highlights[player] = highlight
end

--== Remove Highlight ==--
local function removeESP(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end

--== Refresh ESP for all players ==--
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESPPlayer.Enabled then
                createESP(player)
            else
                removeESP(player)
            end
        end
    end
end

--== Handle players joining/leaving ==--
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPPlayer.Enabled then
            task.wait(1)
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(removeESP)

--== Start/Stop ==--
function ESPPlayer.Start()
    if ESPPlayer.Enabled then return end
    ESPPlayer.Enabled = true
    updateESP()
    print("✅ Player ESP ENABLED")

    RunService.Heartbeat:Connect(function()
        if not ESPPlayer.Enabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not highlights[player] then
                    createESP(player)
                elseif highlights[player].Adornee ~= player.Character then
                    highlights[player].Adornee = player.Character
                end
            end
        end
    end)
end

function ESPPlayer.Stop()
    ESPPlayer.Enabled = false
    for player, highlight in pairs(highlights) do
        highlight:Destroy()
    end
    table.clear(highlights)
    print("❌ Player ESP DISABLED")
end

return ESPPlayer
