-- AutoTap_Debug.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Net package reference
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

-- RemoteEvents
local FishingMinigameChanged = net:WaitForChild("RE/FishingMinigameChanged")
local FishingStopped = net:WaitForChild("RE/FishingStopped")

FishingMinigameChanged.OnClientEvent:Connect(function(...)
    local args = {...}
    print("🎣 FishingMinigameChanged fired with", #args, "args:")
    for i, v in ipairs(args) do
        print("   Arg", i, "→", v, typeof(v))
    end
end)

FishingStopped.OnClientEvent:Connect(function(...)
    local args = {...}
    print("🛑 FishingStopped fired with", #args, "args:")
    for i, v in ipairs(args) do
        print("   Arg", i, "→", v, typeof(v))
    end
end)

print("✅ AutoTap Debug mode loaded – waiting for Fishing events...")
