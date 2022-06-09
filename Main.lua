local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DiabloPro/UiLibrary/main/Main.lua"))()
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Assets = game:GetObjects("rbxassetid://9839966208")[1]

local screenGUI = Library.init("Kart's Epsilon 2")
local player = game.Players.LocalPlayer
local settings = {
    speedToggle = false,
    speed = 20,
    viewHealthBars = false,
    viewManaBars = false,
    viewTools = false,
}
local connections = {
    trinketEvent = nil,
    speedEvent = nil,
    manaPrecent = nil,
    health = nil,
    healthBars = {},
    manaBars = {},
    toolView = {},
    infiniteMana = nil,
    noFog = nil,
    day = nil
}
local spellPrecentages = {
    Gate = {}
}

local defaultSettings = {
    speedBind = nil
}

local savedSettings = {}
if writefile then
    if isfile("KartEpsilon.txt") then
        savedSettings = HttpService:JSONDecode(readfile("KartEpsilon.txt"))
    else
        savedSettings = defaultSettings
    end
end
local settingsMT = setmetatable(savedSettings,{
    __newindex = function(self, key, value)
        rawset(self, key, value)
        if writefile then
            print("saving")
            writefile("KartEpsilon.txt", HttpService:JSONEncode(savedSettings))
        end
    end,
    __index = function(self, index)
        return rawget(self, index)
    end
})

local function getParent(screenGUI)
    if syn then
		syn.protect_gui(screenGUI)
		screenGUI.Parent = game.CoreGui
	elseif gethui then
		screenGUI.Parent = gethui()
	else
		screenGUI.Parent = game.CoreGui
	end
end

-- humanoid
local humanoidTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9827813129")

local localPlayerSection = humanoidTab:createSection("Local Player")

local function setWalkSpeed()
    if connections.speedEvent then
        connections.speedEvent:Disconnect()
    end
    connections.speedEvent = player.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if settings.speedToggle then
            player.Character.Humanoid.WalkSpeed = settings.WalkSpeed
            player.Character.Stats.WalkSpeed.Value = settings.WalkSpeed
        end
    end)
end

local toggleSpeed = localPlayerSection:createToggle("Walk Speed", function(boolean)
    settings.speedToggle = boolean
    if not settings.speedToggle then
        if game.ReplicatedStorage.Outfits[player.Data.Armor.Value] and game.ReplicatedStorage.Outfits[player.Data.Armor.Value].Stats:FindFirstChild("SpeedBoost") then
            player.Character.Stats.WalkSpeed.Value = 20 + game.ReplicatedStorage.Outfits[player.Data.Armor.Value].Stats.SpeedBoost.Value
        elseif game.ReplicatedStorage.OldOutfits[player.Data.Armor.Value] and game.ReplicatedStorage.OldOutfits[player.Data.Armor.Value].Stats:FindFirstChild("SpeedBoost") then
            player.Character.Stats.WalkSpeed.Value = 20 + game.ReplicatedStorage.OldOutfits[player.Data.Armor.Value].Stats.SpeedBoost.Value
        else
            player.Character.Stats.WalkSpeed.Value = 20
        end
    else
        setWalkSpeed()
    end
end)

toggleSpeed:createSlider({0,80}, settings.speed, false, function(value)
    settings.speed = value
    setWalkSpeed()
end)

toggleSpeed:createBind(function(bind)
    savedSettings.speedBind = Enum.KeyCode[bind]
end)

if savedSettings.speedBind then
    toggleSpeed:setBind(savedSettings.speedBind)
end


local noFall = localPlayerSection:createToggle("No Fall", function(boolean)
    player.Character.FallDamage.Disabled = boolean
end)

local localPlayerVisuals = humanoidTab:createSection("Visuals")

