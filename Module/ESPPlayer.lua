--==================================================
-- Player ESP Module
--==================================================

local ESPPlayer = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

ESPPlayer.Enabled = false
local espObjects = {} -- store all ESP BillboardGui objects

--== Helper: Create ESP Billboard ==--
local function createESP(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    if espObjects[player] then return end -- already created

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP"
    billboard.Adornee = player.Character:FindFirstChild("Head")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.DisplayName .. " (" .. player.Name .. ")"
    label.TextColor3 = Color3.new(1, 1, 0)
    label.TextStrokeTransparency = 0.2
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Parent = billboard

    billboard.Parent = player.Character:FindFirstChild("Head")
    espObjects[player] = billboard
end

--== Helper: Remove ESP Billboard ==--
local function removeESP(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end

--== Update Loop ==--
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

--== Player Added / Removed ==--
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPPlayer.Enabled then
            task.wait(1)
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

--== Main Control Functions ==--
function ESPPlayer.Start()
    ESPPlayer.Enabled = true
    updateESP()
    print("✅ Player ESP ENABLED")

    -- Keep updating if character respawns or new players join
    RunService.Heartbeat:Connect(function()
        if not ESPPlayer.Enabled then return end
        updateESP()
    end)
end

function ESPPlayer.Stop()
    ESPPlayer.Enabled = false
    for player, esp in pairs(espObjects) do
        esp:Destroy()
    end
    table.clear(espObjects)
    print("❌ Player ESP DISABLED")
end

return ESPPlayer
