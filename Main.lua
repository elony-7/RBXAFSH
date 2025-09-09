--========================
-- Preload Fluent UI Library
--========================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
print("Loaded Fluent:", Fluent)

-- Helper function for notifications
local function Notify(title, content, duration)
    Fluent:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3
    })
end

Notify("Notification", "Script is loading...", 5)

--========================
-- Preload Modules
--========================
local AutoFishing = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Autofishing.lua"))()
local AutoReel = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Autoreel.lua"))()
local AutoCastPerfect = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/AutoCastPerfect.lua"))()
local TeleportModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Teleport.lua"))()
local TeleportToPlayer = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Teleporttoplayer.lua"))()
local PurchaseWeather = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/PurchaseWeather.lua"))()
local PlayerModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/PlayerModule.lua"))()
local autosellmodule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main//Module/sellAllItems.lua"))()
local antiafkmodule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Antiafk.lua"))()

print("Modules loaded:", AutoFishing, AutoReel, AutoCastPerfect, TeleportModule, TeleportToPlayer, PurchaseWeather,PlayerModule, autosellmodule, antiafkmodule)

--========================
-- Create Main Window
--========================
local Window = Fluent:CreateWindow({
    Title = "IkanTerbang Hub",
    SubTitle = "",
    TabWidth = 140,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})
print("Created Window:", Window)

--========================
-- Create Tabs
--========================
local FarmTab = Window:AddTab({Title = "Farm", Icon = "play"})
local TeleportTab = Window:AddTab({Title = "Teleport", Icon = "map"})
local TeleportPlayerTab = Window:AddTab({Title = "Teleport to Player", Icon = "user"})
local PlayerTab = Window:AddTab({Title = "Player", Icon = "user-cog"})
local AutoSellTab = Window:AddTab({Title = "Auto Sell", Icon = "shopping-cart"})
local WeatherTab = Window:AddTab({Title = "Weather", Icon = "cloud-rain"})
local ExtraTab = Window:AddTab({Title = "Extra", Icon = "settings"})

local Options = Fluent.Options 

--========================
-- Farm Tab 
--========================

--=== Auto Fishing Toggle ===
do
    FarmTab:AddToggle("AutoFishingPerfect", {
        Title = "🎣 Auto Fishing Perfect",
        Description = "Automatically starts fishing minigame perfectly.",
        Default = false
    }):OnChanged(function(val)
        if val then
            AutoFishing.Start()
            print("✅ Auto Fishing Perfect ENABLED")
            Notify("✅ Auto Fishing Perfect", "Auto Fishing Perfect ENABLED", 2)
        else
            AutoFishing.Stop()
            print("❌ Auto Fishing Perfect DISABLED")
            Notify("❌ Auto Fishing Perfect", "Auto Fishing Perfect DISABLED", 2)
        end
    end)
end

--==== Auto Cast Perfect Toggle ===

do
    FarmTab:AddToggle("AutoCastPerfect", {
        Title = "🎣 Auto Cast Perfect",
        Description = "Automatically casts the fishing line perfectly.",
        Default = false
    }):OnChanged(function(val)
        if val then
            AutoCastPerfect.Start()
            print("✅ Auto Cast Perfect ENABLED")
            Notify("✅ Auto Cast Perfect", "Auto Cast Perfect ENABLED", 2)
        else
            AutoCastPerfect.Stop()
            print("❌ Auto Cast Perfect DISABLED")
            Notify("❌ Auto Cast Perfect", "Auto Cast Perfect DISABLED", 2)
        end
    end)
end

--==== Auto Reel Toggle ====
do
    FarmTab:AddToggle("AutoReel", {
        Title = "🎣 Auto Reel",
        Description = "Automatically reels in the fish during the fishing minigame.",
        Default = false
    }):OnChanged(function(val)
        if val then
            AutoReel.Start()
            print("✅ Auto Reel ENABLED")
            Notify("✅ Auto Reel", "Auto Reel ENABLED", 2)
        else
            AutoReel.Stop()
            print("❌ Auto Reel DISABLED")
            Notify("❌ Auto Reel", "Auto Reel DISABLED", 2)
        end
    end)
end

--========================
-- Teleport Tab (Dropdown)
--========================
do
    -- Create a list of locations
    local locationList = {}
    for name, _ in pairs(TeleportModule.Locations) do
        table.insert(locationList, name)
    end

    -- Default selection
    local selectedLocation = locationList[1] or "None"

    -- Add Dropdown
    local locationDropdown = TeleportTab:AddDropdown("SelectLocationDropdown", {
        Title = "Select Location",
        Values = locationList,
        Multi = false,
        Default = selectedLocation
    })

    -- Set the default value
    locationDropdown:SetValue(selectedLocation)

    -- Handle dropdown change
    locationDropdown:OnChanged(function(value)
        selectedLocation = value
        print("Selected location:", value)
    end)

    -- Teleport button
    TeleportTab:AddButton({
        Title = "Teleport",
        Description = "Teleport to the selected location",
        Callback = function()
            local pos = TeleportModule.Locations[selectedLocation]
            if pos then
                TeleportModule.TeleportTo(pos)
                Notify("Teleported", "You have been teleported to " .. selectedLocation, 2)
            else
                Notify("Error", "Location not found!", 2)
            end
        end
    })