local noFog = localPlayerVisuals:createToggle("No Fog", function(boolean)
    if boolean then
        game.Lighting.FogEnd = 9e9
        game.Lighting.FogStart = 9e9
        connections.noFog = game.Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
            game.Lighting.FogEnd = 9e9
            game.Lighting.FogStart = 9e9
        end)
    else
        connections.noFog:Disconnect()
    end
end)

local day = localPlayerVisuals:createToggle("Day Time", function(boolean)
    if boolean then
        game.Lighting.TimeOfDay = 12
        connections.day = game.Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
            game.Lighting.TimeOfDay = 12
        end)
    else
        connections.day:Disconnect()
    end
end)

local regionColor = localPlayerVisuals:createToggle("Region Color", function(boolean)
    if boolean then
        game.Lighting.RegionColor.Enabled = false
    else
        game.Lighting.RegionColor.Enabled = true
    end
end)


local manaSection = humanoidTab:createSection("Mana")
local manaGui

local manaPrecentage = manaSection:createToggle("Mana Precentage", function(boolean)
    if boolean then
        manaGui = Instance.new("ScreenGui")
        getParent(manaGui)
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansLight
        textLabel.TextSize = 20
        textLabel.Size = UDim2.new(0, 20, 0, 20)
        textLabel.Parent = manaGui
        textLabel.TextColor3 = Color3.fromRGB(255,255,255)
        textLabel.TextStrokeTransparency = .9
        textLabel.Position = player.PlayerGui.ManaGui.LeftContainer.Position + UDim2.new(0,26,0,-178)
        textLabel.AnchorPoint = player.PlayerGui.ManaGui.LeftContainer.AnchorPoint
        textLabel.Text = math.floor(player.Character.Stats.Mana.Value).."%"
        connections.manaPrecent = player.Character.Stats.Mana.Changed:Connect(function(newValue)
            manaGui.TextLabel.Text = math.floor(newValue).."%"
        end)
    else
        connections.manaPrecent:Disconnect()
        manaGui:Destroy()
    end
end)
-- trinkets
local trinketTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9830996211")
local trinketSettingsSection = trinketTab:createSection("Trinket Settings")

