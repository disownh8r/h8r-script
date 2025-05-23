pcall(function()
    Fluent:Destroy()
end)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()



local version = "v0.5"

local h8rThemePath = "/theme/h8r-theme"

local Window = Fluent:CreateWindow({
    Title = "h8r " .. version,
    SubTitle = "by monte",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 550),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = h8rThemePath,
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when there's no MinimizeKeybind
})

-- Developer Checks

local developerScript = false
local localPlayer = game.Players.LocalPlayer

if localPlayer.Name == "ImTesco" or localPlayer.Name == "dxsown" then
    developerScript = true
end

-- Tab Creation

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "compass"}),
    Movement = Window:AddTab({ Title = "Movement", Icon = "accessibility"}),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye"}),
    Exploits = Window:AddTab({ Title = "Exploits", Icon = "ghost"}),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin"}),
    Freaky = Window:AddTab({ Title = "Freaky", Icon = "skull" }),
    ReAnimations = Window:AddTab({ Title = "Re-Animations", Icon = "person-standing"}),
    Animations = Window:AddTab({ Title = "Animation Packs", Icon = "folder"}),
    Scripts = Window:AddTab({ Title = "Scripts", Icon = "scroll"}),
    Protections = Window:AddTab({ Title = "Protections", Icon = "shield" }),
    Utilities = Window:AddTab({ Title = "Utilities", Icon = "wrench" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Developer Tab

if developerScript then
    Tabs.Developer = Window:AddTab({ Title = "Developer", Icon = "bug" })
end

-- Config Setup Shit

local Options = Fluent.Options
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- Beginnings checks

local inmicup = false
local placeId = game.PlaceId
local placeNames = {
    [15546218972] = "MIC UP 🔊 17+",
    [6884319169] = "MIC UP 🔊"
}
local placeInfo = game:GetService("MarketplaceService"):GetProductInfo(placeId)


local displayName = localPlayer.DisplayName

if placeNames[placeId] then
    inmicup = true
    Fluent:Notify({
        Title = "Welcome " .. displayName .. "!",
        Content = "You are in " .. placeNames[placeId] .. ". All features are enabled.",
        Duration = 10
    })
else
    inmicup = false
    
    Fluent:Notify({
        Title = "Welcome " .. displayName,
        Content = "You are in " .. placeInfo.Name .. ". Some features may be disabled.",
        Duration = 10
    })
end


if not inmicup and not developerScript then
    Window:Dialog({
        Title = "⚠️ Warning",
        Content = "This script is not made for this game. Some features may lead to a ban.\n\nDo you want to continue?",
        Buttons = {
            { 
                Title = "Yes",
                Callback = function()
                    print("Confirmed the dialog.")
                end 
            }, {
                Title = "No",
                Callback = function()
                    Fluent:Destroy()
                end 
            }
        }
    })
end

-- Main Tab Functions


local spinSpeed = 10
local spinning = false

local function startSpinning()
    spinning = true
    task.spawn(function()
        while spinning do
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end
            task.wait(0.005)
        end
    end)
end

local function stopSpinning()
    spinning = false
end

local SpinToggle = Tabs.Main:AddToggle("SpinToggle", {
    Title = "Spin",
    Description = "Spin the player at a set speed",
    Default = false,
    Callback = function(state)
        if state then
            startSpinning()
        else
            stopSpinning()
        end
    end
})

local SpinSpeedSlider = Tabs.Main:AddSlider("SpinSpeedSlider", {
    Title = "Spin Speed",
    Description = "Adjust the speed of spinning",
    Default = 10,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        spinSpeed = Value
    end
})



-- Movement Tab Functions
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local flying = false
local speed = 10

local bodyGyro, bodyVelocity

local control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local lControl = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local currentSpeed = 0
getgenv().Clip = true
local Noclip = nil
local Clip = nil

function enableNoCollision()
	Clip = false
	local function Nocl()
		if Clip == false and game.Players.LocalPlayer.Character ~= nil then
			for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
				if v:IsA('BasePart') and v.CanCollide and v.Name ~= floatName then
					v.CanCollide = false
				end
			end
		end
		wait(0.21) -- basic optimization
	end
	Noclip = game:GetService('RunService').Stepped:Connect(Nocl)
end

function disableNoCollision()
    if Noclip then Noclip:Disconnect() end
    Clip = true
    local character = game.Players.LocalPlayer.Character
    if character then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA('BasePart') and not v.CanCollide then
                v.CanCollide = true
            end
        end
    end
end


local function startFlying()
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.D = 1e3
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.Parent = humanoidRootPart
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = humanoidRootPart
    
    humanoid.PlatformStand = true
    flying = true
end

local function stopFlying()
    flying = false
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
    humanoid.PlatformStand = false
end

mouse.KeyDown:Connect(function(key)
    if key == "f" and FlyToggle.Value then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    elseif key == "w" then
        control.F = speed
    elseif key == "s" then
        control.B = -speed
    elseif key == "a" then
        control.L = -speed
    elseif key == "d" then
        control.R = speed
    elseif key == "e" then
        control.Q = speed * 2
    elseif key == "q" then
        control.E = -speed * 2
    end
end)

mouse.KeyUp:Connect(function(key)
    if key == "w" then
        control.F = 0
    elseif key == "s" then
        control.B = 0
    elseif key == "a" then
        control.L = 0
    elseif key == "d" then
        control.R = 0
    elseif key == "e" then
        control.Q = 0
    elseif key == "q" then
        control.E = 0
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if flying then
        local character = player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        if control.L + control.R ~= 0 or control.F + control.B ~= 0 or control.Q + control.E ~= 0 then
            currentSpeed = speed
        elseif not (control.L + control.R ~= 0 or control.F + control.B ~= 0 or control.Q + control.E ~= 0) and currentSpeed ~= 0 then
            currentSpeed = 0
        end
        
        if (control.L + control.R) ~= 0 or (control.F + control.B) ~= 0 or (control.Q + control.E) ~= 0 then
            bodyVelocity.Velocity = ((workspace.CurrentCamera.CFrame.LookVector * (control.F + control.B)) + ((workspace.CurrentCamera.CFrame * CFrame.new(control.L + control.R, (control.F + control.B + control.Q + control.E) * 0.2, 0).p) - workspace.CurrentCamera.CFrame.p)) * currentSpeed
            lControl = {F = control.F, B = control.B, L = control.L, R = control.R}
        elseif (control.L + control.R) == 0 and (control.F + control.B) == 0 and (control.Q + control.E) == 0 and currentSpeed ~= 0 then
            bodyVelocity.Velocity = ((workspace.CurrentCamera.CFrame.LookVector * (lControl.F + lControl.B)) + ((workspace.CurrentCamera.CFrame * CFrame.new(lControl.L + lControl.R, (lControl.F + lControl.B + control.Q + control.E) * 0.2, 0).p) - workspace.CurrentCamera.CFrame.p)) * currentSpeed
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end
end)

local FlyToggle = Tabs.Movement:AddToggle("FlyToggle", 
{
    Title = "Fly", 
    Description = "Lets you fly",
    Default = false,
    Callback = function(state)
        if state then
            startFlying()
        else
            stopFlying()
        end
    end 
})

local FlySpeedSlider = Tabs.Movement:AddSlider("FlySpeedSlider", {
    Title = "Fly Speed",
    Description = "Adjust the speed of flying",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        speed = Value
        if flying then
            bodyVelocity.Velocity = bodyVelocity.Velocity.unit * speed
        end
    end
})



local NoCollisionToggle = Tabs.Movement:AddToggle("NoCollisionToggle", 
{
    Title = "No Collision", 
    Description = "Lets you go through objects",
    Default = false,
    Callback = function(state)
        if state then
            enableNoCollision()
        else
            disableNoCollision()
        end
    end 
})


local shiftSpeedEnabled = false
local defaultWalkSpeed = 16
local shiftWalkSpeed = 50

local ShiftSpeedToggle = Tabs.Movement:AddToggle("ShiftSpeedToggle", 
{
    Title = "Shift Speed", 
    Description = "Hold shift to increase speed",
    Default = false,
    Callback = function(state)
        shiftSpeedEnabled = state
        if state then
            task.spawn(function()
                while shiftSpeedEnabled do
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                        player.Character.Humanoid.WalkSpeed = shiftWalkSpeed
                    else
                        player.Character.Humanoid.WalkSpeed = defaultWalkSpeed
                    end
                    task.wait(0.1)
                end
                player.Character.Humanoid.WalkSpeed = defaultWalkSpeed
            end)
        else
            player.Character.Humanoid.WalkSpeed = defaultWalkSpeed
        end
    end 
})

local SprintSpeedSlider = Tabs.Movement:AddSlider("SprintSpeedSlider", {
    Title = "Sprint Speed",
    Description = "Adjust the speed of sprinting",
    Default = 50,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        shiftWalkSpeed = Value
        if shiftSpeedEnabled and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
            player.Character.Humanoid.WalkSpeed = shiftWalkSpeed
        end
    end
})


-- Visuals Tab Functions

local ESPHandler = {
    Enabled = false,
    PlayerData = {},
}

local function createNameESP(player, font, baseTextSize, boneOffset)

    if player.Character.Head:FindFirstChild("NameESP") then
        return
    end

    local BillboardGui = Instance.new("BillboardGui")
    local TextLabel = Instance.new("TextLabel")

    BillboardGui.Name = "NameESP"
    BillboardGui.Adornee = player.Character.Head
    BillboardGui.Size = UDim2.new(0, 100, 0, 40)
    BillboardGui.StudsOffset = boneOffset
    BillboardGui.AlwaysOnTop = true

    TextLabel.Parent = BillboardGui
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = player.DisplayName
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.TextStrokeTransparency = 0.5
    TextLabel.TextSize = baseTextSize
    TextLabel.Font = font

    BillboardGui.Parent = player.Character.Head

    local renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("Head") then
            local camera = game.Workspace.CurrentCamera
            local distance = (camera.CFrame.Position - player.Character.Head.Position).Magnitude
            if distance < 50 then
                TextLabel.TextSize = math.clamp(baseTextSize + (25 - baseTextSize) * (1 - distance / 50), baseTextSize, 25)
            else
                TextLabel.TextSize = baseTextSize
            end
        end
    end)

    ESPHandler.PlayerData[player] = {
        BillboardGui = BillboardGui,
        RenderConnection = renderConnection,
    }
end

local function disableDefaultName(player)
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
end

local function removeNameESP(player)
    local data = ESPHandler.PlayerData[player]
    if data then

        if data.BillboardGui and data.BillboardGui.Parent then
            data.BillboardGui:Destroy()
        end

        if data.RenderConnection then
            data.RenderConnection:Disconnect()
        end

        ESPHandler.PlayerData[player] = nil
    end

    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
    end
end
local function applyESPToAllPlayers(font, baseTextSize, boneOffset)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            createNameESP(player, font, baseTextSize, boneOffset)
            disableDefaultName(player)
        end
    end
end

function ESPHandler:Enable(font, baseTextSize, boneOffset)
    if self.Enabled then return end
    self.Enabled = true

    applyESPToAllPlayers(font, baseTextSize, boneOffset)

    self.PlayerAddedConnection = game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            if self.Enabled and character:FindFirstChild("Head") then
                createNameESP(player, font, baseTextSize, boneOffset)
                disableDefaultName(player)
            end
        end)

        if player.Character and player.Character:FindFirstChild("Head") then
            createNameESP(player, font, baseTextSize, boneOffset)
            disableDefaultName(player)
        end
    end)

    self.ScanLoop = spawn(function()
        while self.Enabled do
            applyESPToAllPlayers(font, baseTextSize, boneOffset)
            wait(1)
        end
    end)
