-- AutoReel.lua
local AutoReel = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Replace with your actual RemoteEvent path
local completedRE = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RE/FishingCompleted")

local spamming = false
local spamThread
local inputConnection

-- Function to start spamming
local function startSpam()
    if spamming then return end
    spamming = true
    print("✅ Started unlimited spam (40ms delay)")

    spamThread = task.spawn(function()
        while spamming do
            pcall(function()
                completedRE:FireServer()
            end)
            task.wait(0.04) -- 40ms delay
        end
    end)
end

-- Function to stop spam but keep module alive
local function stopSpam()
    spamming = false
    print("🛑 Spam stopped (module still active)")
end

-- Function to stop spam and destroy the module
local function quitAndDestroy()
    spamming = false
    if inputConnection then
        inputConnection:Disconnect()
        inputConnection = nil
    end
    print("🛑 Spam stopped — module destroyed")
    if script then
        script:Destroy()
    end
end

-- Hotkey listener
inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Home then
        startSpam()
    elseif input.KeyCode == Enum.KeyCode.PageUp then
        stopSpam()
    elseif input.KeyCode == Enum.KeyCode.PageDown then
        quitAndDestroy()
    end
end)

-- Module API
function AutoReel.Start()
    startSpam()
end

function AutoReel.Stop()
    stopSpam()
end

return AutoReel
