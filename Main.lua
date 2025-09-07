--local weatherCode = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua") local success, PurchaseWeather = pcall(function() return loadstring(weatherCode)() end) if not success then warn("Failed to load PurchaseWeather:", PurchaseWeather) end
--local weatherCode = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua")
--local PurchaseWeather = loadstring(weatherCode)()
--========================
-- UI Creation
--========================
-- Preload UI
local UI = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local PurchaseWeather = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Main.lua"))()  -- remove the internal HttpGet for PurchaseWeather

--local function tryLoad(url, name)
--    local success, result = pcall(function()
--        local code = game:HttpGet(url)
--        return loadstring(code)()
--    end)

--    if success then
--        print(name .. " loaded successfully!")
--        return result
--    else
--        warn("⚠ Error loading " .. name .. ": " .. tostring(result))
--       return nil
--    end
--end

-- Usage
--local PurchaseWeather = tryLoad(
--    "https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua",
--    "PurchaseWeather"
--)

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