end

function ESPHandler:Disable()
    if not self.Enabled then return end
    self.Enabled = false

    for _, player in pairs(game.Players:GetPlayers()) do
        removeNameESP(player)
    end

    if self.PlayerAddedConnection then
        self.PlayerAddedConnection:Disconnect()
        self.PlayerAddedConnection = nil
    end

    if self.ScanLoop then
        self.ScanLoop = nil
    end
end

local section = Tabs.Visuals:AddSection("Name Settings")

local fonts = {
    "Arial",
    "GothamBold",
    "JosefinSans",
    "Bodoni",
    "SourceSans",
    "Nunito"
}

local selectedFont = Enum.Font.Arial
local baseTextSize = 12
local boneOffset = Vector3.new(0, 2, 0)

local nameESP = Tabs.Visuals:AddToggle("nameESP", {
    Title = "Overhaul Names",
    Description = "Renders names above players",
    Default = true,
    Callback = function(state)
        if state then
            ESPHandler:Enable(selectedFont, baseTextSize, boneOffset)
        else
            ESPHandler:Disable()
        end
    end
})

local bones = {"Head", "Chest", "Foot"}

local boneSelection = Tabs.Visuals:AddDropdown("BoneSelection", {
    Title = "Text Position",
    Values = bones,
    Default = 1,
    Multi = false,
    Callback = function(value)
        selectedBone = value
        if selectedBone == "Head" then
            boneOffset = Vector3.new(0, 2, 0)
        elseif selectedBone == "Chest" then
            boneOffset = Vector3.new(0, -1, 0)
        elseif selectedBone == "Foot" then
            boneOffset = Vector3.new(0, -5, 0)
        end
        print(selectedBone, boneOffset)
        for player, data in pairs(ESPHandler.PlayerData) do
            if data.BillboardGui then
                if selectedBone == "Head" then
                    data.BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
                elseif selectedBone == "Chest" then
                    data.BillboardGui.StudsOffset = Vector3.new(0, -1, 0)
                elseif selectedBone == "Foot" then
                    data.BillboardGui.StudsOffset = Vector3.new(0, -5, 0)
                end
            end
        end
    end
})

