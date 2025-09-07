--========================
--  Preload Functions
--========================
--======================
-- preLoad function PurchaseWeather module
--======================
local PurchaseWeather = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/PurchaseWeather.lua"))()  -- remove the internal HttpGet for PurchaseWeather
print("Loaded PurchaseWeather:", PurchaseWeather)
print("Has BuyStorm:", PurchaseWeather and PurchaseWeather.BuyStorm)
--======================
-- preLoad function autosell module
--======================
local autosellmodule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main//Module/sellAllItems.lua"))()  -- remove the internal HttpGet for PurchaseWeather
print("Loaded AutoSellModule:", autosellmodule)
print("Has sellAllItems:", autosellmodule and autosellmodule.sellAllItems)
--======================
-- preLoad function anti-afk
--======================
local antiafkmodule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Antiafk.lua"))()  -- remove the internal HttpGet for PurchaseWeather
print("Loaded AntiAFKModule:", antiafkmodule)


--========================
-- UI Creation
--========================
-- Preload UI
local UI = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
print("Loaded UI:", UI)

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

--======================
-- Create Window
--======================


local Window = UI:CreateWindow({
    Title = "IkanTerbang Hub",
    SubTitle = "",
    TabWidth = 140,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
    print( "Window created:", Window    )
})

--======================
-- TAB ORDER
--======================

local autoSellTab = Window:AddTab({ 
    Title = "Auto Sell", 
    Icon = "shopping-cart" 
    print( "Auto Sell Tab created:", autoSellTab )
})


local WeatherTab = Window:AddTab({ 
    Title = "Weather", 
    Icon = "cloud-rain" 
    print( "Weather Tab created:", WeatherTab)
    )
})

local ExtraTab = Window:AddTab({ 
    Title = "Extra", 
    Icon = "settings" 
    print( "Extra Tab created:", ExtraTab)
})




--======================
-- Add Buttons for auto sell
--======================
autoSellTab:AddButton({
    Title = "Sell All Items",
    Callback = function()
        -- Call the function from the module
        autosellmodule.sellAllItems()
    end
})

autoSellTab:AddToggle("AutoSellToggle", {
    Title = "💰 Auto Sell",
    Description = "Automatically sells all items at the specified interval.",
    Default = false
}):OnChanged(function(val)
    autosellmodule.autoSellEnabled = val
    if val then
        print("✅ Auto Sell ENABLED")
        task.spawn(function()
            while autosellmodule.autoSellEnabled do
                autosellmodule.sellAllItems()
                task.wait(autosellmodule.sellDelayMinutes * 60)  -- convert minutes to seconds
            end
        end)
    else
        print("❌ Auto Sell DISABLED")
    end
end)

-- Slider to adjust delay in minutes
autoSellTab:AddSlider("SellDelaySlider", {
    Title = "⏱ Sell Delay (Minutes)",
    Description = "Set how often items are sold automatically.",
    Default = 1,
    Min = 0.5,
    Max = 30,
    Rounding = 1
}):OnChanged(function(val)
    autosellmodule.sellDelayMinutes = val
    print("🔧 Auto Sell delay set to " .. autosellmodule.sellDelayMinutes .. " minute(s)")
end)

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

ExtraTab:AddToggle({
    Title = "🛡️ Anti-AFK",
    Description = "Prevents being disconnected due to inactivity",
    Default = false
}):OnChanged(function(val)
    if val then
        antiafkmodule.start()
        addLog("🛡️ Anti-AFK ENABLED")
    else
        antiafkmodule.stop()
        addLog("🛡️ Anti-AFK DISABLED")
    end
end)

-- Example: if you want to add more weather later
-- WeatherTab:AddButton({
--     Title = "Buy Snow Weather",
--     Callback = function()
--         PurchaseWeather.BuySnow()
--     end
-- })
