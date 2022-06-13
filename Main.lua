local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DiabloPro/UiLibrary/main/Main.lua"))()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Assets = game:GetObjects("rbxassetid://9839966208")[1]

local screenGUI = Library.init("Kart's Epsilon 2")
local player = game.Players.LocalPlayer
local resetOnDeath = {}
local settings = {
    speedToggle = false,
    speed = 20,
    viewHealthBars = false,
    viewManaBars = false,
    viewTools = false,
    chatLogger = false,
    jumpPower = 50,
    infJump = false,
    esp = false,
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
    day = nil,
    manaHelp = {},
    chatLogger = {},
    noFire = nil,
    jumpHeight = nil,
}
local spellPrecentages = {
    Gate = {Normal = {.50, .80}},
    Ignis = {Snap = {.45, .60}, Normal = {.75, 1}},
    Gelidus = {Normal = {.80, 1}},
    Viribus = {Snap = {.60, .75},Normal = {.25, .35}},
    Telorum = {Normal = {.75, .95}},
    Snarvindur = {Snap = {.10, .35},Normal = {.55, .75}},
    Percutiens = {Snap = {.55, .75}, Normal = {.5, .75}},
    Velo = {Snap = {.50, 1}, Normal = {.45, .65}},
    Catena = {Normal = {.20, .70}},
    Fimbulvetr = {Normal = {.60, .95}}

}

local Proxy = {}
if writefile then
    if isfile("KartEpsilon.txt") then
        Proxy = HttpService:JSONDecode(readfile("KartEpsilon.txt"))
    else
        Proxy = defaultSettings
    end
end
local savedSettings = setmetatable({},{
    __newindex = function(self, key, value)
        Proxy[key] = value
        if writefile then
            writefile("KartEpsilon.txt", HttpService:JSONEncode(Proxy))
        end
    end,
    __index = function(self, index)
        return Proxy[index]
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

-- [[ Humanoid Tab ]]
local humanoidTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9827813129")

-- local player section

local localPlayerSection = humanoidTab:createSection("Local Player")
local oldSpeed
local function setWalkSpeed()
    if connections.speedEvent then
        connections.speedEvent:Disconnect()
    end
    if settings.speedToggle then
        player.Character.Humanoid.WalkSpeed = settings.speed
    end
    connections.speedEvent = player.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if settings.speedToggle and settings.speed ~= player.Character.Humanoid.WalkSpeed then  
            oldSpeed = player.Character.Humanoid.WalkSpeed
            player.Character.Humanoid.WalkSpeed = settings.speed
        end
    end)
end

resetOnDeath.toggleSpeed = localPlayerSection:createToggle("Walk Speed", function(boolean)
    settings.speedToggle = boolean
    if not boolean then
        player.Character.Humanoid.WalkSpeed = oldSpeed
    end
    oldSpeed = player.Character.Humanoid.WalkSpeed
    setWalkSpeed()
end)
resetOnDeath.toggleSpeed:createSlider({0, 80}, settings.speed, false, function(value)
    settings.speed = value
    setWalkSpeed()
end)
resetOnDeath.toggleSpeed:createBind(function(bind)
    savedSettings.speedBind = bind
end)
if savedSettings.speedBind then
    resetOnDeath.toggleSpeed:setBind(savedSettings.speedBind)
end

local function setJumpPower()
    if connections.jumpHeight then
        connections.jumpHeight:Disconnect()
    end
    if settings.jumpHeight then
        player.Character.Humanoid.JumpPower = settings.jumpPower
        connections.jumpHeight = player.Character.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            player.Character.Humanoid.JumpPower = settings.jumpPower
        end)
    end
end

resetOnDeath.jumpHeight = localPlayerSection:createToggle("Jump Height", function(boolean)
    settings.jumpHeight = boolean
    if boolean then
        setJumpPower()
    else
        setJumpPower()
       player.Character.Humanoid.JumpPower = 50
    end
end)
resetOnDeath.jumpHeight:createSlider({0, 250}, settings.jumpPower, false, function(value)
    settings.jumpPower = value
    if settings.jumpHeight then
        setJumpPower()
    else
        player.Character.Humanoid.JumpPower = 50
    end
end)
resetOnDeath.jumpHeight:createBind(function(bind)
    savedSettings.jumpHeight = bind
end)
if savedSettings.jumpHeight then
    resetOnDeath.jumpHeight:setBind(savedSettings.jumpHeight)
end

resetOnDeath.infJump = localPlayerSection:createToggle("Infinite Jump", function(boolean)
    if boolean then
        ContextActionService:BindAction("infJump", function(actionName, inputState, inputObject)
            if inputObject.KeyCode == Enum.KeyCode.Space and inputState == Enum.UserInputState.Begin then
                game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState(3)
            end
        end, false, Enum.KeyCode.Space)
        settings.infJump = boolean
    else
        if settings.infJump then
            ContextActionService:UnbindAction("infJump")
            settings.infJump = boolean
        end
    end
end)
local floating
local floatPart
local function float(bool)
    if bool then
        if floatPart then
            floatPart:Destroy()
        end
        local character = player.Character
        floatPart = Instance.new("Part")
        floatPart.Transparency = 1
        floatPart.Anchored = true
        floatPart.Size = Vector3.new(6, 1, 6)
        floatPart.Parent = character
        floating = RunService.Heartbeat:Connect(function()
            if character then
                floatPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
            else
                floating:Disconnect()
                floatPart:Destroy()
            end
        end)
    else
        if floating then
            floating:Disconnect()
            floatPart:Destroy()
        end
    end
end

resetOnDeath.float = localPlayerSection:createToggle("Float", function(boolean)
    if boolean then
        float(true)
    else
        if floating then
            float(false)
        end
    end
end)
local noclip 
local function noClip()
    noclip = RunService.Stepped:Connect(function()
        for i,v in pairs(player.character:GetDescendants()) do
            if v:IsA("BasePart") and v ~= floatPart then
                v.CanCollide = false
            end
        end
    end)
end