local TextSizeSlider = Tabs.Visuals:AddSlider("TextSizeSlider", {
    Title = "Text Size",
    Description = "Adjust the base size of the text",
    Default = 12,
    Min = 1,
    Max = 32,
    Rounding = 0,
    Callback = function(Value)
        baseTextSize = Value
        if ESPHandler.Enabled then
            ESPHandler:Disable()
            ESPHandler:Enable(selectedFont, baseTextSize, boneOffset)
        end
    end
})

local fontDropdown = Tabs.Visuals:AddDropdown("FontDropdown", {
    Title = "Select Font",
    Values = fonts,
    Default = 1,
    Multi = false,
    Callback = function(value)
        selectedFont = Enum.Font[value]
        if ESPHandler.Enabled then
            ESPHandler:Disable()
            ESPHandler:Enable(selectedFont, baseTextSize, boneOffset)
        end
    end
})







-- Exploits Tab Functions


local Players = game:GetService("Players")

local function printAllPlayerUsernames()
    local playerList = Players:GetPlayers()
    
    for _, player in ipairs(playerList) do
        print(player.Name)
    end
end


local baseplate

local function createBaseplate()
    baseplate = Instance.new("Part")
    baseplate.Size = Vector3.new(1024, 1, 1024)
    baseplate.Position = Vector3.new(0, -0.505, 0)
    baseplate.Anchored = true
    baseplate.Name = "Baseplate"
    baseplate.Material = Enum.Material.Plastic
    baseplate.Color = Color3.fromRGB(114, 229, 114)
    baseplate.Parent = workspace

    local texture = Instance.new("Texture")
    texture.Texture = "rbxassetid://10442413242"
    texture.StudsPerTileU = 10
    texture.StudsPerTileV = 10
    texture.Face = Enum.NormalId.Top
    texture.Color3 = Color3.fromRGB(114, 229, 114)
    texture.Parent = baseplate
