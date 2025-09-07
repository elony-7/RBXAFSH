--========================
--  Preload Functions
--========================

local PurchaseWeather = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua"))()  -- remove the internal HttpGet for PurchaseWeather
print("Loaded PurchaseWeather:", PurchaseWeather)
print("Has BuyStorm:", PurchaseWeather and PurchaseWeather.BuyStorm)

local autosellmodule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/sellAllItems.lua"))()  -- remove the internal HttpGet for PurchaseWeather
print("Loaded AutoSellModule:", autosellmodule)
print("Has sellAllItems:", autosellmodule and autosellmodule.sellAllItems)
--========================
-- UI Creation
--========================
-- Preload UI
local UI = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()


--=============== USE THIS ONLY WHEN IT RETURN NILL TO LOADSTRING===============
--local function tryLoad(url, name)
--    local success, result = pcall(function()
--        local code = game:HttpGet(url)
--        return loadstring(code)()
--    end)
--
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

--=============== USE THIS ONLY WHEN IT RETURN NILL TO LOADSTRING===============

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

local autoSellTab = Window:AddTab({ 
    Title = "Auto Sell", 
    Icon = "shopping-cart" 
})

local WeatherTab = Window:AddTab({ 
    Title = "Weather", 
    Icon = "cloud-rain" 
})

--======================
-- Load PurchaseWeather module
--======================
--======================
-- Add Buttons for Weather
--======================
autoSellTab:AddButton({
    Title = "Sell All Items",
    Callback = function()
        -- Call the function from the module
        autosellmodule.sellAllItems()
    end
})

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
