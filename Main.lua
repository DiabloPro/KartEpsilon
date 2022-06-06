local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DiabloPro/UiLibrary/main/Main.lua"))()
local RunService = game:GetService("RunService")

local screenGUI = Library.init("Kart's Epsilon 2")
local player = game.Players.LocalPlayer
local connections = {
    ["trinketEvent"] = nil
}

-- humanoid
local humanoidTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9827813129")

local localPlayerSection = humanoidTab:createSection("Local Player")

local speed = localPlayerSection:createSlider("Speed Multiplier", {0,100}, 20, false, function(Value)
    player.Character.Stats.WalkSpeed.Value = Value
end)

local noFall = localPlayerSection:createToggle("No Fall", false, function(boolean)
    player.Character.FallDamage.Disabled = boolean
end)

local combatSection = humanoidTab:createSection("Combat")

-- trinkets
local trinketTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9830996211")
local trinketSettingsSection = trinketTab:createSection("Trinket Settings")

local AutoPickUp = trinketSettingsSection:createToggle("Auto Pickup", false, function(boolean)
    if boolean then
        connections.trinketEvent = RunService.Heartbeat:Connect(function()
            for i,v in pairs(workspace.MouseIgnore:GetChildren()) do
                if v.Name ~= "Entity" then
                    for i,item in pairs(v:GetDescendants()) do
                        if item:IsA("ClickDetector") then
                            if (player.Character.HumanoidRootPart.Position - item.Parent.Position).Magnitude <= 18 then
                                fireclickdetector(item, 18)
                            end
                        end
                    end
                end
            end
        end)
    else
        connections.trinketEvent:Disconnect()
    end
end)