end

local function removeBaseplate()
    if baseplate then
        baseplate:Destroy()
        baseplate = nil
    end
end


local BaseplateToggle = Tabs.Exploits:AddToggle("BaseplateToggle", {
    Title = "Create Baseplate",
    Description = "Toggle to create or remove a baseplate",
    Default = false,
    Callback = function(state)
        if state then
            createBaseplate()
        else
            removeBaseplate()
        end
    end
})

Tabs.Exploits:AddButton({
    Title = "Walk on Walls",
    Description = "Enable walking on walls. Reset to disable.",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
    end
})

-- Teleports Tab Functions

if inmicup then

    local TpDropdown = Tabs.Teleports:AddDropdown("TpDropdown", {
        Title = "Locations",
        Values = {"Spawn 1", "Spawn 2", "Spawn 3", "Circle Booth", "Avatar-UI", "Private Room (Inside)", "Bathrooms", "Chill Spot", "Picnic", "Middle Room (Tent)", "Tower (Float Up Part)", "Tower (Top)", "Tower (Highest Part)", "Donut Shop", "Above Relaxing Room", "Note Board"},
        Multi = false,
        Default = 1
    })

    local locations = {
        ["Spawn 1"] = CFrame.new(-0.000122070313, 4.99999857, 0.000122070313),
        ["Spawn 2"] = CFrame.new(166.64, 4.99999857, 195.381),
        ["Spawn 3"] = CFrame.new(143.6, 4.99999857, -33.09),
        ["Circle Booth"] = CFrame.new(26.7397423, 7.81395245, 86.7164536),
        ["Avatar-UI"] = CFrame.new(-129, 4.9, 82),
        ["Private Room (Inside)"] = CFrame.new(4220.82275, 2.76511836, 60.7681046),
        ["Bathrooms"] = CFrame.new(-72.3955917, 5.09832525, 93.0914459),
        ["Chill Spot"] = CFrame.new(228.970184, 5.75081444, -21.5613441),
        ["Picnic"] = CFrame.new(85.846756, 3.61196709, -29.8345909), -- Seat 1
        ["Middle Room (Tent)"] = CFrame.new(70.9464493, 5.62692404, 24.2968006),
        ["Tower (Float Up Part)"] = CFrame.new(61.3288841, 72.0192184, 215.731613),
        ["Tower (Top)"] = CFrame.new(63.2298126, 284.407227, 193.529007),
        ["Tower (Highest Part)"] = CFrame.new(58.0468788, 313.312622, 225.215027),
        ["Donut Shop"] = CFrame.new(-80.8301239, 3.1662631, -82.6656799),
        ["Above Relaxing Room"] = CFrame.new(-97.4412308, 24.4840164, 121.394676),
        ["Note Board"] = CFrame.new(58.6107864, 4.99999857, 245.690369)
    }

    Tabs.Teleports:AddButton({
        Title = "Teleport",
        Description = "Teleport to the selected location",
        Callback = function()
            local selectedLocation = TpDropdown.Value
            local targetCFrame = locations[selectedLocation]
            if targetCFrame then
                local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
                HumanoidRootPart.CFrame = targetCFrame
            else
                warn("Invalid location selected")
            end
        end
    })
end


local TpToPlayerInput = Tabs.Teleports:AddInput("TpToPlayerInput", {
    Title = "Teleport to Player",
    Description = "Enter the player to teleport to",
    Default = "",
    Placeholder = "Player Name",
    Numeric = false, -- Only allows text input
    Finished = true, -- Only calls callback when you press enter
    Callback = function(displayName)
        local targetPlayer = nil
        local lowerDisplayName = displayName:lower()
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.DisplayName:lower() == lowerDisplayName then
                targetPlayer = player
                break
            end
        end
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
            HumanoidRootPart.CFrame = targetCFrame
            Fluent:Notify({
                Title = "Notification",
                Content = "Teleported to " .. displayName,
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "Notification",
                Content = "Failed to find player: " .. displayName,
                Duration = 5
            })
            warn("Player not found or invalid target.")
        end
    end
})

-- Freaky Tab Functions


getgenv().bangSpeed = 1