resetOnDeath.noClip = localPlayerSection:createToggle("No Clip", function(boolean)
    if boolean then
        noClip()
    else
        if noclip then
            noclip:Disconnect()
            player.Character.Torso.CanCollide = true
            player.Character.HumanoidRootPart.CanCollide = true
        end
    end
end)

-- Status Section

local statusSection = humanoidTab:createSection("Status")

resetOnDeath.noFall = statusSection:createToggle("No Fall", function(boolean)
    player.Character.FallDamage.Disabled = boolean
end)

resetOnDeath.noFire = statusSection:createToggle("No Fire", function(boolean)
    if boolean then
        connections.noFire = game.Workspace.AliveData[player.Name].Status.ChildAdded:Connect(function(child)
            if child.Name == "Burn" then
                game.Players.LocalPlayer.Backpack.Roll.Dash:FireServer("backward")
            end
        end)
    else
        if connections.noFire then
            connections.noFire:Disconnect()
        end
    end
end)

-- visual section

local localPlayerVisuals = humanoidTab:createSection("Visuals")
local oldFogStart
local oldFogEnd 
local noFog = localPlayerVisuals:createToggle("No Fog", function(boolean)
    if boolean then
        oldFogStart = game.Lighting.FogStart
        oldFogEnd = game.Lighting.FogEnd
        game.Lighting.FogEnd = 9e9
        game.Lighting.FogStart = 9e9
        connections.noFog = game.Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
            oldFogStart = game.Lighting.FogStart
            oldFogEnd = game.Lighting.FogEnd
            game.Lighting.FogEnd = 9e9
            game.Lighting.FogStart = 9e9
        end)
    else
        connections.noFog:Disconnect()
        game.Lighting.FogStart = oldFogStart
        game.Lighting.FogEnd = game.Lighting.FogEnd
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

local fullBright = localPlayerVisuals:createToggle("Full Bright", function(boolean)
    if boolean then
        game.Lighting.Ambient = Color3.fromRGB(255,255,255)
    else
        game.Lighting.Ambient = Color3.fromRGB(20,20,20)
    end
end)

-- Mana Section

local manaSection = humanoidTab:createSection("Mana")
local manaHelpGuis = {}
local manaScreenGui
local manaGui

resetOnDeath.manaPrecentage = manaSection:createToggle("Mana Precentage", function(boolean)
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
        if manaGui then
            connections.manaPrecent:Disconnect()
            manaGui:Destroy()
        end
    end
end)

local function CreateManaBarSection(Tool)
    local Normal = Instance.new("Frame")
    table.insert(manaHelpGuis, Normal)
    Normal.Size = UDim2.new(0,player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.X, 0, (spellPrecentages[Tool].Normal[2] * player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.Y) - (spellPrecentages[Tool].Normal[1] * player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.Y))
    Normal.Position = UDim2.new(0,player.PlayerGui.ManaGui.LeftContainer.Mana.AbsolutePosition.X, 0, (player.PlayerGui.ManaGui.LeftContainer.Mana.AbsolutePosition.Y + player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.Y) - (spellPrecentages[Tool].Normal[1] * player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.Y))
    Normal.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    Normal.BackgroundTransparency = 0.7
    Normal.AnchorPoint = Vector2.new(0,1)
    Normal.BorderSizePixel = 0
    Normal.Parent = manaScreenGui
    if spellPrecentages[Tool].Snap then
        local Snap = Instance.new("Frame")
        table.insert(manaHelpGuis, Snap)
        Snap.Size = UDim2.new(0,player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.X, 0, (spellPrecentages[Tool].Snap[2] * player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.Y) - (spellPrecentages[Tool].Snap[1] * player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.Y))
        Snap.Position = UDim2.new(0,player.PlayerGui.ManaGui.LeftContainer.Mana.AbsolutePosition.X, 0, (player.PlayerGui.ManaGui.LeftContainer.Mana.AbsolutePosition.Y + player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.Y) - (spellPrecentages[Tool].Snap[1] * player.PlayerGui.ManaGui.LeftContainer.Mana.AbsoluteSize.Y))
        Snap.BackgroundColor3 = Color3.fromRGB(255,0,0)
        Snap.BackgroundTransparency = 0.7
        Snap.AnchorPoint = Vector2.new(0,1)
        Snap.BorderSizePixel = 0
        Snap.Parent = manaScreenGui
    end
end

resetOnDeath.manaHelp = manaSection:createToggle("Mana Helper", function(boolean)
    if boolean then
        manaScreenGui = Instance.new("ScreenGui")
        getParent(manaScreenGui)
        local tool = player.Character:FindFirstChildWhichIsA("Tool")
        if tool then
            if spellPrecentages[tool.Name] then
                CreateManaBarSection(tool.Name)
            end
        end
        connections.manaHelp[#connections.manaHelp + 1] = player.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and  spellPrecentages[child.Name] then
                for i,v in pairs(manaHelpGuis) do
                    v:Destroy()
                end
                CreateManaBarSection(child.Name)
            end
        end)

        connections.manaHelp[#connections.manaHelp + 1] = player.Character.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                for i,v in pairs(manaHelpGuis) do
                    v:Destroy()
                end
            end
        end)
    else
        if manaScreenGui then
            manaScreenGui:Destroy()
        end
        for i,v in pairs(manaHelpGuis) do
            v:Destroy()
        end
        for i,v in pairs(connections.manaHelp) do
            if v.Connected then
                v:Disconnect()
            end
            connections.manaHelp[i] = nil
        end
    end
end)

-- [[ Trinket Tab ]]

local trinketTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9830996211")

-- Trinket Settings Section

local trinketSettingsSection = trinketTab:createSection("Trinket Settings")

resetOnDeath.AutoPickUp = trinketSettingsSection:createToggle("Auto Pickup", function(boolean)
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
        if connections.trinketEvent then
            connections.trinketEvent:Disconnect()
        end
    end
end)

-- auto farm section