local AutoPickUp = trinketSettingsSection:createToggle("Auto Pickup", function(boolean)
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

-- combat
local combatTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9839226250")
local visualCombatSection = combatTab:createSection("Visuals")
local healthGuis = {}
local manaGuis = {}
local toolGuis = {}

local function createHealthBar(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        local healthBar = Assets.Health:Clone()
        healthGuis[#healthGuis + 1] = healthBar
        getParent(healthBar)
        healthBar.Adornee = humanoidRootPart
        healthBar.Frame.Frame.Size = UDim2.new(character.Humanoid.Health / character.Humanoid.MaxHealth, 0, 1, 0)

        connections.healthBars[#connections.healthBars + 1] =  character.Humanoid.HealthChanged:Connect(function()
            healthBar.Frame.Frame.Size = UDim2.new(character.Humanoid.Health / character.Humanoid.MaxHealth, 0, 1, 0)
        end)
    end
end

local function createManaBar(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        local manaBar = Assets.Mana:Clone()
        manaGuis[#manaGuis + 1] = manaBar
        getParent(manaBar)
        manaBar.Adornee = humanoidRootPart
        manaBar.Frame.Frame.Size = UDim2.new(1, 0, character.Stats.Mana.Value / 100, 0)

        connections.manaBars[#connections.manaBars + 1] = character.Stats.Mana.Changed:Connect(function()
            manaBar.Frame.Frame.Size = UDim2.new(1, 0, character.Stats.Mana.Value / 100, 0)
        end)
    end
end

local function createToolViewer(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        local toolBar = Assets.Tool:Clone()
        toolGuis[#toolGuis + 1] = toolBar
        getParent(toolBar)
        toolBar.Adornee = humanoidRootPart
        local tool = character:FindFirstChildWhichIsA("Tool") 
        if tool then
            toolBar.Frame.Text = tool.Name
        else
            toolBar.Frame.Text = ""
        end

        connections.toolView[#connections.toolView + 1] = character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                toolBar.Frame.Text = child.Name
            end
        end)
        connections.toolView[#connections.toolView + 1] = character.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                toolBar.Frame.Text = ""
            end
        end)
    end
end

game.Workspace.Alive.ChildAdded:Connect(function(child)
    if settings.viewHealthBars then
        createHealthBar(child)
    end
    if settings.viewManaBars then
        createManaBar(child)
    end
    if settings.viewTools then
        createToolViewer(child)
    end
end)

local healthBars = visualCombatSection:createToggle("Health Bars", function(boolean)
    if boolean then
        settings.viewHealthBars = boolean
        for i,v in pairs(workspace.Alive:GetChildren()) do
            if v ~= player.Character then
                local playerFromCharacter = game.Players:GetPlayerFromCharacter(v)
                if playerFromCharacter then
                    createHealthBar(v)
                end
            end
        end
    else
        settings.viewHealthBars = boolean
        for i,v in pairs(connections.healthBars) do
            if v.Connected then
                v:Disconnect()
            end
            connections.healthBars[i] = nil
        end
        for i,v in pairs(healthGuis) do
            v:Destroy()
        end
    end
end)

local manaBars = visualCombatSection:createToggle("Mana Bars", function(boolean)
    if boolean then
        settings.viewManaBars = boolean
        for i,v in pairs(workspace.Alive:GetChildren()) do
            if v ~= player.Character then
                local playerFromCharacter = game.Players:GetPlayerFromCharacter(v)
                if playerFromCharacter then
                    createManaBar(v)
                end  
            end
        end
    else
        settings.viewManaBars = boolean
        for i,v in pairs(connections.manaBars) do
            if v.Connected then
                v:Disconnect()
            end
            connections.manaBars[i] = nil
        end
        for i,v in pairs(manaGuis) do
            v:Destroy()
        end
    end
end)

local viewTools = visualCombatSection:createToggle("View Tools", function(boolean)
    if boolean then
        settings.viewTools = boolean
        for i,v in pairs(workspace.Alive:GetChildren()) do
            if v ~= player.Character then
                local playerFromCharacter = game.Players:GetPlayerFromCharacter(v)
                if playerFromCharacter then
                    createToolViewer(v)
                end  
            end
        end
    else
        settings.viewTools = boolean
        for i,v in pairs(connections.toolView) do
            if v.Connected then
                v:Disconnect()
            end
            connections.toolView[i] = nil
        end
        for i,v in pairs(toolGuis) do
            v:Destroy()
        end
    end
end)


--leaderboard viewer
local currentHover = {}
for i,v in pairs(player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame:GetChildren()) do
    v.MouseEnter:Connect(function()
        table.insert(currentHover, 1, v.Text)
    end)

    v.MouseLeave:Connect(function()
        local removeIndex = table.find(currentHover, v.Text)
        if removeIndex then
            table.remove(currentHover, removeIndex)
        end
    end)
end

player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame.ChildAdded:Connect(function(child)
    child.MouseEnter:Connect(function()
        table.insert(currentHover, 1, child.Text)
    end)
    
    child.MouseLeave:Connect(function()
        local removeIndex = table.find(currentHover, child.Text)
        if removeIndex then
            table.remove(currentHover, removeIndex)
        end
    end)
end)

player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame.ChildRemoved:Connect(function(child)
    local removeIndex = table.find(currentHover, child.Text)
    if removeIndex then
        table.remove(currentHover, removeIndex)
    end
end)

local function spectate(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin and currentHover[1] then
        local spectatePlayer = game.Players:FindFirstChild(currentHover[1])
        if spectatePlayer and spectatePlayer.Character then
            if spectatePlayer.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = spectatePlayer.Character.Humanoid
            end
        end
    elseif inputState == Enum.UserInputState.Begin and not currentHover[1] then
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
    end
    return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("Spectate", spectate, false, Enum.UserInputType.MouseButton1)
