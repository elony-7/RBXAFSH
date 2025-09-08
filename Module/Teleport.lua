local TeleportModule = {}

-- Teleport coordinates
TeleportModule.Locations = {
    ["Small Islands Nowhere"] = Vector3.new(1187.7, 15.9, 2246.1),
    ["Fisherman Islands"] = Vector3.new(206.4, 69.1, 2946.9),
    ["Crater Island"] = Vector3.new(1118.7, 30.2, 4912.6),
    ["Coral Reefs (Cave)"] = Vector3.new(-2907.3, 10.8, 2047.6),
    ["Coral Reefs (Middle)"] = Vector3.new(-3214.4, 7.0, 2269.7),
    ["Lost Isle Island"] = Vector3.new(-3670.7, 37.5, -974.5),
    ["Sysiphus - Lost Isle"] = Vector3.new(-3690.3, -134.5, -1054.1),
    ["Treasure Room - Lost Isle"] = Vector3.new(-3516.6, -267.0, -1680.7),
    ["Esoteric Island"] = Vector3.new(2039.1, 85.3, 1373.1),
    ["Esoteric Depths"] = Vector3.new(3171.8, -1302.7, 1430.8),
    ["Kohana Volcano"] = Vector3.new(-493.7, 20.8, 214.2),
    ["Tropical Island"] = Vector3.new(-2074.0, 53.5, 3767.4),
    ["Kohana Island"] = Vector3.new(-631.3, 16.0, 613.4),
    ["Winter Island"] = Vector3.new(1685.6, 10.2, 3397.6),
    ["Safe Spot Crater"] = Vector3.new(1131.5, 30.2, 4866.5),
    ["Safe Spot Fisherman"] = Vector3.new(253.0, 69.1, 2924.5),
    ["Safe Spot Small Islands"] = Vector3.new(994.7, 1.0, 5073.8)
}
print("Teleport Locations Added")

-- Teleport function
function TeleportModule.TeleportTo(pos)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

return TeleportModule
