--[[
    BETA MENU - Build a Boat for Treasure
    Tracks: game.Workspace.MainTerrain.Grass
    Open/Close Key: Insert (changeable in Settings)
--]]

local Library = {
    Toggles = {},
    Keybind = "Insert",
    Open = false,
    TweenTime = 0.15
}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Target block
local TargetBlock = workspace
local function getTargetBlock()
    local mainTerrain = workspace:FindFirstChild("MainTerrain")
    if mainTerrain then
        return mainTerrain:FindFirstChild("Grass")
    end
    return nil
end

-- Drawing objects
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BetaMenu"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "BETA MENU"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local tabButtons = Instance.new("Frame")
tabButtons.Size = UDim2.new(1, 0, 0, 35)
tabButtons.Position = UDim2.new(0, 0, 0, 30)
tabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tabButtons.BorderSizePixel = 0
tabButtons.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -65)
contentFrame.Position = UDim2.new(0, 0, 0, 65)
contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Tab containers
local mainTab = Instance.new("ScrollingFrame")
mainTab.Size = UDim2.new(1, 0, 1, 0)
mainTab.BackgroundTransparency = 1
mainTab.BorderSizePixel = 0
mainTab.ScrollBarThickness = 6
mainTab.CanvasSize = UDim2.new(0, 0, 0, 200)
mainTab.Visible = true
mainTab.Parent = contentFrame

local settingsTab = Instance.new("ScrollingFrame")
settingsTab.Size = UDim2.new(1, 0, 1, 0)
settingsTab.BackgroundTransparency = 1
settingsTab.BorderSizePixel = 0
settingsTab.ScrollBarThickness = 6
settingsTab.CanvasSize = UDim2.new(0, 0, 0, 150)
settingsTab.Visible = false
settingsTab.Parent = contentFrame

-- UI Elements
local espEnabled = false
local espLine = nil
local espBox = nil
local targetPart = nil

-- Drawing setup for ESP
local function setupESP()
    if espLine then espLine:Remove() end
    if espBox then espBox:Remove() end
    
    espLine = Drawing.new("Line")
    espLine.Thickness = 2
    espLine.Color = Color3.fromRGB(0, 255, 0)
    espLine.Transparency = 1
    espLine.Visible = false
    
    espBox = Drawing.new("Square")
    espBox.Thickness = 2
    espBox.Color = Color3.fromRGB(0, 255, 0)
    espBox.Filled = false
    espBox.Transparency = 1
    espBox.Visible = false
end

local camera = workspace.CurrentCamera
local function worldToScreen(pos)
    local vec, onScreen = camera:WorldToViewportPoint(pos)
    return Vector2.new(vec.X, vec.Y), onScreen
end

-- Update ESP every frame
RunService.RenderStepped:Connect(function()
    if not espEnabled then
        if espLine then espLine.Visible = false end
        if espBox then espBox.Visible = false end
        return
    end
    
    targetPart = getTargetBlock()
    if not targetPart or not targetPart.Parent then
        if espLine then espLine.Visible = false end
        if espBox then espBox.Visible = false end
        return
    end
    
    local pos = targetPart.Position
    local screenPos, onScreen = worldToScreen(pos)
    
    if onScreen and screenPos then
        local size = 50
        espBox.Size = Vector2.new(size, size)
        espBox.Position = screenPos - Vector2.new(size/2, size/2)
        espBox.Visible = true
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local hrpPos, _ = worldToScreen(hrp.Position)
            if hrpPos then
                espLine.From = hrpPos
                espLine.To = screenPos
                espLine.Visible = true
            end
        end
    else
        espBox.Visible = false
        espLine.Visible = false
    end
end)

-- Create toggle UI
local function createToggle(parent, text, yPos, callback)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
    toggleBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "  " .. text .. "  [OFF]"
    toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleBtn.TextSize = 14
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.Parent = parent
    
    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = "  " .. text .. "  [" .. (state and "ON" or "OFF") .. "]"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60, 90, 60) or Color3.fromRGB(45, 45, 55)
        callback(state)
    end)
    
    return toggleBtn
end

