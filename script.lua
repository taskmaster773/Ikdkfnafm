--[[
    BETA MENU - Build a Boat for Treasure
    Tracks: game.Workspace.MainTerrain.Grass
    Open/Close Key: Insert (changeable in Settings)
    Compatible with: Matcha External & most executors
--]]

-- Matcha External compatibility wrapper
local MatchaFix = {}
do
    -- Some executors like Matcha have specific requirements
    local success, result = pcall(function()
        -- Check if we're in Matcha's environment
        return getgenv and getgenv().MatchaVersion
    end)
    
    MatchaFix.IsMatcha = success and result
    MatchaFix.UsingMatcha = MatchaFix.IsMatcha or (game:GetService("CoreGui"):FindFirstChild("MatchaUI") ~= nil)
    
    -- Matcha sometimes needs a delay after injection
    if MatchaFix.UsingMatcha then
        task.wait(0.5)
    end
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Configuration
local Config = {
    Keybind = "Insert",
    Open = false,
    TweenTime = 0.15,
    ESPSize = 50,
    ESPColor = Color3.fromRGB(0, 255, 0),
    LineThickness = 2,
    BoxThickness = 2
}

-- Target block function - with error handling for Matcha
local function getTargetBlock()
    local success, result = pcall(function()
        local mainTerrain = workspace:FindFirstChild("MainTerrain")
        if mainTerrain then
            return mainTerrain:FindFirstChild("Grass")
        end
        return nil
    end)
    return success and result or nil
end