local autoFarmSection = trinketTab:createSection("Auto Farms")
local Samples = {
    Golem = {
        {Position = Vector3.new(97.4538, -0.434484, -0.22738), Size = Vector3.new(30.8951, 21.2244, 7.14055)},
        {Position = Vector3.new(-49.9016, 0.321288, 0.0279962), Size = Vector3.new(26.3476, 21.2244, 6.98773)},
        {Position = Vector3.new(-91.1604, -0.00120255, 0.00451192), Size = Vector3.new(26.7601, 21.2244, 7.06941)},
        {Position = Vector3.new(-48.8979, 0.190896, -0.337764), Size = Vector3.new(29.7613, 21.2244, 9.24906)},
        {Position = Vector3.new(120.899, 0.365381, 0.199799), Size = Vector3.new(26.6789, 21.2244, 7.06826)},
        {Position = Vector3.new(87.3603, 0.432861, -0.248479), Size = Vector3.new(30.9549, 21.2244, 7.19889)},
        {Position = Vector3.new(98.9478, 0.0871018, -0.0283097), Size = Vector3.new(27.6181, 21.2244, 6.94294)},
        {Position = Vector3.new(129.364, -0.197744, -0.097349), Size = Vector3.new(28.899, 21.2244, 9.71609)},
        {Position = Vector3.new(92.3842, 0.175521, 0.0184415), Size = Vector3.new(27.2372, 21.2244, 6.94294)},
        {Position = Vector3.new(-40.8294, 0.308402, -0.0884393), Size = Vector3.new(26.3219, 21.2244, 6.94294)},
        {Position = Vector3.new(128.226, 0.226565, 0.204513), Size = Vector3.new(30.893, 21.2244, 7.31937)},
        {Position = Vector3.new(94.1385, 0.0431978, 0.0970109), Size = Vector3.new(28.8545, 21.2244, 9.68399)},
        {Position = Vector3.new(111.304, -0.531714, 0.0866501), Size = Vector3.new(29.434, 21.2244, 9.82151)},
        {Position = Vector3.new(114.92, -0.522673, -0.0265291), Size = Vector3.new(31.319, 21.2244, 7.28207)},
        {Position = Vector3.new(119.803, -0.324016, 0.0011931), Size = Vector3.new(28.9781, 21.2244, 9.52019)},
        {Position = Vector3.new(134.197, 0.266445, -0.263155), Size = Vector3.new(29.6828, 21.2244, 9.093179)},
        {Position = Vector3.new(-69.830322265625, 0.31224679946899414, 0.05765676498413086), Size = Vector3.new(29.055614471435547, 21.224441528320312, 9.780242919921875)},
        {Position = Vector3.new(-52.79409408569336, 0.23649653792381287, 0.1052883192896843), Size = Vector3.new(27.016094207763672, 21.224437713623047, 6.942939758300781)},
        {Position = Vector3.new(148.90367126464844, 0.034123897552490234, 0.11051199585199356), Size = Vector3.new(26.841506958007812, 21.224443435668945, 8.177550315856934)},
        {Position = Vector3.new(-65.32487487792969, 0.25492265820503235, 0.33328777551651), Size = Vector3.new(29.480472564697266, 21.224441528320312, 8.816274642944336)}
    },
    Arocknid = {
        {Position = Vector3.new(127.964, -0.0538416, -0.00187828), Size = Vector3.new(22.6375, 6.48817, 9.82289)},
        {Position = Vector3.new(-49.3993, 0.504834, 0.203969), Size = Vector3.new(22.3245, 5.78818, 9.82289)},
        {Position = Vector3.new(96.1259, -0.0112494, -0.00279934),  Size = Vector3.new(23.4944, 5.20113, 9.82288)},
        {Position = Vector3.new(92.3455, 0.134186, -0.00703047),  Size = Vector3.new(22.82, 5.21705, 9.82288)},
        {Position = Vector3.new(-46.6269, 0.464673, -0.0406529),  Size = Vector3.new(22.6706, 7.18777, 9.82288)},
        {Position = Vector3.new(132.085, 0.229973, 0.0747214),  Size = Vector3.new(29.407, 21.6882, 9.82287)},
        {Position = Vector3.new(-59.8025, -1.19805, -0.964491), Size = Vector3.new(29.8405, 20.8521, 13.6765)},
        {Position = Vector3.new(-57.8643, 0.320641, -0.0980313), Size = Vector3.new(22.8025, 5.89641, 9.82289)},
        {Position = Vector3.new(139.978, -0.385224, 0.222407), Size = Vector3.new(23.294, 5.38065, 9.82287)},
        {Position = Vector3.new(-82.0555, 0.194586, -0.0308195), Size = Vector3.new(29.5621, 21.8918, 9.82288)},
        {Position = Vector3.new(118.182, -0.366833, 0.211787), Size = Vector3.new(26.247, 6.37737, 9.82289)},
        {Position = Vector3.new(-81.1965, -0.395728, 0.0986654), Size = Vector3.new(22.4644, 5.76675, 9.82288)},
        {Position = Vector3.new(107.625, 0.280223, 0.0595678), Size = Vector3.new(21.6632, 6.39288, 9.82288)},
        {Position = Vector3.new(-62.5091, -0.337311, -0.157288), Size = Vector3.new(22.3155, 5.92786, 9.82288)},
        {Position = Vector3.new(-93.2697, 0.19109, -0.058423), Size = Vector3.new(26.97, 5.66475, 9.82288)},
        {Position = Vector3.new(-69.4651, 0.0975829, 0.0243299), Size = Vector3.new(26.3123, 5.73223, 9.82289)},
        {Position = Vector3.new(-89.6128, -0.787651, -0.225858), Size = Vector3.new(26.3799, 6.58374, 9.82289)},
        {Position = Vector3.new(100.282, -0.437356, -0.0459662), Size = Vector3.new(22.0941, 5.80486, 9.82289)},
        {Position = Vector3.new(-67.1624, 0.13984, -0.0246577), Size = Vector3.new(22.0966, 7.06314, 9.82289)},
        {Position = Vector3.new(119.36811828613281, -1.0369927883148193, -0.5022960305213928), Size = Vector3.new(29.97052764892578, 17.485389709472656, 18.156631469726562)},
        {Position = Vector3.new(-39.59138870239258, -0.03274347260594368, -0.010010188445448875), Size = Vector3.new(29.675865173339844, 22.02476692199707, 9.822883605957031)},
        {Position = Vector3.new(-65.3839111328125, -0.3653535842895508, -0.15660856664180756), Size = Vector3.new(29.465694427490234, 21.434459686279297, 11.77912425994873)},
        {Position = Vector3.new(120.09639739990234, -1.0471605062484741, -1.2547099590301514), Size = Vector3.new(29.998435974121094, 19.153602600097656, 15.867521286010742)},
    },
    ["Zombie Scroom"] = {
        {Position = Vector3.new(-39.4827, -0.115834, -0.0619981),  Size = Vector3.new(23.5904, 5.81699, 9.8061)},
        {Position = Vector3.new(104.986, -0.789834, 0.0132009),  Size = Vector3.new(27.534, 22.5479, 8.81733)},
        {Position = Vector3.new(96.1792, -0.116503, -0.143842), Size = Vector3.new(22.503, 7.63632, 9.20713)},
        {Position = Vector3.new(99.905, -0.901383, 0.162267), Size = Vector3.new(22.8085, 8.02807, 9.17897)},
        {Position = Vector3.new(128.737, -0.284868, 0.114766), Size = Vector3.new(20.0084, 6.32811, 8.20491)},
        {Position = Vector3.new(-77.8275, -0.918813, -0.545952), Size = Vector3.new(27.1053, 18.0897, 17.1152)},
        {Position = Vector3.new(108.108, -0.339437, -0.0716684), Size = Vector3.new(24.9171, 6.46262, 6.61744)},
        {Position = Vector3.new(-54.9684, -0.190821, 0.0964238), Size = Vector3.new(23.5001, 5.72369, 8.2062)},
        {Position = Vector3.new(-59.3694, -0.281378, 0.0410373), Size = Vector3.new(20.4938, 6.03111, 8.2657)},
        {Position = Vector3.new(139.859, -0.0833582, 0.32167), Size = Vector3.new(25.0113, 5.28326, 6.59065)},
        {Position = Vector3.new(-75.5606, -0.701828, -0.821961), Size = Vector3.new(24.4835, 6.63158, 6.51199)},
        {Position = Vector3.new(144.42, -0.43584, -0.440727), Size = Vector3.new(27.1208, 21.7143, 7.32825)},
        {Position = Vector3.new(140.694, -0.189937, -0.13926), Size = Vector3.new(19.9815, 5.782, 7.31265)},
        {Position = Vector3.new(88.5829, -0.468566, 0.248371), Size = Vector3.new(27.2692, 22.0152, 6.7162)},
        {Position = Vector3.new(-54.0247, 0.366933, -0.103601), Size = Vector3.new(27.5983, 21.6058, 7.17057)},
        {Position = Vector3.new(-35.6044, -0.730994, -0.574959), Size = Vector3.new(24.5499, 7.0503, 6.45329)},
        {Position = Vector3.new(-64.6993, -0.519661, -1.07412), Size = Vector3.new(27.2916, 21.5719, 12.756)},
        {Position = Vector3.new(118.145, -0.281102, 0.0945256), Size = Vector3.new(23.2774, 5.02354, 9.73415)},
        {Position = Vector3.new(-85.3726, 0.477567, 0.00832964), Size = Vector3.new(20.78, 6.48127, 7.11338)},
        {Position = Vector3.new(-51.3793, 0.0148774, 0.0912062), Size = Vector3.new(24.8615, 5.70743, 6.6373)},
        {Position = Vector3.new(146.565, -1.00608, -0.234112), Size = Vector3.new(23.7545, 8.71677, 8.66758)},
        {Position = Vector3.new(-69.76303100585938, -0.19621434807777405, 0.050688259303569794), Size = Vector3.new(24.94872283935547, 5.113282203674316, 6.634149551391602)},
        {Position = Vector3.new(-59.40373992919922, -0.22421212494373322, -0.2150178849697113), Size = Vector3.new(28.03226089477539, 21.493621826171875, 7.172720909118652)},
        {Position = Vector3.new(91.94567108154297, -0.31782403588294983, 0.15542340278625488), Size = Vector3.new(23.099960327148438, 5.680273056030273, 9.56641674041748)},
        {Position = Vector3.new(101.47180938720703, -0.78349369764328, -0.5875802040100098), Size = Vector3.new(27.44139862060547, 21.903316497802734, 10.854096412658691)},
        {Position = Vector3.new(97.80067443847656, -0.01120656356215477, 0.36516228318214417), Size = Vector3.new(24.393875122070312, 6.214439868927002, 6.532125949859619)},
        {Position = Vector3.new(-50.350494384765625, -0.3028421401977539, 0.02116999216377735), Size = Vector3.new(27.655296325683594, 21.467769622802734, 6.942940711975098)},
        {Position = Vector3.new(-39.10206985473633, -0.11543133854866028, 0.58193039894104), Size = Vector3.new(20.777559280395508, 7.890842437744141, 5.833657264709473)}
    },
    ["Evil Eye"] = {
        {Position = Vector3.new(-53.5407, -0.541131, -0.159955), Size = Vector3.new(27.056, 8.82404, 7.99947)},
        {Position = Vector3.new(128.377, 0.187968, 0.124119), Size = Vector3.new(31.8241, 22.1793, 6.90987)},
        {Position = Vector3.new(87.7785, -0.61249, -0.921955), Size = Vector3.new(31.5243, 21.7116, 12.3421)},
        {Position = Vector3.new(121.824, -0.046153, -0.00241101), Size = Vector3.new(24.9895, 5.065, 6.63602)},
        {Position = Vector3.new(-86.7643, -0.163713, 0.102795), Size = Vector3.new(26.8871, 5.80384, 9.73901)},
        {Position = Vector3.new(-68.9045, 0.475077, 0.186249), Size = Vector3.new(23.6508, 7.18834, 6.83785)},
        {Position = Vector3.new(-54.0492, -0.224129, 0.13069), Size = Vector3.new(24.0999, 7.28674, 6.84081)},
        {Position = Vector3.new(92.0631, -0.528837, 0.192445), Size = Vector3.new(26.278, 8.91703, 7.81141)},
        {Position = Vector3.new(-60.9528, -0.454917, -0.110025), Size = Vector3.new(27.0089, 5.86287, 9.55502)},
        {Position = Vector3.new(122.404, -0.696153, -0.585154), Size = Vector3.new(31.1692, 21.9695, 9.95856)},
        {Position = Vector3.new(122.412, -0.323546, 0.0823666), Size = Vector3.new(23.7969, 6.31102, 8.41968)},
        {Position = Vector3.new(-96.1765, -0.202974, 0.152837), Size = Vector3.new(23.4099, 5.65913, 8.41605)},
        {Position = Vector3.new(-85.4094, -1.57224, -0.31801), Size = Vector3.new(30.6647, 19.262, 16.44)},
        {Position = Vector3.new(98.0687, -0.602798, -1.27863), Size = Vector3.new(30.8484, 20.9931, 13.4695)},
        {Position = Vector3.new(137.637, -0.282517, -1.61636), Size = Vector3.new(31.2321, 20.5434, 14.6898)},
        {Position = Vector3.new(-38.1045, -0.126116, -0.0588019), Size = Vector3.new(24.7511, 5.43165, 6.63602)},
        {Position = Vector3.new(-89.097, -0.755778, 0.0843383), Size = Vector3.new(26.6691, 6.95526, 9.48811)},
        {Position = Vector3.new(-46.9984, -0.307544, 0.359908), Size = Vector3.new(24.4325, 6.34746, 6.52271)},
        {Position = Vector3.new(96.6961, -0.660198, -0.0513901), Size = Vector3.new(23.5865, 6.85864, 6.81)},
        {Position = Vector3.new(91.7128, -0.529116, 0.107033), Size = Vector3.new(30.7884, 22.2484, 7.88039)},
        {Position = Vector3.new(102.003, -0.535711, -0.266678), Size = Vector3.new(30.6915, 21.4973, 7.33479)},
        {Position = Vector3.new(-87.7204, -0.650144, 7.15256e-07), Size = Vector3.new(26.3342, 6.53218, 9.82289)},
        {Position = Vector3.new(-61.572, -0.138491, -0.299153), Size = Vector3.new(331.2238, 21.4936, 7.17274)},
        {Position = Vector3.new(-50.968, -0.244203, 0.0519134), Size = Vector3.new(25.1319, 6.35849, 6.63602)},
        {Position = Vector3.new(96.3133773803711, 0.09735338389873505, 0.40268146991729736), Size = Vector3.new(23.707427978515625, 5.822920799255371, 8.125804901123047)},
        {Position = Vector3.new(107.68841552734375, -0.18181127309799194, 0.17695987224578857), Size = Vector3.new(26.53668212890625, 5.403897285461426, 9.709190368652344)},
        {Position = Vector3.new(110.77523803710938, -0.4797418415546417, -0.00803021714091301), Size = Vector3.new(27.242164611816406, 7.234105110168457, 9.687934875488281)}
    },
    Howler = {
        {Position = Vector3.new(-89.3153, 0.190229, -0.0768645), Size = Vector3.new(19.7627, 6.3369, 7.11338)},
        {Position = Vector3.new(145.907, -0.097608, -0.216544), Size = Vector3.new(22.5911, 7.63627, 9.07052)},
        {Position = Vector3.new(100.191, 0.299853, -0.0888763), Size = Vector3.new(22.0006, 7.21782, 9.83234)},
        {Position = Vector3.new(126.092, -0.593315, -1.535), Size = Vector3.new(26.5885, 20.2959, 15.2151)},
        {Position = Vector3.new(121.955, -0.560921, 0.136298), Size = Vector3.new(22.4359, 7.87431, 8.94813)},
        {Position = Vector3.new(121.453, -0.311265, -0.298853), Size = Vector3.new(26.5043, 21.4852, 10.7768)},
        {Position = Vector3.new(132.357, 0.295705, -0.0847987), Size = Vector3.new(20.2319, 6.14825, 7.11338)},
        {Position = Vector3.new(-36.9567, 0.190455, 0.0808362), Size = Vector3.new(26.0827, 21.4224, 7.11338)},
        {Position = Vector3.new(145.998, -1.11115, -0.385473), Size = Vector3.new(26.175, 19.7703, 15.389)},
        {Position = Vector3.new(-62.2925, -0.472247, -0.00401328), Size = Vector3.new(22.3508, 6.59069, 9.5843)},
        {Position = Vector3.new(104.374, -0.657694, -0.906799), Size = Vector3.new(26.585, 21.4501, 12.5134)},
        {Position = Vector3.new(114.189, -0.423347, 0.134225), Size = Vector3.new(23.2617, 7.11092, 7.39658)},
        {Position = Vector3.new(110.659, -0.300534, 0.121417), Size = Vector3.new(19.7257, 6.3967, 7.11338)},
        {Position = Vector3.new(-42.1242, -0.273326, -0.00555624), Size = Vector3.new(21.8635, 8.37723, 9.4846)},
        {Position = Vector3.new(-71.0841, -0.319326, 0.0678685), Size = Vector3.new(20.5784, 6.43674, 7.11338)},
        {Position = Vector3.new(-68.4466, -0.462632, 0.142659), Size = Vector3.new(23.6954, 6.65353, 7.14951)},
        {Position = Vector3.new(-84.8459, -0.342102, -0.0504356), Size = Vector3.new(22.0242, 6.14825, 9.79216)},
        {Position = Vector3.new(134.893, 0.00533065, 0.0156256), Size = Vector3.new(22.4945, 6.14825, 9.82566)},
        {Position = Vector3.new(-72.709, -0.128225, -0.0942094), Size = Vector3.new(23.6846, 7.15651, 7.27872)},
        {Position = Vector3.new(96.1686, -1.5578, -0.743886), Size = Vector3.new(26.2126, 16.1201, 19.0404)},
        {Position = Vector3.new(-42.2243, 0.253554, 0.00441936), Size = Vector3.new(20.5184, 6.57934, 7.11338)},
        {Position = Vector3.new(-59.8697, -0.485523, -0.117071), Size = Vector3.new(26.3309, 21.728, 7.89131)},
        {Position = Vector3.new(129.096, -0.674035, -0.196203), Size = Vector3.new(26.7367, 21.3361, 10.5124)},
        {Position = Vector3.new(-79.9288, -0.511844, -0.0662911), Size = Vector3.new(23.2736, 6.55925, 7.1202)},
        {Position = Vector3.new(-95.2215, -0.549861, 0.0228603), Size = Vector3.new(22.1901, 6.41581, 9.83191)},
        {Position = Vector3.new(-57.1025, 0.00180999, -0.00804766), Size = Vector3.new(22.5254, 6.148254, 9.83014)},
        {Position = Vector3.new(-76.90776824951172, -0.5372229218482971, -0.125189870595932), Size = Vector3.new(26.597217559814453, 21.482254028320312, 8.077178955078125)},
        {Position = Vector3.new(85.44660186767578, -0.7717099785804749, -0.07532575726509094), Size = Vector3.new(22.565505981445312, 9.310586929321289, 8.437281608581543)}
    }
}

