local TeleportSpecificModule = {}

-- ======================
--  LIST OF TELEPORT COORDINATES (NAMED)
-- ======================
TeleportSpecificModule.Locations = {
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
    ["Safe Spot Small Islands"] = Vector3.new(998.0, -0.4, 5076.3),
    ["Green Artifact"] = Vector3.new(1400.8, 3.0, 122.4),
    ["Purple Artifact"] = Vector3.new(0, 0, 0), -- empty placeholder
    ["Red Artifact"] = Vector3.new(878.7, 4.1, -338.2),
    ["Anchient Jungle (Mid)"] = Vector3.new(1313.5, 7.9, -201.4),
    ["Anchient Jungle (Temple)"] = Vector3.new(1475.6, -21.8, -630.2)
}

print("Teleport Specific Locations Added")

-- ======================
--  TELEPORT LOOP
-- ======================
local running = false
local index = 1

-- Convert dictionary → ordered array
local OrderedNames = {}
for name in pairs(TeleportSpecificModule.Locations) do
    table.insert(OrderedNames, name)
end

-- also keep count
local total = #OrderedNames

function TeleportSpecificModule.Start()
    if running then return end
    running = true

    task.spawn(function()
        while running do
            local name = OrderedNames[index]
            local pos = TeleportSpecificModule.Locations[name]

            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(pos)
            end

            index = index + 1
            if index > total then
                index = 1 -- loop back
            end

            task.wait(1.5) -- delay between teleports
        end
    end)
end

function TeleportSpecificModule.Stop()
    running = false
end

return TeleportSpecificModule
