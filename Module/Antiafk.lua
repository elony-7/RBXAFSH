local antiafkmodule = {}

antiafkmodule.enabled = false

function antiafkmodule.start()
    if antiafkmodule.enabled then return end  -- prevent multiple loops
    antiafkmodule.enabled = true

    task.spawn(function()
        while antiafkmodule.enabled do
            task.wait(60)
            local VirtualUser = game:GetService("VirtualUser")
            local LocalPlayer = game:GetService("Players").LocalPlayer
            if LocalPlayer and LocalPlayer.PlayerGui then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0,0))
            end
        end
    end)
end

function antiafkmodule.stop()
    antiafkmodule.enabled = false
end

return antiafkmodule