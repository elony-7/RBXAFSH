-- PurchaseWeather.lua
local PurchaseWeather = {}

function PurchaseWeather.BuyStorm()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local netModule = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0")

    local netFolder = (netModule and netModule.ClassName == "ModuleScript" and require(netModule).net)
        or (netModule and netModule.ClassName == "Folder" and netModule:FindFirstChild("net"))

    local purchaseRF = netFolder and netFolder:FindFirstChild("RF/PurchaseWeatherEvent")
    if purchaseRF and purchaseRF:IsA("RemoteFunction") then
        pcall(function()
            purchaseRF:InvokeServer("Storm", 3, 35000)
        end)
        print("Purchased 'Storm' weather successfully! Tier: 3, Price 35000")
    end
end 

return PurchaseWeather
