-- PurchaseWeather.lua
print("[PurchaseWeather.lua] Loaded!")
local PurchaseWeather = {}

local function buyWeather(name, tier, price)
    print("BuyWeather called:", name)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local netModule = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0")

    local netFolder = (netModule and netModule.ClassName == "ModuleScript" and require(netModule).net)
        or (netModule and netModule.ClassName == "Folder" and netModule:FindFirstChild("net"))

    local purchaseRF = netFolder and netFolder:FindFirstChild("RF/PurchaseWeatherEvent")
    if purchaseRF and purchaseRF:IsA("RemoteFunction") then
        pcall(function()
            purchaseRF:InvokeServer(name, tier, price)
        end)
        print("Purchased '" .. name .. "' weather successfully! Tier:", tier, "Price:", price)
    end
end

function PurchaseWeather.BuyStorm() buyWeather("Storm", 3, 35000) end
function PurchaseWeather.BuyWind() buyWeather("Wind", 2, 10000) end
function PurchaseWeather.BuyCloudy() buyWeather("Cloudy", 2, 20000) end
function PurchaseWeather.BuySnow() buyWeather("Snow", 2, 15000) end
function PurchaseWeather.BuyRadiant() buyWeather("Radiant", 3, 50000) end

return PurchaseWeather