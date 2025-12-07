local antiafkmodule = {}

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

antiafkmodule.enabled = false
antiafkmodule._connection = nil
antiafkmodule._timer = 0

function antiafkmodule.start()
    if antiafkmodule.enabled then return end
    antiafkmodule.enabled = true
    antiafkmodule._timer = 0

    -- Use a RunService stepped loop instead of a coroutine
    antiafkmodule._connection = RunService.Stepped:Connect(function(_, dt)
        if not antiafkmodule.enabled then return end

        -- Count time manually to avoid long waits
        antiafkmodule._timer += dt

        if antiafkmodule._timer >= 60 then
            antiafkmodule._timer = 0

            if LocalPlayer and LocalPlayer.PlayerGui then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
    end)
end

function antiafkmodule.stop()
    antiafkmodule.enabled = false
    antiafkmodule._timer = 0

    -- Disconnect cleanly
    if antiafkmodule._connection then
        antiafkmodule._connection:Disconnect()
        antiafkmodule._connection = nil
    end
end

return antiafkmodule