local function findPlayerByName(name)
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.DisplayName:lower() == name:lower() then
            return player
        end
    end
    return nil
end

local function bang_plr_bypass(target)
    if getgenv().bangScriptLoaded then
        Fluent:Notify({
            Title = "Failed",
            Content = "Already loaded bang bypass!",
            Duration = 5
        })
        return
    end

    getgenv().bangScriptLoaded = true
    getgenv().enabled = true
    getgenv().unload = false

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    local bangAnim = Instance.new("Animation")
    bangAnim.AnimationId = "rbxassetid://5918726674"
    local bang = Humanoid:LoadAnimation(bangAnim)
    bang.Looped = true
    bang:Play(0.1, 1, 1)

    getgenv().bangAnimation = bang

    getgenv().bangLoop = RunService.Stepped:Connect(function()
        if getgenv().unload then
            bang:Stop()
            bangAnim:Destroy()
            getgenv().bangScriptLoaded = false
            return
        end

        if bang.Speed ~= getgenv().bangSpeed then
            bang:AdjustSpeed(getgenv().bangSpeed)
        end

        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.1)
        end
    end)

    getgenv().bangDied = Humanoid.Died:Connect(function()
        bang:Stop()
        bangAnim:Destroy()
        getgenv().bangScriptLoaded = false
    end)
end

local function bang_plr_bypass_off()
    if getgenv().bangLoop then getgenv().bangLoop:Disconnect() end
    if getgenv().bangDied then getgenv().bangDied:Disconnect() end

    if getgenv().bangAnimation then
        getgenv().bangAnimation:Stop()
        getgenv().bangAnimation:Destroy()
        getgenv().bangAnimation = nil
    end

    getgenv().bangScriptLoaded = false
    getgenv().unload = nil
    getgenv().enabled = false
end


local BangPlayerInput = Tabs.Freaky:AddInput("BangPlayerInput", {
    Title = "Bang Player",
    Description = "Enter the player to bang",
    Default = "",
    Placeholder = "Player Name",
    Numeric = false,
    Finished = true,
    Callback = function(displayName)
        local targetPlayer = nil
        local lowerDisplayName = displayName:lower()
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.DisplayName:lower() == lowerDisplayName then
                targetPlayer = player
                break
            end
        end
        if targetPlayer then
            bang_plr_bypass(targetPlayer)
            Fluent:Notify({
                Title = "Notification",
                Content = "Banging player: " .. displayName,
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "Notification",
                Content = "Player not found: " .. displayName,
                Duration = 5
            })
            warn("Player not found.")
        end
    end
})

local BangPlayerSpeedSlider = Tabs.Freaky:AddSlider("BangPlayerSpeedSlider", {
    Title = "Bang Player Speed",
    Description = "Adjust the speed of banging the player",
    Default = 1,
    Min = 0.1,
    Max = 20,
    Rounding = 1,
    Callback = function(Value)
        getgenv().bangSpeed = Value
    end
})

Tabs.Freaky:AddButton({
    Title = "Unbang",
    Description = "Stop banging the player",
    Callback = function()
        bang_plr_bypass_off()
        Fluent:Notify({
            Title = "Notification",
            Content = "Stopped banging the player",
            Duration = 5
        })
    end
})

-- Reanimation Stuff

-- Animation Packs

