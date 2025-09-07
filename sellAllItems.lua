local autosellmodule = {}

function autosellmodule.sellAllItems()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local netModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")  
    local sellAllRF = netModule.net:FindFirstChild("RF/SellAllItems")
    if not sellAllRF then
        warn("RF/SellAllItems not found!")
        return
    end

    local success, err = pcall(function()
        sellAllRF:InvokeServer()
    end)

    if success then
        print("✅ All items sold successfully!")
    else
        warn("❌ Failed to sell items:", err)
    end
end

return autosellmodule