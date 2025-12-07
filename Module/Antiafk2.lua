local antiafkmodule = {}

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
antiafkmodule.enabled = false

-- Store the running thread for cleanup
local antiAFKThread = nil

function antiafkmodule.start()
    if antiafkmodule.enabled then return end -- Prevent duplicate loop
    antiafkmodule.enabled = true

    -- Start Anti-AFK loop
    antiAFKThread = task.spawn(function()
        while antiafkmodule.enabled do
            task.wait(60)

            -- Safe checks
            if LocalPlayer and LocalPlayer.PlayerGui then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
    end)
end

function antiafkmodule.stop()
    antiafkmodule.enabled = false

    -- Stop the spawned thread safely
    if antiAFKThread then
        task.cancel(antiAFKThread)
        antiAFKThread = nil
    end
end

return antiafkmodule
