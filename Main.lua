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
local TeleportModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Teleport.lua"))()
local TeleportToPlayer = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Teleporttoplayer.lua"))()
local PurchaseWeather = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/PurchaseWeather.lua"))()
local autosellmodule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main//Module/sellAllItems.lua"))()
local antiafkmodule = loadstring(game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Module/Antiafk.lua"))()

print("Modules loaded:", TeleportModule, TeleportToPlayer, PurchaseWeather, autosellmodule, antiafkmodule)

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
local TeleportTab = Window:AddTab({Title = "Teleport", Icon = "map"})
local TeleportPlayerTab = Window:AddTab({Title = "Teleport to Player", Icon = "user"})
local AutoSellTab = Window:AddTab({Title = "Auto Sell", Icon = "shopping-cart"})
local WeatherTab = Window:AddTab({Title = "Weather", Icon = "cloud-rain"})
local ExtraTab = Window:AddTab({Title = "Extra", Icon = "settings"})

local Options = Fluent.Options

--========================
-- Teleport Tab Buttons
--========================
do
    for name, pos in pairs(TeleportModule.Locations) do
        TeleportTab:AddButton({
            Title = name,
            Description = "Teleport to " .. name,
            Callback = function()
                TeleportModule.TeleportTo(pos)
                Notify("Teleported", "You have been teleported to " .. name, 1)
            end
        })
    end
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