local function createLabel(parent, text, yPos)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.9, 0, 0, 25)
    label.Position = UDim2.new(0.05, 0, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = parent
    return label
end

-- Build Main Tab
local mainY = 10
createLabel(mainTab, "Target: MainTerrain.Grass", mainY); mainY = mainY + 30
createToggle(mainTab, "ESP Trace", mainY, function(state)
    espEnabled = state
    if state then
        setupESP()
    end
end); mainY = mainY + 45
createLabel(mainTab, "Status: " .. (getTargetBlock() and "Found" or "Not Found"), mainY)
mainTab.CanvasSize = UDim2.new(0, 0, 0, mainY + 20)

-- Build Settings Tab
local settingsY = 10
local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(0.9, 0, 0, 35)
keybindBtn.Position = UDim2.new(0.05, 0, 0, settingsY)
keybindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
keybindBtn.BorderSizePixel = 0
keybindBtn.Text = "  Menu Keybind: " .. Library.Keybind
keybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
keybindBtn.TextSize = 14
keybindBtn.TextXAlignment = Enum.TextXAlignment.Left
keybindBtn.Font = Enum.Font.Gotham
keybindBtn.Parent = settingsTab

local waitingForBind = false
keybindBtn.MouseButton1Click:Connect(function()
    waitingForBind = true
    keybindBtn.Text = "  Press any key..."
    task.wait(0.1)
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if waitingForBind then
            local key = input.KeyCode.Name
            Library.Keybind = key
            keybindBtn.Text = "  Menu Keybind: " .. key
            waitingForBind = false
            connection:Disconnect()
        end
    end)
end)

settingsY = settingsY + 45
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.9, 0, 0, 35)
closeBtn.Position = UDim2.new(0.05, 0, 0, settingsY)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "  Close Menu"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.TextSize = 14
closeBtn.TextXAlignment = Enum.TextXAlignment.Left
closeBtn.Font = Enum.Font.Gotham
closeBtn.Parent = settingsTab
closeBtn.MouseButton1Click:Connect(function()
    Library.Open = false
    local tween = TweenService:Create(mainFrame, TweenInfo.new(Library.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
        {BackgroundTransparency = 1, Position = UDim2.new(0.5, -200, 0.5, -150)})
    tween:Play()
    tween.Completed:Connect(function()
        mainFrame.Visible = false
    end)
end)

settingsTab.CanvasSize = UDim2.new(0, 0, 0, settingsY + 50)

-- Tab switching
local tab1Btn = Instance.new("TextButton")
tab1Btn.Size = UDim2.new(0.5, 0, 1, 0)
tab1Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
tab1Btn.BorderSizePixel = 0
tab1Btn.Text = "Main"
tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Btn.Font = Enum.Font.GothamBold
tab1Btn.Parent = tabButtons

local tab2Btn = Instance.new("TextButton")
tab2Btn.Size = UDim2.new(0.5, 0, 1, 0)
tab2Btn.Position = UDim2.new(0.5, 0, 0, 0)
tab2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
tab2Btn.BorderSizePixel = 0
tab2Btn.Text = "Settings"
tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
tab2Btn.Font = Enum.Font.Gotham
tab2Btn.Parent = tabButtons

tab1Btn.MouseButton1Click:Connect(function()
    mainTab.Visible = true
    settingsTab.Visible = false
    tab1Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    tab2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

tab2Btn.MouseButton1Click:Connect(function()
    mainTab.Visible = false
    settingsTab.Visible = true
    tab1Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tab2Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    tab1Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- Smooth open/close animation
local function toggleMenu()
    Library.Open = not Library.Open
    if Library.Open then
        mainFrame.Visible = true
        mainFrame.BackgroundTransparency = 1
        local tween = TweenService:Create(mainFrame, TweenInfo.new(Library.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
            {BackgroundTransparency = 0})
        tween:Play()
    else
        local tween = TweenService:Create(mainFrame, TweenInfo.new(Library.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
            {BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            if not Library.Open then
                mainFrame.Visible = false
            end
        end)
    end
end

-- Keybind listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode.Name == Library.Keybind then
        toggleMenu()
    end
end)

-- Initialize
setupESP()
print("Beta Menu Loaded — Press " .. Library.Keybind .. " to open")
