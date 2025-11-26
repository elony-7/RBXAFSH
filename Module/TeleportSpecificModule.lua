local TeleportSpecificModule = {}

-- ======================
--  LIST OF TELEPORT COORDINATES (NAMED)
-- ======================
TeleportSpecificModule.Locations = {
    ["location1"] = Vector3.new(-0.2, 2061.6, -100.1),
    ["location2"] = Vector3.new(215.3, 152.6, 124.4),
    ["location3"] = Vector3.new(77.8, 73.0, 172.8),
    ["location4"] = Vector3.new(-2.1, 3.5, 333.6),
    ["location5"] = Vector3.new(-88.8, 353.8, 799.5),
    ["location6"] = Vector3.new(-139.4, 389.0, 132.6)
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

local total = #OrderedNames

function TeleportSpecificModule.Start()
    if running then return end
    running = true

    index = 1  -- ALWAYS start from location1 when enabled

    task.spawn(function()
        while running do

            local name = OrderedNames[index]
            local pos = TeleportSpecificModule.Locations[name]

            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(pos)
            end

            -- move to next
            index = index + 1
            if index > total then
                index = 1
            end

            -- special wait for location1 (far, needs loading)
            if name == "location1" then
                task.wait(2)
            else
                task.wait(0.08)
            end
        end
    end)
end

function TeleportSpecificModule.Stop()
    running = false
end

return TeleportSpecificModule
