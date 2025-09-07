local TeleportToPlayer = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Selected player
TeleportToPlayer.selectedPlayerName = "None"

-- Store buttons for cleanup
TeleportToPlayer.playerButtons = {}

-- Function to teleport to a player
function TeleportToPlayer.TeleportTo(name)
    if name == "None" then
        return warn("❌ No player selected")
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
        print("❌ Cannot teleport: player not ready")
    end
end

-- Function to create player buttons
function TeleportToPlayer.CreatePlayerButtons(tab, callbackUpdateSelected)
    -- Clear old buttons
    for _, btn in ipairs(TeleportToPlayer.playerButtons) do
        btn:Destroy()
    end
    TeleportToPlayer.playerButtons = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then  -- skip yourself
            local btn = tab:AddButton({
                Title = plr.DisplayName,
                Description = plr.Name,
                Callback = function()
                    TeleportToPlayer.selectedPlayerName = plr.Name
                    if callbackUpdateSelected then
                        callbackUpdateSelected(plr.DisplayName)
                    end
                end
            })
            table.insert(TeleportToPlayer.playerButtons, btn)
        end
    end

end

-- Auto-refresh when players join/leave
Players.PlayerAdded:Connect(function()
    if TeleportToPlayer.dropdownOpen and TeleportToPlayer.refreshCallback then
        TeleportToPlayer.refreshCallback()
    end
end)
Players.PlayerRemoving:Connect(function()
    if TeleportToPlayer.dropdownOpen and TeleportToPlayer.refreshCallback then
        TeleportToPlayer.refreshCallback()
    end
end)

return TeleportToPlayer