local function destroyKillBricks()
    for i,v in pairs(workspace.Map:GetDescendants()) do
        if v.Name == "ArdorianKillbrick" or v.Name == "KillBrick" or v.Name == "Killbrickeeee" or v.Name == "Lava" then
            v:Destroy()
        end
    end
    for i,v in pairs(workspace.Map["Abyssal Second Layer"]:GetDescendants()) do
        if v.Name == "SunkenAbyss" then
            v:Destroy()
        end
    end
end

local function serverHop()
    if writefile then
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/9530846958/servers/Public?sortOrder=Asc&limit=100"))
        if not savedSettings.visitedServers then
            savedSettings.visitedServers = {}
        end
        if not savedSettings.visitedCreated then
            savedSettings.visitedCreated = os.time() + 300
        end
        if savedSettings.visitedCreated - os.time() <= 0 then
            savedSettings.visitedServers = {}
            savedSettings.visitedCreated = os.time() + 300
        end
        table.insert(savedSettings.visitedServers, game.JobId)
        local JobId = game.JobId
        local serverFound = false
        for i,v in pairs(servers.data) do
            if not table.find(savedSettings.visitedServers, v.id) and v.playing <= v.maxPlayers then
                serverFound = true
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
            end
        end
        if not serverFound then
            savedSettings.visitedServers = {}
            savedSettings.visitedCreated = os.time() + 300
            table.insert(savedSettings.visitedServers, game.JobId)
            for i,v in pairs(servers.data) do
                if not table.find(savedSettings.visitedServers, v.id) and v.playing <= v.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
                end
            end
        end
        savedSettings.Hop = os.time() + 20
        if syn then
            syn.queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/DiabloPro/KartEpsilon/main/Main.lua'))()")
        elseif queue_on_teleport then
            queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/DiabloPro/KartEpsilon/main/Main.lua'))()")
        end
    end
