--local weatherCode = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua")
--local success, PurchaseWeather = pcall(function() return loadstring(weatherCode)() end)
--if not success then 
--    warn("Failed to load PurchaseWeather:", PurchaseWeather) 
-- end

--========================
-- UI Creation
--========================
-- Preload UI
local UIcode = game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
local UI = loadstring(UIcode)()

local Window = UI:CreateWindow({
    Title = "IkanTerbang Hub",
    SubTitle = "",
    TabWidth = 140,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})
--======================
-- TAB ORDER
--======================
local WeatherTab = Window:AddTab({ 
    Title = "Weather", 
    Icon = "(change this to weather icon code)" 
})

--======================
-- Load PurchaseWeather module
--======================
--======================
-- Add Buttons for Weather
--======================
WeatherTab:AddButton({
    Title = "Buy Storm Weather",
    Callback = function()
        -- Call the function from the module
        PurchaseWeather.BuyStorm()
    end
})

-- Example: if you want to add more weather later
-- WeatherTab:AddButton({
--     Title = "Buy Snow Weather",
--     Callback = function()
--         PurchaseWeather.BuySnow()
--     end
-- })