local animationPacks = {
    ["Zombie Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=616158929",
        idle2 = "http://www.roblox.com/asset/?id=616160636",
        walk = "http://www.roblox.com/asset/?id=616168032",
        run = "http://www.roblox.com/asset/?id=616163682",
        jump = "http://www.roblox.com/asset/?id=616161997",
        climb = "http://www.roblox.com/asset/?id=616156119",
        fall = "http://www.roblox.com/asset/?id=616157476"
    },
    ["No Boundaries Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=18747067405",
        idle2 = "http://www.roblox.com/asset/?id=18747063918",
        walk = "http://www.roblox.com/asset/?id=18747074203",
        run = "http://www.roblox.com/asset/?id=18747070484",
        jump = "http://www.roblox.com/asset/?id=18747069148",
        climb = "http://www.roblox.com/asset/?id=18747060903",
        fall = "http://www.roblox.com/asset/?id=18747062535"
    },
    ["Robot Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=10921248039",
        idle2 = "http://www.roblox.com/asset/?id=10921248831",
        walk = "http://www.roblox.com/asset/?id=10921255446",
        run = "http://www.roblox.com/asset/?id=10921250460",
        jump = "http://www.roblox.com/asset/?id=10921252123",
        climb = "http://www.roblox.com/asset/?id=10921247141",
        fall = "http://www.roblox.com/asset/?id=10921251156"
    },
    ["Hero Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=616111295",
        idle2 = "http://www.roblox.com/asset/?id=616113536",
        walk = "http://www.roblox.com/asset/?id=616122287",
        run = "http://www.roblox.com/asset/?id=616117076",
        jump = "http://www.roblox.com/asset/?id=616115533",
        climb = "http://www.roblox.com/asset/?id=616104706",
        fall = "http://www.roblox.com/asset/?id=616108001"
    },
    ["Vampire Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=1083445855",
        idle2 = "http://www.roblox.com/asset/?id=1083450166",
        walk = "http://www.roblox.com/asset/?id=1083473930",
        run = "http://www.roblox.com/asset/?id=1083462077",
        jump = "http://www.roblox.com/asset/?id=1083455352",
        climb = "http://www.roblox.com/asset/?id=1083439238",
        fall = "http://www.roblox.com/asset/?id=1083443587"
    },
    ["Mage Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=707742142",
        idle2 = "http://www.roblox.com/asset/?id=707855907",
        walk = "http://www.roblox.com/asset/?id=707897309",
        run = "http://www.roblox.com/asset/?id=707861613",
        jump = "http://www.roblox.com/asset/?id=707853694",
        climb = "http://www.roblox.com/asset/?id=707826056",
        fall = "http://www.roblox.com/asset/?id=707829716"
    },
    ["Ghost Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=616006778",
        idle2 = "http://www.roblox.com/asset/?id=616008087",
        walk = "http://www.roblox.com/asset/?id=616010382",
        run = "http://www.roblox.com/asset/?id=616013216",
        jump = "http://www.roblox.com/asset/?id=616008936",
        climb = "http://www.roblox.com/asset/?id=616003713",
        fall = "http://www.roblox.com/asset/?id=616005863"
    },
    ["Elder Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=845397899",
        idle2 = "http://www.roblox.com/asset/?id=845400520",
        walk = "http://www.roblox.com/asset/?id=845403856",
        run = "http://www.roblox.com/asset/?id=845386501",
        jump = "http://www.roblox.com/asset/?id=845398858",
        climb = "http://www.roblox.com/asset/?id=845392038",
        fall = "http://www.roblox.com/asset/?id=845396048"
    },
    ["Levitation Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=616006778",
        idle2 = "http://www.roblox.com/asset/?id=616008087",
        walk = "http://www.roblox.com/asset/?id=616013216",
        run = "http://www.roblox.com/asset/?id=616010382",
        jump = "http://www.roblox.com/asset/?id=616008936",
        climb = "http://www.roblox.com/asset/?id=616003713",
        fall = "http://www.roblox.com/asset/?id=616005863"
    },
    ["Astronaut Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=891621366",
        idle2 = "http://www.roblox.com/asset/?id=891633237",
        walk = "http://www.roblox.com/asset/?id=891667138",
        run = "http://www.roblox.com/asset/?id=891636393",
        jump = "http://www.roblox.com/asset/?id=891627522",
        climb = "http://www.roblox.com/asset/?id=891609353",
        fall = "http://www.roblox.com/asset/?id=891617961"
    },
    ["Ninja Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=656117400",
        idle2 = "http://www.roblox.com/asset/?id=656118341",
        walk = "http://www.roblox.com/asset/?id=656121766",
        run = "http://www.roblox.com/asset/?id=656118852",
        jump = "http://www.roblox.com/asset/?id=656117878",
        climb = "http://www.roblox.com/asset/?id=656114359",
        fall = "http://www.roblox.com/asset/?id=656115606"
    },
    ["Werewolf Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=1083195517",
        idle2 = "http://www.roblox.com/asset/?id=1083214717",
        walk = "http://www.roblox.com/asset/?id=1083178339",
        run = "http://www.roblox.com/asset/?id=1083216690",
        jump = "http://www.roblox.com/asset/?id=1083218792",
        climb = "http://www.roblox.com/asset/?id=1083182000",
        fall = "http://www.roblox.com/asset/?id=1083189019"
    },
    ["Cartoon Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=742637544",
        idle2 = "http://www.roblox.com/asset/?id=742638445",
        walk = "http://www.roblox.com/asset/?id=742640026",
        run = "http://www.roblox.com/asset/?id=742638842",
        jump = "http://www.roblox.com/asset/?id=742637942",
        climb = "http://www.roblox.com/asset/?id=742636889",
        fall = "http://www.roblox.com/asset/?id=742637151"
    },
    ["Pirate Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=750781874",
        idle2 = "http://www.roblox.com/asset/?id=750782770",
        walk = "http://www.roblox.com/asset/?id=750785693",
        run = "http://www.roblox.com/asset/?id=750783738",
        jump = "http://www.roblox.com/asset/?id=750782230",
        climb = "http://www.roblox.com/asset/?id=750779899",
        fall = "http://www.roblox.com/asset/?id=750780242"
    },
    ["Sneaky Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=1132473842",
        idle2 = "http://www.roblox.com/asset/?id=1132477671",
        walk = "http://www.roblox.com/asset/?id=1132510133",
        run = "http://www.roblox.com/asset/?id=1132494274",
        jump = "http://www.roblox.com/asset/?id=1132489853",
        climb = "http://www.roblox.com/asset/?id=1132461372",
        fall = "http://www.roblox.com/asset/?id=1132469004"
    },
    ["Toy Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=782841498",
        idle2 = "http://www.roblox.com/asset/?id=782845736",
        walk = "http://www.roblox.com/asset/?id=782843345",
        run = "http://www.roblox.com/asset/?id=782842708",
        jump = "http://www.roblox.com/asset/?id=782847020",
        climb = "http://www.roblox.com/asset/?id=782843869",
        fall = "http://www.roblox.com/asset/?id=782846423"
    },
    ["Knight Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=657595757",
        idle2 = "http://www.roblox.com/asset/?id=657568135",
        walk = "http://www.roblox.com/asset/?id=657552124",
        run = "http://www.roblox.com/asset/?id=657564596",
        jump = "http://www.roblox.com/asset/?id=658409194",
        climb = "http://www.roblox.com/asset/?id=658360781",
        fall = "http://www.roblox.com/asset/?id=657600338"
    },
    ["Confident Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=1069977950",
        idle2 = "http://www.roblox.com/asset/?id=1069987858",
        walk = "http://www.roblox.com/asset/?id=1070017263",
        run = "http://www.roblox.com/asset/?id=1070001516",
        jump = "http://www.roblox.com/asset/?id=1069984524",
        climb = "http://www.roblox.com/asset/?id=1069946257",
        fall = "http://www.roblox.com/asset/?id=1069973677"
    },
    ["Popstar Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=1212900985",
        idle2 = "http://www.roblox.com/asset/?id=1212900985",
        walk = "http://www.roblox.com/asset/?id=1212980338",
        run = "http://www.roblox.com/asset/?id=1212980348",
        jump = "http://www.roblox.com/asset/?id=1212954642",
        climb = "http://www.roblox.com/asset/?id=1213044953",
        fall = "http://www.roblox.com/asset/?id=1212900995"
    },
    ["Princess Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=941003647",
        idle2 = "http://www.roblox.com/asset/?id=941013098",
        walk = "http://www.roblox.com/asset/?id=941028902",
        run = "http://www.roblox.com/asset/?id=941015281",
        jump = "http://www.roblox.com/asset/?id=941008832",
        climb = "http://www.roblox.com/asset/?id=940996062",
        fall = "http://www.roblox.com/asset/?id=941000007"
    },
    ["Cowboy Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=1014390418",
        idle2 = "http://www.roblox.com/asset/?id=1014398616",
        walk = "http://www.roblox.com/asset/?id=1014421541",
        run = "http://www.roblox.com/asset/?id=1014401683",
        jump = "http://www.roblox.com/asset/?id=1014394726",
        climb = "http://www.roblox.com/asset/?id=1014380606",
        fall = "http://www.roblox.com/asset/?id=1014384571"
    },
    ["Patrol Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=1149612882",
        idle2 = "http://www.roblox.com/asset/?id=1150842221",
        walk = "http://www.roblox.com/asset/?id=1151231493",
        run = "http://www.roblox.com/asset/?id=1150967949",
        jump = "http://www.roblox.com/asset/?id=1150944216",
        climb = "http://www.roblox.com/asset/?id=1148811837",
        fall = "http://www.roblox.com/asset/?id=1148863382"
    },
    ["Weird Zombie Animation Package"] = {
        idle1 = "http://www.roblox.com/asset/?id=3489171152",
        idle2 = "http://www.roblox.com/asset/?id=3489171152",
        walk = "http://www.roblox.com/asset/?id=3489174223",
        run = "http://www.roblox.com/asset/?id=3489173414",
        jump = "http://www.roblox.com/asset/?id=616161997",
        climb = "http://www.roblox.com/asset/?id=616156119",
        fall = "http://www.roblox.com/asset/?id=616157476"
    }

}