end


--========================
-- Teleport to Player Tab
--========================
do
    local playerList = TeleportToPlayer.GetInitialPlayers() or {}
    if #playerList == 0 then table.insert(playerList, "None") end
    local selectedPlayer = playerList[1]

    TeleportToPlayer.selectedPlayerName = selectedPlayer

    local playerDropdown = TeleportPlayerTab:AddDropdown("SelectPlayerDropdown", {
        Title = "Select Player",
        Values = playerList,
        Multi = false,
        Default = selectedPlayer
    })

    playerDropdown:SetValue(selectedPlayer)
    playerDropdown:OnChanged(function(value)
        selectedPlayer = value
        TeleportToPlayer.selectedPlayerName = value
        print("Selected player:", value)
    end)

    TeleportPlayerTab:AddButton({
        Title = "Teleport to Player",
        Description = "Teleport to the selected player",
        Callback = function()
            TeleportToPlayer.TeleportTo(selectedPlayer)
            Notify("Teleport", "Teleported to " .. selectedPlayer, 2)
        end
    })
end


--========================
-- Player Tab
--========================
do -- Unlimited Jump Toggle
    PlayerTab:AddToggle("UnlimitedJump", {
        Title = "♾️ Unlimited Jump",
        Description = "Allows jumping infinitely",
        Default = false
    }):OnChanged(function(val)
        PlayerModule.SetUnlimitedJump(val)
    end)
end    

do  -- NoClip Toggle
    PlayerTab:AddToggle("NoClip", {
        Title = "🚫 NoClip",
        Description = "Makes character pass through walls",
        Default = false
    }):OnChanged(function(val)
        PlayerModule.SetNoClip(val)
    end)
end

--========================
-- Auto Sell Tab
--========================
do
    AutoSellTab:AddButton({
        Title = "Sell All Items",
        SubTitle = "Sell Anywhere",
        Callback = function()
            autosellmodule.sellAllItems()
            Notify("Sell Anywhere", "All items sold!", 2)
        end
    })

    local autoSellToggle = AutoSellTab:AddToggle("AutoSellToggle", {
        Title = "💰 Auto Sell",
        Description = "Automatically sells all items at the specified interval.",
        Default = false
    })

    autoSellToggle:OnChanged(function(val)
        autosellmodule.autoSellEnabled = val
        Notify("Auto Sell", val and "Auto Sell ENABLED" or "Auto Sell DISABLED", 2)
        if val then
            task.spawn(function()
                while autosellmodule.autoSellEnabled do
                    autosellmodule.sellAllItems()
                    task.wait(autosellmodule.sellDelayMinutes * 60)
                end
            end)
        end
    end)
    Options.AutoSellToggle:SetValue(false)

    AutoSellTab:AddSlider("SellDelaySlider", {
        Title = "⏱ Sell Delay (Minutes)",
        Description = "Set how often items are sold automatically.",
        Default = 1,
        Min = 0.5,
        Max = 30,
        Rounding = 1,
        Callback = function(val)
            autosellmodule.sellDelayMinutes = val
            Notify("Auto Sell Delay", "Delay set to " .. val .. " minute(s)", 2)
        end
    })
end


--========================
-- Weather Tab
--========================
do
    local weatherData = {
        {Title = "Storm", Func = PurchaseWeather.BuyStorm},
        {Title = "Wind", Func = PurchaseWeather.BuyWind},
        {Title = "Cloudy", Func = PurchaseWeather.BuyCloudy},
        {Title = "Snow", Func = PurchaseWeather.BuySnow},
        {Title = "Radiant", Func = PurchaseWeather.BuyRadiant}
    }

    for _, weather in ipairs(weatherData) do
        WeatherTab:AddButton({
            Title = "Buy " .. weather.Title .. " Weather",
            Callback = function()
                weather.Func()
                Notify("Weather Purchased", weather.Title .. " weather purchased!", 2)
            end
        })
    end
end

--========================
-- Extra Tab
--========================
do
    local antiAFK = ExtraTab:AddToggle("AntiAFKToggle", {
        Title = "🛡️ Anti-AFK",
        Description = "Prevents being disconnected due to inactivity",
        Default = false
    })

    antiAFK:OnChanged(function(val)
        if val then
            antiafkmodule.start()
        else
            antiafkmodule.stop()
        end
        Notify("🛡️ Anti-AFK", val and "Anti-AFK ENABLED" or "Anti-AFK DISABLED", 2)
    end)
end

--========================
-- Final Notification
--========================
Notify("Notification", "The Script has loaded successfully!", 3)