end

local function solveCaptcha()
    local captcha = player.PlayerGui.Captcha
    if captcha then
        local closest = {nil, math.huge}
        for monster, v in pairs(Samples) do
            for i, samples in pairs(v) do
                local distance = math.pow((samples.Size - captcha.MainFrame.Viewport.Union.Size).Magnitude, 2) + (samples.Position - captcha.MainFrame.Viewport.Union.Position).Magnitude
                if distance < closest[2] then
                    closest = {monster, distance}
                end
            end
        end
        for i,v in pairs(captcha.MainFrame.Options:GetChildren()) do
            if v:IsA("TextButton") then
                if v.Text == closest[1] then
                    mousemoveabs(v.AbsolutePosition.X + 100, v.AbsolutePosition.Y + v.AbsoluteSize.Y + 25)
                    mousemoveabs(v.AbsolutePosition.X + 100, v.AbsolutePosition.Y + v.AbsoluteSize.Y + 26)
                    mouse1click()
                end
            end
        end
    end
end

local function tweenPlayer(position)
    local distance = (position - player.Character.HumanoidRootPart.Position).Magnitude
    return TweenService:Create(player.Character.HumanoidRootPart,TweenInfo.new(distance/50, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position)})
end

local crFunction = Instance.new("BindableFunction")
crFunction.OnInvoke = function()
    savedSettings.crFarm = false
    game.Players.LocalPlayer:Kick("Stopped auto farming")
    if UserSettings().GameSettings:InFullScreen() then
        GuiService:ToggleFullscreen()
    end