-- Drawing objects (with fallback for executors that don't support Drawing)
local espLine = nil
local espBox = nil
local espEnabled = false
local drawingSupported = false

-- Check if Drawing is supported
local function checkDrawingSupport()
    local success, result = pcall(function()
        local testLine = Drawing.new("Line")
        testLine:Remove()
        return true
    end)
    drawingSupported = success and result
    return drawingSupported
end

-- Setup ESP with proper error handling
local function setupESP()
    if not drawingSupported then
        warn("Drawing API not supported by this executor")
        return false
    end
    
    local success, err = pcall(function()
        if espLine then espLine:Remove() end
        if espBox then espBox:Remove() end
        
        espLine = Drawing.new("Line")
        espLine.Thickness = Config.LineThickness
        espLine.Color = Config.ESPColor
        espLine.Transparency = 1
        espLine.Visible = false
        
        espBox = Drawing.new("Square")
        espBox.Thickness = Config.BoxThickness
        espBox.Color = Config.ESPColor
        espBox.Filled = false
        espBox.Transparency = 1
        espBox.Visible = true
    end)
    
    if not success then
        warn("Failed to setup ESP: " .. tostring(err))
        return false
    end
    return true
end

-- GUI Creation with Matcha compatibility
local screenGui = nil
local mainFrame = nil

local function createGUI()
    -- For Matcha, sometimes CoreGui isn't immediately available
    local targetGui = CoreGui
    if not targetGui then
        targetGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BetaMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = targetGui
    
    -- Main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Title bar
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
    
    -- Draggable functionality for the title bar
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    
    -- Tab buttons
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
    settingsTab.CanvasSize = UDim2.new(0, 0, 0, 200)
    settingsTab.Visible = false
    settingsTab.Parent = contentFrame
    
    -- Helper function to create toggle buttons
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
            pcall(function() callback(state) end)
        end)
        
        return toggleBtn
    end
    
    local function createLabel(parent, text, yPos, color)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.9, 0, 0, 25)
        label.Position = UDim2.new(0.05, 0, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color or Color3.fromRGB(150, 150, 150)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = parent
        return label
    end
    
    -- Build Main Tab
    local mainY = 10
    createLabel(mainTab, "Target: MainTerrain.Grass", mainY); mainY = mainY + 30
    
    -- Status label that updates
    local statusLabel = createLabel(mainTab, "Status: Checking...", mainY); mainY = mainY + 30
    mainY = mainY + 5
    
    createToggle(mainTab, "ESP Trace", mainY, function(state)
        espEnabled = state
        if state then
            setupESP()
        end
    end); mainY = mainY + 45
    
    -- Auto-refresh status
    task.spawn(function()
        while true do
            task.wait(1)
            local block = getTargetBlock()
            local status = block and "Status: FOUND" or "Status: NOT FOUND"
            pcall(function()
                statusLabel.Text = status
                statusLabel.TextColor3 = block and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            end)
        end
    end)
    
    createLabel(mainTab, "Instructions: Enable ESP to see", mainY + 10)
    createLabel(mainTab, "a green box + line to the target", mainY + 30)
    
    mainTab.CanvasSize = UDim2.new(0, 0, 0, mainY + 60)
    
    -- Build Settings Tab
    local settingsY = 10
    
    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0.9, 0, 0, 35)
    keybindBtn.Position = UDim2.new(0.05, 0, 0, settingsY)
    keybindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    keybindBtn.BorderSizePixel = 0
    keybindBtn.Text = "  Menu Keybind: " .. Config.Keybind
    keybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    keybindBtn.TextSize = 14
    keybindBtn.TextXAlignment = Enum.TextXAlignment.Left
    keybindBtn.Font = Enum.Font.Gotham
    keybindBtn.Parent = settingsTab
    
    local waitingForBind = false
    keybindBtn.MouseButton1Click:Connect(function()
        waitingForBind = true
        keybindBtn.Text = "  Press any key..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if waitingForBind then
                local key = input.KeyCode.Name
                Config.Keybind = key
                keybindBtn.Text = "  Menu Keybind: " .. key
                waitingForBind = false
                connection:Disconnect()
            end
        end)
    end)
    
    settingsY = settingsY + 45
    
    -- ESP Settings
    createLabel(settingsTab, "ESP Settings", settingsY, Color3.fromRGB(200, 200, 255)); settingsY = settingsY + 25
    
    local sizeSlider = Instance.new("TextButton")
    sizeSlider.Size = UDim2.new(0.9, 0, 0, 30)
    sizeSlider.Position = UDim2.new(0.05, 0, 0, settingsY)
    sizeSlider.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sizeSlider.BorderSizePixel = 0
    sizeSlider.Text = "  ESP Size: " .. Config.ESPSize
    sizeSlider.TextColor3 = Color3.fromRGB(200, 200, 200)
    sizeSlider.TextSize = 13
    sizeSlider.TextXAlignment = Enum.TextXAlignment.Left
    sizeSlider.Font = Enum.Font.Gotham
    sizeSlider.Parent = settingsTab
    sizeSlider.MouseButton1Click:Connect(function()
        Config.ESPSize = Config.ESPSize + 10
        if Config.ESPSize > 120 then Config.ESPSize = 30 end
        sizeSlider.Text = "  ESP Size: " .. Config.ESPSize
    end)
    
    settingsY = settingsY + 40
    
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
        Config.Open = false
        local tween = TweenService:Create(mainFrame, TweenInfo.new(Config.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
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
    
    return true
end

-- Menu animation functions
local function toggleMenu()
    Config.Open = not Config.Open
    if Config.Open then
        mainFrame.Visible = true
        mainFrame.BackgroundTransparency = 1
        local tween = TweenService:Create(mainFrame, TweenInfo.new(Config.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
            {BackgroundTransparency = 0})
        tween:Play()
    else
        local tween = TweenService:Create(mainFrame, TweenInfo.new(Config.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), 
            {BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            if not Config.Open then
                mainFrame.Visible = false
            end
        end)
    end
end

-- World to screen function
local camera = workspace.CurrentCamera
local function worldToScreen(pos)
    local success, result = pcall(function()
        local vec, onScreen = camera:WorldToViewportPoint(pos)
        return Vector2.new(vec.X, vec.Y), onScreen
    end)
    if success then
        return result, select(2, result)
    end
    return nil, false
end

-- ESP Update Loop
local function startESPUpdate()
    task.spawn(function()
        while true do
            task.wait()
            if not drawingSupported or not espEnabled then
                if espLine then espLine.Visible = false end
                if espBox then espBox.Visible = false end
                return
            end
            
            pcall(function()
                local targetPart = getTargetBlock()
                if not targetPart or not targetPart.Parent then
                    if espLine then espLine.Visible = false end
                    if espBox then espBox.Visible = false end
                    return
                end
                
                local pos = targetPart.Position
                local screenPos, onScreen = worldToScreen(pos)
                
                if onScreen and screenPos then
                    local size = Config.ESPSize
                    if espBox then
                        espBox.Size = Vector2.new(size, size)
                        espBox.Position = screenPos - Vector2.new(size/2, size/2)
                        espBox.Color = Config.ESPColor
                        espBox.Visible = true
                    end
                    
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and espLine then
                        local hrpPos, hrpOn = worldToScreen(hrp.Position)
                        if hrpPos and hrpOn then
                            espLine.From = hrpPos
                            espLine.To = screenPos
                            espLine.Color = Config.ESPColor
                            espLine.Visible = true
                        end
                    end
                else
                    if espBox then espBox.Visible = false end
                    if espLine then espLine.Visible = false end
                end
            end)
        end
    end)
end

-- Keybind listener
local function setupKeybind()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode.Name == Config.Keybind then
            toggleMenu()
        end
    end)
end

-- Initialize everything
local function initialize()
    -- Check drawing support
    checkDrawingSupport()
    
    -- Create GUI
    local success, err = pcall(createGUI)
    if not success then
        warn("Failed to create GUI: " .. tostring(err))
        return
    end
    
    -- Setup ESP if supported
    if drawingSupported then
        setupESP()
        startESPUpdate()
    else
        print("[Beta] Drawing API not supported - ESP features disabled")
    end
    
    -- Setup keybind
    setupKeybind()
    
    print("[Beta] Menu Loaded — Press " .. Config.Keybind .. " to open")
    if MatchaFix.UsingMatcha then
        print("[Beta] Matcha External detected - compatibility mode enabled")
    end
end

-- Run initialization with a small delay for Matcha
task.wait(0.2)
initialize()
