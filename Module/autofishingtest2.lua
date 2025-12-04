local AutoFishing = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

AutoFishing.Enabled = false

local netFolder = nil

-- Pre-fetch net folder every heartbeat (doesn't lag)
local function findNetFolder()
    local p = ReplicatedStorage:FindFirstChild("Packages")
    if not p then return nil end

    local idx = p:FindFirstChild("_Index")
    if not idx then return nil end

    local sleit = idx:FindFirstChild("sleitnick_net@0.2.0")
    if not sleit then return nil end

    return sleit:FindFirstChild("net")
end

-- Heartbeat loop connection
local heartbeatConnection

function AutoFishing.Start()
    AutoFishing.Enabled = true

    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end

    heartbeatConnection = RunService.Heartbeat:Connect(function()

        if not AutoFishing.Enabled then return end

        -- Refresh net folder (lightweight)
        netFolder = netFolder or findNetFolder()
        if not netFolder then
            netFolder = findNetFolder()
            return
        end

        -- Get remotes
        local equipRE     = netFolder:FindFirstChild("RE/EquipToolFromHotbar")
        local chargeRF    = netFolder:FindFirstChild("RF/ChargeFishingRod")
        local startRF     = netFolder:FindFirstChild("RF/RequestFishingMinigameStarted")
        local finishedRE  = netFolder:FindFirstChild("RE/FishingCompleted")

        -- SUB-STEP LOOP (2 times per Heartbeat = ~120 calls/sec)
        for i = 1, 2 do
            if equipRE then equipRE:FireServer(1) end
            if chargeRF then chargeRF:InvokeServer(workspace:GetServerTimeNow()) end
            if startRF then startRF:InvokeServer(1,1) end
            if finishedRE then finishedRE:FireServer() end
        end

    end)
end


function AutoFishing.Stop()
    AutoFishing.Enabled = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
end

return AutoFishing
