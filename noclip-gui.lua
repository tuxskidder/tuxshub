-- NoClip Menu By tux 
-- This is the beta version our team is still working on a better version

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variables
local isNoClipEnabled = false
local isRGBEnabled = false
local gui
local mainFrame
local titleLabel
local toggleButton
local rgbButton
local closeButton
local isDragging = false
local dragStart
local startPos

-- RGB Animation
local rgbConnection
local hueValue = 0

-- Create GUI
local function createGUI()
    -- Main ScreenGui
    gui = Instance.new("ScreenGui")
    gui.Name = "EnhancedNoClipGUI"
    gui.Parent = playerGui
    gui.ResetOnSpawn = false
    
    -- Main Frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    -- Frame Corner
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 12)
    frameCorner.Parent = mainFrame
    
    -- Frame Shadow
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.AnchorPoint = Vector2.new(0, 0)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 16)
    shadowCorner.Parent = shadow
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    -- Fix title bar corners
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 20)
    titleFix.Position = UDim2.new(0, 0, 1, -20)
    titleFix.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Label
    titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "NoClip GUI v2.0"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close Button
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Toggle NoClip Button
    toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1, 0, 0, 40)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "Enable NoClip"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.Parent = contentFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleButton
    
    -- RGB Menu Button
    rgbButton = Instance.new("TextButton")
    rgbButton.Name = "RGBButton"
    rgbButton.Size = UDim2.new(1, 0, 0, 40)
    rgbButton.Position = UDim2.new(0, 0, 0, 50)
    rgbButton.BackgroundColor3 = Color3.fromRGB(150, 75, 150)
    rgbButton.BorderSizePixel = 0
    rgbButton.Text = "Enable RGB Menu"
    rgbButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rgbButton.TextScaled = true
    rgbButton.Font = Enum.Font.Gotham
    rgbButton.Parent = contentFrame
    
    local rgbCorner = Instance.new("UICorner")
    rgbCorner.CornerRadius = UDim.new(0, 8)
    rgbCorner.Parent = rgbButton
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 1, -25)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Ready"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = contentFrame
    
    return statusLabel
end

-- NoClip Functions
local function enableNoClip()
    local character = player.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent == character then
            part.CanCollide = false
        end
    end
end

local function disableNoClip()
    local character = player.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent == character then
            part.CanCollide = true
        end
    end
end

-- RGB Animation Function
local function startRGBAnimation()
    rgbConnection = RunService.Heartbeat:Connect(function()
        hueValue = (hueValue + 2) % 360
        local color = Color3.fromHSV(hueValue / 360, 1, 1)
        
        -- Apply rainbow to different UI elements
        if titleLabel then
            titleLabel.TextColor3 = color
        end
        if mainFrame then
            mainFrame.BackgroundColor3 = Color3.fromRGB(
                math.floor(color.R * 100 + 45),
                math.floor(color.G * 100 + 45),
                math.floor(color.B * 100 + 45)
            )
        end
        if toggleButton then
            toggleButton.BackgroundColor3 = color
        end
        if rgbButton then
            rgbButton.BackgroundColor3 = Color3.fromRGB(
                math.floor(color.R * 200 + 55),
                math.floor(color.G * 200 + 55),
                math.floor(color.B * 200 + 55)
            )
        end
    end)
end

local function stopRGBAnimation()
    if rgbConnection then
        rgbConnection:Disconnect()
        rgbConnection = nil
    end
    
    -- Reset colors
    if titleLabel then
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    if mainFrame then
        mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
    if toggleButton then
        toggleButton.BackgroundColor3 = isNoClipEnabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(70, 130, 180)
    end
    if rgbButton then
        rgbButton.BackgroundColor3 = Color3.fromRGB(150, 75, 150)
    end
end

-- Dragging Functions
local function onDragStart(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end

local function onDragEnd(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end

local function onDrag(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

-- Button Animations
local function animateButton(button, scale)
    local tween = TweenService:Create(
        button,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(scale, 0, 0, 40)}
    )
    tween:Play()
end

-- Main Setup
local function setup()
    local statusLabel = createGUI()
    
    -- NoClip Loop
    RunService.Stepped:Connect(function()
        if isNoClipEnabled then
            enableNoClip()
        end
    end)
    
    -- Button Events
    toggleButton.MouseButton1Click:Connect(function()
        isNoClipEnabled = not isNoClipEnabled
        
        if isNoClipEnabled then
            toggleButton.Text = "Disable NoClip"
            toggleButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            statusLabel.Text = "Status: NoClip Enabled"
        else
            toggleButton.Text = "Enable NoClip"
            toggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
            statusLabel.Text = "Status: NoClip Disabled"
            disableNoClip()
        end
    end)
    
    rgbButton.MouseButton1Click:Connect(function()
        isRGBEnabled = not isRGBEnabled
        
        if isRGBEnabled then
            rgbButton.Text = "Disable RGB Menu"
            startRGBAnimation()
            statusLabel.Text = "Status: RGB Mode Active"
        else
            rgbButton.Text = "Enable RGB Menu"
            stopRGBAnimation()
            statusLabel.Text = "Status: RGB Mode Disabled"
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        if rgbConnection then
            rgbConnection:Disconnect()
        end
        gui:Destroy()
    end)
    
    -- Button Hover Effects
    toggleButton.MouseEnter:Connect(function()
        animateButton(toggleButton, 1.05)
    end)
    
    toggleButton.MouseLeave:Connect(function()
        animateButton(toggleButton, 1)
    end)
    
    rgbButton.MouseEnter:Connect(function()
        animateButton(rgbButton, 1.05)
    end)
    
    rgbButton.MouseLeave:Connect(function()
        animateButton(rgbButton, 1)
    end)
    
    -- Dragging
    titleLabel.InputBegan:Connect(onDragStart)
    UserInputService.InputChanged:Connect(onDrag)
    UserInputService.InputEnded:Connect(onDragEnd)
    
    -- Character respawn handling
    player.CharacterAdded:Connect(function()
        wait(1) -- Wait for character to fully load
        if isNoClipEnabled then
            statusLabel.Text = "Status: NoClip Re-enabled"
        end
    end)
    
    print("Noclip GUI by Tux Successfly Loaded!")
end

-- Initialize
setup()