end

local waypoints = {
    [1] = CFrame.new(5775.49463, 327.880737, 665.69696, -0.999979436, 4.20893329e-08, 0.00641153939, 4.18343902e-08, 1, -3.98970599e-08, -0.00641153939, -3.96280164e-08, -0.999979436),
    [2] = CFrame.new(5742.45312, 327.904907, 664.573181, -0.999717653, 3.13635495e-09, 0.0237618852, 3.45797546e-09, 1, 1.34940592e-08, -0.0237618852, 1.3572417e-08, -0.999717653),
    [3] = CFrame.new(5741.04785, 322.17218, 644.165833, -0.0121795479, -4.52488891e-08, -0.999925852, -1.00811178e-07, 1, -4.4024322e-08, 0.999925852, 1.00267499e-07, -0.0121795479),
    [4] = CFrame.new(5741.01465, 322.199066, 624.666321, 0.00527153211, 4.49041115e-09, -0.999986112, 1.11335732e-08, 1, 4.54916504e-09, 0.999986112, -1.11573994e-08, 0.00527153211),
    [5] = CFrame.new(5741.01465, 322.176331, 624.666321, 0.00527153211, 1.08721121e-08, -0.999986112, 2.69555755e-08, 1, 1.10143619e-08, 0.999986112, -2.70132645e-08, 0.00527153211),
    [6] = CFrame.new(5759.16846, 322.199982, 612.232117, -0.999263287, -9.14102927e-08, 0.0383788794, -9.40315488e-08, 1, -6.6494259e-08, -0.0383788794, -7.00540994e-08, -0.999263287),
}

