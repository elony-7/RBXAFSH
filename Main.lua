--========================
--  Preload Functions
--========================

--========================
-- preLoad function Teleport module
--======================
local TeleportModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Teleport.lua"))()  -- remove the internal HttpGet for TeleportModule
print("Loaded TeleportModule:", TeleportModule)

--========================
-- preLoad function Teleport to Player Module
--======================

local TeleportToPlayer = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Teleporttoplayer.lua"))()  
print("Loaded TeleportToPlayer Module:", TeleportToPlayer)

--========================
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
})
print("Created Window:", Window)

--======================
-- TAB ORDER
--======================

--======================
-- Teleport Tab
--======================

local TeleportTab = Window:AddTab({ 
    Title = "Teleport", 
    Icon = "map" 
})
print("Created Teleport Tab:", TeleportTab)

local TeleportPlayerTab = Window:AddTab({ 
    Title = "Teleport to Player", 
    Icon = "user" 
})

local autoSellTab = Window:AddTab({ 
    Title = "Auto Sell", 
    Icon = "shopping-cart" 
})
print("Created Auto Sell Tab:", autoSellTab)

local WeatherTab = Window:AddTab({ 
    Title = "Weather", 
    Icon = "cloud-rain" 
})
print("Created Weather Tab:", WeatherTab)

local ExtraTab = Window:AddTab({ 
    Title = "Extra", 
    Icon = "settings" 
})
print("Created Extra Tab:", ExtraTab)


--======================
-- Teleport to Player Tab
--======================
-- Track dropdown state (global variable)
TeleportToPlayer.dropdownOpen = false

-- Toggle button to show/hide player list
local toggleButton = TeleportPlayerTab:AddButton({
    Title = "Select Player: None",
    Description = "Click to select player",
    Callback = function()
        TeleportToPlayer.dropdownOpen = not TeleportToPlayer.dropdownOpen
        if TeleportToPlayer.dropdownOpen then
            TeleportToPlayer.refreshCallback = function()
                TeleportToPlayer.CreatePlayerButtons(TeleportPlayerTab, function(displayName)
                    toggleButton.Title = "Select Player: " .. displayName
                end)
            end
            TeleportToPlayer.refreshCallback()
        else
            for _, btn in ipairs(TeleportToPlayer.playerButtons) do
                btn:Destroy()
            end
            TeleportToPlayer.playerButtons = {}
        end
    end
})

-- Teleport Player button
TeleportPlayerTab:AddButton({
    Title = "Teleport to Player",
    Description = "Teleport to the selected player",
    Callback = function()
        TeleportToPlayer.TeleportTo(TeleportToPlayer.selectedPlayerName)
    end
})

--======================
-- Add Buttons for Teleport Tab
--======================
for name, pos in pairs(TeleportModule.Locations) do
    TeleportTab:AddButton({
        Title = name,
        Description = "Teleport to " .. name,
        Callback = function()
            TeleportModule.TeleportTo(pos)  -- calls the function in the module
        end
    })
end

--======================
-- Add Buttons for auto sell Tab
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
-- Add Buttons for Weather Tab
--======================

WeatherTab:AddButton({
    Title = "Buy Storm Weather",
    Callback = function()
        -- Call the function from the module
        PurchaseWeather.BuyStorm()
    end
})

--======================
-- Add Buttons for Extra Tab
--======================

ExtraTab:AddToggle("AntiAFKToggle", {
    Title = "🛡️ Anti-AFK",
    Description = "Prevents being disconnected due to inactivity",
    Default = false
}):OnChanged(function(val)
    if val then
        antiafkmodule.start()
        print("🛡️ Anti-AFK ENABLED")
    else
        antiafkmodule.stop()
        print("🛡️ Anti-AFK DISABLED")
    end
end)

-- Example: if you want to add more weather later
-- WeatherTab:AddButton({
--     Title = "Buy Snow Weather",
--     Callback = function()
--         PurchaseWeather.BuySnow()
--     end
-- })