local function applyAnimationPack(pack)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local Animate = character:WaitForChild("Animate")

    if not Animate then return end

    Animate.Disabled = true
    task.wait()
    Animate.Disabled = false

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end

    Animate.idle.Animation1.AnimationId = pack.idle1
    Animate.idle.Animation2.AnimationId = pack.idle2
    Animate.walk.WalkAnim.AnimationId = pack.walk
    Animate.run.RunAnim.AnimationId = pack.run
    Animate.jump.JumpAnim.AnimationId = pack.jump
    Animate.climb.ClimbAnim.AnimationId = pack.climb
    Animate.fall.FallAnim.AnimationId = pack.fall
    task.wait()
    Animate.Disabled = false
end

for title, pack in pairs(animationPacks) do
    Tabs.Animations:AddButton({
        Title = title,
        Description = "Apply the " .. title,
        Callback = function()
            applyAnimationPack(pack)
        end
    })
end

-- Scripts Tab Functions

Tabs.Scripts:AddButton({
    Title = "Draw In Chat",
    Description = "Credit: AK Admin",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/disownh8r/h8r-script/master/scripts/chatdrawscript"))()
    end
})

Tabs.Scripts:AddButton({
    Title = "Emote GUI",
    Description = "Credit: Gi#7331",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/disownh8r/h8r-script/master/scripts/emotescript"))()
    end
})


Tabs.Scripts:AddButton({
    Title = "Infinite Yield",
    Description = "Credit: EdgeIY",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})


