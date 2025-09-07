-- Function to safely load code from URL
local function safeLoad(url, name)
    local success, result = pcall(function()
        local code = game:HttpGet(url)
        return loadstring(code)()
    end)
    if success then
        print(name .. " loaded successfully!")
        return result
    else
        warn("Error loading " .. name .. ": " .. tostring(result))
        return nil
    end
end

-- Load PurchaseWeather
local PurchaseWeather = safeLoad("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua", "PurchaseWeather")

-- Preload UI Library
local UI = safeLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", "UI Library")

-- Load Main.lua
safeLoad("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Main.lua", "Main.lua")


-- Preload module
--local weatherCode = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua")
--local success, PurchaseWeather = pcall(function() return loadstring(weatherCode)() end)
--if not success then warn("Failed to load PurchaseWeather:", PurchaseWeather) end

--local weatherCode = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/PurchaseWeather.lua")
--local PurchaseWeather = loadstring(weatherCode)()

-- Preload UI Library
--local UIcode = game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
--local UI = loadstring(UIcode)()

-- Now call Main.lua
--local mainCode = game:HttpGet("https://raw.githubusercontent.com/elony-7/RBXAFSH/main/Main.lua")
--loadstring(mainCode)()  -- remove the internal HttpGet for PurchaseWeather
 
-- The Main.lua should now use the preloaded PurchaseWeather and UI