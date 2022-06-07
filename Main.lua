local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DiabloPro/UiLibrary/main/Main.lua"))()
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Assets = game:GetObjects("rbxassetid://9839966208")[1]

local screenGUI = Library.init("Kart's Epsilon 2")
local player = game.Players.LocalPlayer
local connections = {
    ["trinketEvent"] = nil,
    ["speedEvent"] = nil,
    ["manaPrecent"] = nil,
    ["health"] = nil,
    ["healthBars"] = {},
    ["manaBars"] = {},
    ["toolView"] = {}
}

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

local speedToggle = false
local toggleSpeed = localPlayerSection:createToggle("Walk Speed", function(boolean)
    speedToggle = boolean
    if not speedToggle then
        if game.ReplicatedStorage.Outfits[player.Data.Armor.Value] and game.ReplicatedStorage.Outfits[player.Data.Armor.Value].Stats:FindFirstChild("SpeedBoost") then
            player.Character.Stats.WalkSpeed.Value = 20 + game.ReplicatedStorage.Outfits[player.Data.Armor.Value].Stats.SpeedBoost.Value
        elseif game.ReplicatedStorage.OldOutfits[player.Data.Armor.Value] and game.ReplicatedStorage.OldOutfits[player.Data.Armor.Value].Stats:FindFirstChild("SpeedBoost") then
            player.Character.Stats.WalkSpeed.Value = 20 + game.ReplicatedStorage.OldOutfits[player.Data.Armor.Value].Stats.SpeedBoost.Value
        else
            player.Character.Stats.WalkSpeed.Value = 20
        end
    end
end)

toggleSpeed:createSlider({0,80}, 20, false, function(value)
    if connections.speedEvent then
        connections.speedEvent:Disconnect()
    end
    connections.speedEvent = player.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if speedToggle then
            player.Character.Humanoid.WalkSpeed = value
            player.Character.Stats.WalkSpeed.Value = value
        end
    end)
end)

local noFall = localPlayerSection:createToggle("No Fall", function(boolean)
    player.Character.FallDamage.Disabled = boolean
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

local manaGui
local manaPrecentage = visualCombatSection:createToggle("Mana Precentage", function(boolean)
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

local healthGui
local healthViewer = visualCombatSection:createToggle("Health", function(boolean)
    if boolean then
        healthGui = Instance.new("ScreenGui")
        getParent(healthGui)
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansLight
        textLabel.TextSize = 20
        textLabel.Size = UDim2.new(0, 20, 0, 20)
        textLabel.Parent = healthGui
        textLabel.TextColor3 = Color3.fromRGB(255,255,255)
        textLabel.TextStrokeTransparency = .9
        textLabel.Position = player.PlayerGui.StatGui.Container.Position + UDim2.new(0, 10, 0, -1)
        textLabel.AnchorPoint = player.PlayerGui.StatGui.Container.AnchorPoint
        textLabel.Text = math.floor(player.Character.Humanoid.Health).." / "..player.Character.Humanoid.MaxHealth
        connections.health = player.Character.Humanoid.HealthChanged:Connect(function()
            healthGui.TextLabel.Text = math.floor(player.Character.Humanoid.Health).." / "..player.Character.Humanoid.MaxHealth
        end)
    else
        connections.health:Disconnect()
        healthGui:Destroy()
    end
end)


local viewHealthBars = false
local viewManaBars = false
local viewTools = false
local healthGuis = {}
local manaGuis = {}
local toolGuis = {}

local function createHealthBar(character)
    local torso = character:FindFirstChild("Torso")
    if torso then
        local healthBar = Assets.Health:Clone()
        healthGuis[#healthGuis + 1] = healthBar
        getParent(healthBar)
        healthBar.Adornee = character.Torso
        healthBar.Frame.Frame.Size = UDim2.new(character.Humanoid.Health / character.Humanoid.MaxHealth, 0, 1, 0)

        connections.healthBars[#connections.healthBars + 1] =  character.Humanoid.HealthChanged:Connect(function()
            healthBar.Frame.Frame.Size = UDim2.new(character.Humanoid.Health / character.Humanoid.MaxHealth, 0, 1, 0)
        end)
    end
end

local function createManaBar(character)
    local torso = character:FindFirstChild("Torso")
    if torso then
        local manaBar = Assets.Mana:Clone()
        manaGuis[#manaGuis + 1] = manaBar
        getParent(manaBar)
        manaBar.Adornee = character.Torso
        manaBar.Frame.Frame.Size = UDim2.new(1, 0, character.Stats.Mana.Value / 100, 0)

        connections.manaBars[#connections.manaBars + 1] = character.Stats.Mana.Changed:Connect(function()
            manaBar.Frame.Frame.Size = UDim2.new(1, 0, character.Stats.Mana.Value / 100, 0)
        end)
    end
end

local function createToolViewer(character)
    local torso = character:FindFirstChild("Torso")
    if torso then
        local toolBar = Assets.Tool:Clone()
        toolGuis[#toolGuis + 1] = toolBar
        getParent(toolBar)
        toolBar.Adornee = character.Torso
        local tool = character:FindFirstChildWhichIsA("Tool") 
        if character:FindFirstChildWhichIsA("Tool") then
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

game.Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function()
        newPlayer.CharacterAdded:Wait()
        if viewHealthBars then
            createHealthBar(newPlayer.Character)
        end
        if viewManaBars then
            createManaBar(newPlayer.Character)
        end
        if viewTools then
            createToolViewer(newPlayer.Character)
        end
    end)
end)

local healthBars = visualCombatSection:createToggle("Health Bars", function(boolean)
    if boolean then
        viewHealthBars = true
        for i,v in pairs(game.Players:GetChildren()) do
            if v ~= player then
                createHealthBar(v.Character)
            end
        end
    else
        viewHealthBars = false
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
        viewManaBars = true
        for i,v in pairs(game.Players:GetChildren()) do
            if v ~= player then
                createManaBar(v.Character)
            end
        end
    else
        viewManaBars = false
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
        viewTools = true
        for i,v in pairs(game.Players:GetChildren()) do
            if v ~= player then
                createToolViewer(v.Character)
            end
        end
    else
        viewTools = false
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
        if spectatePlayer then
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
