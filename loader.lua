-- Preload module
local weather = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua")
local success, PurchaseWeather = pcall(function() return loadstring(weather)() end)
if not success then warn("Failed to load PurchaseWeather:", PurchaseWeather) end

-- Preload UI
local UIcode = game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
local UI = loadstring(UIcode)()

-- Now call Main.lua
local mainCode = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Main.lua")
loadstring(mainCode)()  -- remove the internal HttpGet for PurchaseWeather
 
-- The Main.lua should now use the preloaded PurchaseWeather and UI