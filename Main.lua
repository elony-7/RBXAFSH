-- Load PurchaseWeather module safely
local weather = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/PurchaseWeather.lua")
local PurchaseWeather = loadstring(weather)()

--========================
-- UI Creation
--========================
local UI = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

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