local function farmCR()
    local invincible = player.Character:FindFirstChild("FF")
    if invincible then
        while player.Character:FindFirstChild("FF") do
            task.wait()
        end
    end

    local solving
    fireclickdetector(workspace["The Eagle"].ClickDetector)
    solving = player.PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "Captcha" then
            if not isrbxactive() then
                game.StarterGui:SetCore("SendNotification",{
                    Title = "Castle Rock Auto Farm",
                    Text = "window is not focused(click anywhere)",
                    Duration = math.huge,
                    Button1 = "Ok"
                })
                while not isrbxactive() do
                    task.wait()
                end
            end
            solveCaptcha()
            task.wait(1)
            if (player.Character.HumanoidRootPart.Position - Vector3.new(4554.6, 519.648, 464.841)).Magnitude <= 10 then
                solving:Disconnect()
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0)
                local underCR = tweenPlayer(Vector3.new(5305, 313, 631))
                underCR:Play()
                underCR.Completed:Wait()
                local nextTo = tweenPlayer(Vector3.new(5780, 393, 640))
                nextTo:Play()
                nextTo.Completed:Wait()
                local tool = false
                for i,v in pairs(spellPrecentages) do
                    if player.Backpack:FindFirstChild(i) then
                        tool = true
                        player.Character.Humanoid:EquipTool(player.Backpack[i])
                    end
                end
                if tool then
                    local skip = false
                    local time = os.clock() + 10
                    keypress(0x47)
                    while player.Character.Stats.Mana.Value < 95 do
                        task.wait()
                        if time - os.clock() <= 0 then
                            skip = true
                            break
                        end
                    end
                    if not skip then
                        keyrelease(0x47)
                        keypress(0x46)
                    end
                end
                player.Character.HumanoidRootPart.CFrame = CFrame.new(5781, 395, 640)
                task.wait()
                player.Character.HumanoidRootPart.CFrame = CFrame.new(5820, 328, 648)
                local looting = RunService.Heartbeat:Connect(function()
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
                for i,v in pairs(waypoints) do
                    player.Character.HumanoidRootPart.CFrame = v
                    task.wait(1)
                end
                game.Players.LocalPlayer:Kick("hopping")
                serverHop()
            else
                while not player.PlayerGui:FindFirstChild("CaptchaLoading") do
                    fireclickdetector(workspace["The Eagle"].ClickDetector)
                    task.wait()
                end
            end
        end
    end)
end

local function startCR(option)
    if option == "Ok" then
        screenGUI:Hide()
        savedSettings.Hop = os.clock()
        savedSettings.crFarm = true
        player.Character.FallDamage.Disabled = true
        float(true)
        noClip()
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0)
        destroyKillBricks()
        game.StarterGui:SetCore("SendNotification",{
            Title = "Castle Rock Auto Farm",
            Text = "Do you want to stop?",
            Duration = math.huge,
            Callback = crFunction,
            Button1 = "Yes"
        })
        if not UserSettings().GameSettings:InFullScreen() then
            GuiService:ToggleFullscreen()
        end
        local mod = false
        for i,v in pairs(game.Players:GetChildren()) do
            if v:IsInGroup(12832629) then
                local role = v:GetRoleInGroup(12832629)
                if role ~= "Member" then
                    mod = true
                    game.Players.LocalPlayer:Kick(role.." found hopping")
                    task.wait(1)
                    serverHop()
                end
            end
        end
        if not mod then
            farmCR()
        end
    end
end

local crstartFunction = Instance.new("BindableFunction")
crstartFunction.OnInvoke = startCR

local crFarm = autoFarmSection:createToggle("Castle Rock", function(boolean)
    if not workspace.Alive:FindFirstChild(player.Name) then
        if not player.PlayerGui:FindFirstChild("StartMenu") then
            while not player.PlayerGui:FindFirstChild("StartMenu") do
                task.wait()
            end
        end
        getconnections(player.PlayerGui.StartMenu.Choices.Play.MouseButton1Down)[1]:Fire()
        while not workspace.Alive:FindFirstChild(player.Name) do
            task.wait()
        end
    end
    if boolean then
        if not savedSettings.crFarm then
            game.StarterGui:SetCore("SendNotification",{
                Title = "Castle Rock Auto Farm",
                Text = "Keep window fullscreen and roblox focused(press ok to continue)",
                Duration = math.huge,
                Callback = crstartFunction,
                Button1 = "Ok",
                Button2 = "No"
            })
        elseif savedSettings.crFarm then
            startCR("Ok")
        end
    else
        if savedSettings.crFarm then
            savedSettings.crFarm = boolean
            game.Players.LocalPlayer:Kick("Stopped auto farming")
            if UserSettings().GameSettings:InFullScreen() then
                GuiService:ToggleFullscreen()
            end
        end
    end
end)
if savedSettings.crFarm then
    if savedSettings.Hop then
        if savedSettings.Hop - os.clock() <= 0 then
            savedSettings.crFarm = false
        else
            crFarm:setToggle(savedSettings.crFarm)
        end
    else
        crFarm:setToggle(savedSettings.crFarm)
    end
end

-- [[ Combat Tab ]]

local combatTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9839226250")
local visualCombatSection = combatTab:createSection("Visuals")
local healthGuis = {}
local manaGuis = {}
local toolGuis = {}
local espGuis = {}

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

