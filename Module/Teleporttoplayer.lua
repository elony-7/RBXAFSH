local TeleportToPlayer = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Selected player
TeleportToPlayer.selectedPlayerName = "None"

-- Function to teleport to a player
function TeleportToPlayer.TeleportTo(name)
    if name == "None" then
        warn("❌ No player selected")
        return
    end

    -- Wait for local character if not loaded
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
    end

    local targetPlayer = Players:FindFirstChild(name)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame =
            CFrame.new(targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,5,0))
        print("✅ Teleported to " .. targetPlayer.DisplayName)
    else
        warn("❌ Cannot teleport: player not ready")
    end
end

-- Function to get list of player names excluding yourself
function TeleportToPlayer.GetPlayersNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

return TeleportToPlayer