Tabs.Scripts:AddButton({
    Title = "Hug Script",
    Description = "Launch the Hug Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JSFKGBASDJKHIOAFHDGHIUODSGBJKLFGDKSB/fe/refs/heads/main/FEHUGG"))()
    end
})


-- Protections Tab Functions

local vcSection = Tabs.Protections:AddSection("Voice Chat")

local vc_service = game:GetService("VoiceChatService")
local enabled_vc = vc_service:IsVoiceEnabledForUserIdAsync(game.Players.LocalPlayer.UserId)
local vc_inter = game:GetService("VoiceChatInternal")
local retryCooldown = 3

local VcBanProtectionToggle = Tabs.Protections:AddToggle("VcBanProtectionToggle", 
{
    Title = "VC Ban Protection", 
    Description = "⚠️ Warning. While this will unban you from voice-chat, if you say crazy shit and get reported you will get account banned.",
    Default = true,
    Callback = function(state)
        if state then
            if getgenv().voiceChat_Check then
                warn("Voice Chat already initialized.")
            else
                getgenv().voiceChat_Check = true
                local reconnecting = false
                local retryCooldown = 3
                local function onVoiceChatStateChanged(oldState, newState)
                    if newState == Enum.VoiceChatState.Ended and not reconnecting then
                        reconnecting = true
                        Fluent:Notify({
                            Title = "Notification",
                            Content = "VC Ban Detected",
                            Duration = 5 -- Set to nil to make the notification not disappear
                        })
                        task.spawn(function()
                            wait(retryCooldown)
                            local success, err = pcall(function()
                                vc_service:joinVoice()
                            end)
                            if success then
                                Fluent:Notify({
                                    Title = "Notification",
                                    Content = "VC Successfully Unbanned",
                                    Duration = 5 -- Set to nil to make the notification not disappear
                                })
                                reconnecting = false
                            else
                                warn("Error while rejoining voice chat:", err)
                                reconnecting = false
                            end
                        end)
                    end
                end

                vc_inter.StateChanged:Connect(onVoiceChatStateChanged)
            end
        else
            getgenv().voiceChat_Check = false
            -- Add any additional cleanup code here if necessary
        end
    end 
})

if enabled_vc then
    game:GetService("VoiceChatService"):joinVoice() 
    Fluent:Notify({
        Title = "Notification",
        Content = "Voice Chat has been successfully initialized.",
        Duration = 5 -- Set to nil to make the notification not disappear
    })
end

local RetryCooldownSlider = Tabs.Protections:AddSlider("RetryCooldownSlider", {
    Title = "Reconnect Cooldown",   
    Description = "Adjust the cooldown time for reconnecting to VC.",
    Default = 3,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        retryCooldown = Value
    end
})

Tabs.Protections:AddButton({
    Title = "Force VC Unban",
    Description = "Force reconnect to voice chat if you are banned",
    Callback = function()
        game:GetService("VoiceChatService"):joinVoice() 
    end
})



-- Utilities Tab Functions

local MiddleClickAddFriendsEnabled = false

local MiddleClickAddFriendsToggle = Tabs.Utilities:AddToggle("MiddleClickAddFriendsToggle", {
    Title = "Middle Click Add Friends",
    Description = "Enable Middle-click to send friend requests",
    Default = true,
    Callback = function(state)
        MiddleClickAddFriendsEnabled = state
    end
})

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local function retryCall(f, ...)
    while not pcall(f, ...) do
        RunService.Heartbeat:Wait()
    end
end

local function getPlayerUnderMouse()
    local MousePos = UserInputService:GetMouseLocation()
    local Camera = workspace.CurrentCamera

    local UnitRay = Camera:ScreenPointToRay(MousePos.X, MousePos.Y)
    local RaycastResult = workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000)

    if RaycastResult and RaycastResult.Instance then
        local hitPart = RaycastResult.Instance
        local character = hitPart:FindFirstAncestorOfClass("Model")
        if character and Players:GetPlayerFromCharacter(character) then
            return character, Players:GetPlayerFromCharacter(character)
        end
    end

    return nil, nil
end

-- Maybe will add cham later but kinda pointless
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not MiddleClickAddFriendsEnabled then return end

    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        local character, player = getPlayerUnderMouse()

        if character and player then
            retryCall(function()
                StarterGui:SetCore("PromptSendFriendRequest", player)
            end)
        end
    end
end)

-- Settings Tab Functions

-- Developer Tab Options

Tabs.Developer:AddButton({
    Title = "Print Player Coords",
    Description = "Prints the current coordinates of the player",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                print("Current Player Coordinates: ", humanoidRootPart.Position)
            else
                warn("HumanoidRootPart not found.")
            end
        else
            warn("Character not found.")
        end
    end
})

Tabs.Developer:AddButton({
    Title = "Rejoin Server",
    Description = "Rejoins the current server",
    Callback = function()
        local ts = game:GetService("TeleportService")
        local p = game:GetService("Players").LocalPlayer
        ts:Teleport(game.PlaceId, p)
    end
})