local function createEsp(character)
    local espGui = Assets.Esp:Clone()
    getParent(espGui)
    espGuis[#espGuis + 1] = espGui
    espGui.Adornee = character.Torso
    espGui.Frame.Text = character.Name.."["..game.Players:GetPlayerFromCharacter(character).Data.oName.Value.."]"
end

local ESPToggle = visualCombatSection:createToggle("ESP", function(boolean)
    settings.esp = boolean
    if settings.esp then
        for i,v in pairs(workspace.Alive:GetChildren()) do
            if v ~= player.Character then
                local playerFromCharacter = game.Players:GetPlayerFromCharacter(v)
                if playerFromCharacter then
                    createEsp(v)
                end
            end
        end
    else
        for i,v in pairs(espGuis) do
            v:Destroy()
        end
    end
end)

-- [[ Misc Tab ]]

local miscTab = screenGUI:createTab("http://www.roblox.com/asset/?id=9865755786")

-- visual section

local visualMiscSection = miscTab:createSection("Visuals")
local logger
local dragChanged
local dragEnded
local windowFocused

local function makeLogText(player, chat)
    local text = Assets.TextLabel:Clone()
    text.Text = player.Name.."["..player.Data.oName.Value.."]:"..chat
    text.Parent = logger.Menu.Body.Holder
    logger.Menu.Body.Holder.CanvasSize = UDim2.new(0, 0, 0, logger.Menu.Body.Holder.UIListLayout.AbsoluteContentSize.Y + 5)
    if math.abs(logger.Menu.Body.Holder.AbsoluteCanvasSize.Y - logger.Menu.Body.Holder.AbsoluteSize.Y - 30) - math.abs(logger.Menu.Body.Holder.CanvasPosition.Y) <= 5 then
        logger.Menu.Body.Holder.CanvasPosition = Vector2.new(0, logger.Menu.Body.Holder.AbsoluteCanvasSize.Y)
    end
end

local chatLogger = visualMiscSection:createToggle("Chat Logger", function(boolean)
    if boolean then
        logger = Assets.ChatLogger:Clone()
        getParent(logger)

        logger.Menu.TopBar.Drag.MouseButton1Down:Connect(function(x, y)
            local dragStart = Vector3.new(x, y, 0)
            local menuStart = logger.Menu.Position
            dragChanged = UserInputService.InputChanged:Connect(function(inputObject, gameProcessed)
                windowFocused = UserInputService.WindowFocused:Connect(function()
                    dragChanged:Disconnect()
                    dragEnded:Disconnect()
                    windowFocused:Disconnect()
                end)
                if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = inputObject.Position - dragStart
                    logger.Menu.Position = UDim2.new(menuStart.X.Scale, menuStart.X.Offset + delta.X, menuStart.Y.Scale, menuStart.Y.Offset + delta.Y + 35)
                end
            end)
            
            dragEnded = UserInputService.InputEnded:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragChanged:Disconnect()
                    dragEnded:Disconnect()
                    windowFocused:Disconnect()
                end
            end)
        end)

        for i,v in pairs(game.Players:GetChildren()) do
            if v ~= player then
                connections.chatLogger[#connections.chatLogger + 1] = v.Chatted:Connect(function(chat)
                    makeLogText(v, chat)
                end)
            end
        end
    else
        logger:Destroy()
        for i,v in pairs(connections.chatLogger) do
            if v.Connected then
                v:Disconnect()
            end
            connections.chatLogger[i] = nil
        end
    end
end)

local modNotifier = visualMiscSection:createToggle("Mod Notifier", function(boolean)
    savedSettings.modNotifier = boolean
    if boolean then
        for i,v in pairs(game.Players:GetChildren()) do
            if v:IsInGroup(12832629) then
                local role = v:GetRoleInGroup(12832629)
                if role ~= "Member" then
                    game.StarterGui:SetCore("SendNotification",{
                        Title = role.." in server",
                        Text = v.Name,
                        Icon = game.Players:GetUserThumbnailAsync(v.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150),
                        Duration = math.huge,
                        Button1 = "Ok"
                    })
                end
            end
        end
    end
end)

if savedSettings.modNotifier then
    modNotifier:setToggle(savedSettings.modNotifier)
end

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
                currentHover = {}
            end
        end
    elseif inputState == Enum.UserInputState.Begin and not currentHover[1] then
        currentHover = {}
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
    end
    return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("Spectate", spectate, false, Enum.UserInputType.MouseButton1)

game.Workspace.Alive.ChildAdded:Connect(function(child)
    if child ~= player.Character then
        if settings.viewHealthBars then
            createHealthBar(child)
        end
        if settings.viewManaBars then
            createManaBar(child)
        end
        if settings.viewTools then
            createToolViewer(child)
        end
        if settings.esp then
            createEsp(child)
        end
    elseif child == player.Character then
        for i,v in pairs(resetOnDeath) do
            v:setToggle(false)
        end
    end
end)

game.Players.PlayerAdded:Connect(function(player)
    if settings.chatLogger then
        connections.chatLogger[#connections.chatLogger + 1] = player.Chatted:Connect(function(chat)
            makeLogText(player, chat)
        end)
    end
    if not savedSettings.crFarm then
        if savedSettings.modNotifier then
            if player:IsInGroup(12832629) then
                local role = player:GetRoleInGroup(12832629)
                if role ~= "Member" then
                    game.StarterGui:SetCore("SendNotification",{
                        Title = role.." joined server",
                        Text = player.Name,
                        Icon = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150),
                        Duration = math.huge,
                        Button1 = "Ok"
                    })
                end
            end
        end
    else
        local role = player:GetRoleInGroup(12832629)
        if role ~= "Member" then
            game.Players.LocalPlayer:Kick(role.." found hopping")
            task.wait(1)
            serverHop()
        end
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if savedSettings.modNotifier then
        local role = player:GetRoleInGroup(12832629)
        if role ~= "Member" then
            game.StarterGui:SetCore("SendNotification",{
                Title = role.." left server",
                Text = player.Name,
                Icon = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150),
                Duration = math.huge,
                Button1 = "Ok"
            })
        end
    end
end)
