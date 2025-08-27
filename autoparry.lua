-- Tux Hub / AutoParry
-- Protected by Moonedity
-- Tux and Moonedity Made this

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Player Variables
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Configuration
local Config = {
    AutoParry = {
        Enabled = false,
        Distance = 30,
        ResponseTime = 0.05,
        PredictionTime = 0.1,
        SmartTiming = true,
        MultiHit = false,
        Visualization = false
    },
    Performance = {
        MaxFPS = 60,
        LowLatency = true,
        CpuOptimization = true
    }
}

-- State Management
local State = {
    lastParryTime = 0,
    parryStreak = 0,
    connections = {},
    ballHistory = {},
    performance = {
        averageResponseTime = 0,
        successRate = 0,
        totalAttempts = 0,
        successfulParries = 0
    }
}

-- Advanced Ball Detection System
local function findBalls()
    local balls = {}
    local character = Player.Character
    if not character or not character.PrimaryPart then return balls end
    
    local playerPosition = character.PrimaryPart.Position
    
    -- Multi-method ball detection
    local searchMethods = {
        function() return Workspace:FindFirstChild("Balls") and Workspace.Balls:GetChildren() or {} end,
        function() 
            local found = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (
                    obj.Name:lower():match("ball") or 
                    obj.Shape == Enum.PartType.Ball or
                    obj.Material == Enum.Material.Neon
                ) then
                    table.insert(found, obj)
                end
            end
            return found
        end,
        function()
            local found = {}
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:lower():match("ball") then
                    local primaryPart = obj.PrimaryPart or obj:FindFirstChild("Ball")
                    if primaryPart then table.insert(found, primaryPart) end
                end
            end
            return found
        end
    }
    
    for _, method in pairs(searchMethods) do
        local foundBalls = pcall(method) and method() or {}
        for _, ball in pairs(foundBalls) do
            if ball:IsA("BasePart") then
                local distance = (ball.Position - playerPosition).Magnitude
                if distance < 200 then -- Only consider nearby balls
                    table.insert(balls, {
                        object = ball,
                        distance = distance,
                        velocity = ball.AssemblyLinearVelocity or ball.Velocity or Vector3.new(),
                        lastPosition = ball.Position,
                        timestamp = tick()
                    })
                end
            end
        end
    end
    
    -- Sort by distance
    table.sort(balls, function(a, b) return a.distance < b.distance end)
    return balls
end

-- Predictive Analysis System
local function predictBallTrajectory(ballData)
    if not ballData or ballData.velocity.Magnitude < 1 then return false, 0 end
    
    local character = Player.Character
    if not character or not character.PrimaryPart then return false, 0 end
    
    local playerPos = character.PrimaryPart.Position
    local ballPos = ballData.object.Position
    local ballVel = ballData.velocity
    
    -- Calculate trajectory
    local timeToReach = ballData.distance / math.max(ballVel.Magnitude, 1)
    local predictedPosition = ballPos + (ballVel * timeToReach)
    
    -- Check if ball is heading towards player
    local directionToPlayer = (playerPos - ballPos).Unit
    local ballDirection = ballVel.Unit
    local dotProduct = directionToPlayer:Dot(ballDirection)
    
    -- Advanced prediction factors
    local isHeadingTowards = dotProduct > 0.3
    local hasCorrectSpeed = ballVel.Magnitude > 10 and ballVel.Magnitude < 200
    local isInRange = ballData.distance <= Config.AutoParry.Distance
    local timingWindow = timeToReach <= Config.AutoParry.PredictionTime and timeToReach > 0.01
    
    local shouldParry = isHeadingTowards and hasCorrectSpeed and isInRange and timingWindow
    
    return shouldParry, timeToReach
end

-- Enhanced Parry Execution
local function executeParry()
    local startTime = tick()
    local success = false
    local methods = 0
    
    local character = Player.Character
    if not character then return false end
    
    -- Method 1: Tool Activation
    pcall(function()
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Activate()
                methods = methods + 1
                success = true
            end
        end
        
        -- Check backpack
        local backpack = Player.Backpack
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Parent = character
                    wait(0.01)
                    tool:Activate()
                    methods = methods + 1
                    success = true
                    break
                end
            end
        end
    end)
    
    -- Method 2: Remote Events (Enhanced Detection)
    local remotePatterns = {
        "parry", "deflect", "block", "hit", "swing", "attack", "counter", "defend"
    }
    
    pcall(function()
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local remoteName = remote.Name:lower()
                for _, pattern in pairs(remotePatterns) do
                    if remoteName:find(pattern) then
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                            remote:FireServer(0.5)
                            remote:FireServer(CFrame.new())
                        else
                            remote:InvokeServer()
                        end
                        methods = methods + 1
                        success = true
                    end
                end
            end
        end
    end)
    
    -- Method 3: Input Simulation
    pcall(function()
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            methods = methods + 1
        end
        
        -- Mouse simulation
        local mouse = Player:GetMouse()
        mouse.Button1Down:Fire()
        wait(0.01)
        mouse.Button1Up:Fire()
        methods = methods + 1
        success = true
    end)
    
    -- Method 4: Contextual Actions
    pcall(function()
        local contextActionService = game:GetService("ContextActionService")
        contextActionService:CallFunction("parry", Enum.UserInputState.Begin)
        methods = methods + 1
    end)
    
    -- Update performance metrics
    local responseTime = tick() - startTime
    State.performance.averageResponseTime = (State.performance.averageResponseTime + responseTime) / 2
    State.performance.totalAttempts = State.performance.totalAttempts + 1
    
    if success then
        State.performance.successfulParries = State.performance.successfulParries + 1
        State.parryStreak = State.parryStreak + 1
    else
        State.parryStreak = 0
    end
    
    State.performance.successRate = (State.performance.successfulParries / State.performance.totalAttempts) * 100
    
    return success
end

-- Main Auto Parry Loop
local function autoParryLoop()
    if not Config.AutoParry.Enabled then return end
    
    local currentTime = tick()
    if currentTime - State.lastParryTime < Config.AutoParry.ResponseTime then return end
    
    local balls = findBalls()
    if #balls == 0 then return end
    
    for _, ballData in pairs(balls) do
        local shouldParry, timeToReach = predictBallTrajectory(ballData)
        
        if shouldParry then
            -- Smart timing adjustment
            if Config.AutoParry.SmartTiming then
                local optimalDelay = math.max(timeToReach - 0.1, 0)
                if optimalDelay > 0 then
                    wait(optimalDelay)
                end
            end
            
            if executeParry() then
                State.lastParryTime = currentTime
                
                -- Multi-hit prevention
                if not Config.AutoParry.MultiHit then
                    wait(0.5) -- Cooldown
                end
                
                break -- Only parry once per loop
            end
        end
    end
end

-- Create Enhanced UI
local Window = Rayfield:CreateWindow({
    Name = "Tux's Ultra Auto Parry v2.0",
    LoadingTitle = "Loading Ultra Parry System",
    LoadingSubtitle = "Advanced Prediction Engine",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TuxUltraParry",
        FileName = "ConfigV2"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Auto Parry", 4483362458)

-- Auto Parry Toggle
local AutoParryToggle = MainTab:CreateToggle({
    Name = "🎯 Ultra Auto Parry",
    CurrentValue = false,
    Flag = "UltraAutoParry",
    Callback = function(Value)
        Config.AutoParry.Enabled = Value
        
        if Value then
            -- High-frequency connections for maximum responsiveness
            State.connections.heartbeat = RunService.Heartbeat:Connect(autoParryLoop)
            State.connections.renderStepped = RunService.RenderStepped:Connect(autoParryLoop)
            
            Rayfield:Notify({
                Title = "Ultra Auto Parry",
                Content = "🚀 Lightning-fast parry system activated!",
                Duration = 2,
                Image = 4483362458
            })
        else
            for name, connection in pairs(State.connections) do
                if connection then
                    connection:Disconnect()
                    State.connections[name] = nil
                end
            end
            
            Rayfield:Notify({
                Title = "Ultra Auto Parry",
                Content = "⏹️ Auto parry system disabled",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
})

-- Advanced Settings
local DistanceSlider = MainTab:CreateSlider({
    Name = "📏 Detection Distance",
    Range = {15, 60},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 30,
    Flag = "DetectionDistance",
    Callback = function(Value)
        Config.AutoParry.Distance = Value
    end
})

local ResponseSlider = MainTab:CreateSlider({
    Name = "⚡ Response Time",
    Range = {0.01, 0.3},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.05,
    Flag = "ResponseTime",
    Callback = function(Value)
        Config.AutoParry.ResponseTime = Value
    end
})

local PredictionSlider = MainTab:CreateSlider({
    Name = "🔮 Prediction Window",
    Range = {0.05, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "PredictionWindow",
    Callback = function(Value)
        Config.AutoParry.PredictionTime = Value
    end
})

-- Advanced Features
local SmartTimingToggle = MainTab:CreateToggle({
    Name = "🧠 Smart Timing",
    CurrentValue = true,
    Flag = "SmartTiming",
    Callback = function(Value)
        Config.AutoParry.SmartTiming = Value
    end
})

local MultiHitToggle = MainTab:CreateToggle({
    Name = "🔥 Multi-Hit Mode",
    CurrentValue = false,
    Flag = "MultiHit",
    Callback = function(Value)
        Config.AutoParry.MultiHit = Value
    end
})

local VisualizationToggle = MainTab:CreateToggle({
    Name = "👁️ Ball Visualization",
    CurrentValue = false,
    Flag = "BallVisualization",
    Callback = function(Value)
        Config.AutoParry.Visualization = Value
        
        if Value then
            State.connections.visualization = RunService.RenderStepped:Connect(function()
                local balls = findBalls()
                for _, ballData in pairs(balls) do
                    local ball = ballData.object
                    local highlight = ball:FindFirstChild("UltraParryHighlight")
                    
                    if not highlight then
                        highlight = Instance.new("SelectionBox")
                        highlight.Name = "UltraParryHighlight"
                        highlight.Adornee = ball
                        highlight.Color3 = ballData.distance <= Config.AutoParry.Distance 
                            and Color3.fromRGB(0, 255, 0) 
                            or Color3.fromRGB(255, 165, 0)
                        highlight.LineThickness = 0.3
                        highlight.Transparency = 0.3
                        highlight.Parent = ball
                    end
                    
                    -- Update color based on distance
                    highlight.Color3 = ballData.distance <= Config.AutoParry.Distance 
                        and Color3.fromRGB(0, 255, 0) 
                        or Color3.fromRGB(255, 165, 0)
                end
            end)
        else
            if State.connections.visualization then
                State.connections.visualization:Disconnect()
                State.connections.visualization = nil
            end
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "UltraParryHighlight" then
                    obj:Destroy()
                end
            end
        end
    end
})

-- Performance Tab
local PerformanceTab = Window:CreateTab("📊 Performance", 4483362458)

local StatsLabel = PerformanceTab:CreateLabel("📈 Performance Statistics")
local StreakLabel = PerformanceTab:CreateLabel("🏆 Current Streak: 0")
local ResponseLabel = PerformanceTab:CreateLabel("⚡ Avg Response: 0.00ms")
local SuccessLabel = PerformanceTab:CreateLabel("🎯 Success Rate: 0.00%")

-- Manual Controls
local ManualParry = MainTab:CreateButton({
    Name = "🎮 Manual Parry Test",
    Callback = function()
        local success = executeParry()
        Rayfield:Notify({
            Title = "Manual Parry",
            Content = success and "✅ Parry executed!" or "❌ No tool found!",
            Duration = 1.5,
            Image = 4483362458
        })
    end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

local ResetButton = SettingsTab:CreateButton({
    Name = "🔄 Reset to Optimal",
    Callback = function()
        Config.AutoParry.Distance = 30
        Config.AutoParry.ResponseTime = 0.05
        Config.AutoParry.PredictionTime = 0.1
        Config.AutoParry.SmartTiming = true
        
        DistanceSlider:Set(30)
        ResponseSlider:Set(0.05)
        PredictionSlider:Set(0.1)
        SmartTimingToggle:Set(true)
        
        Rayfield:Notify({
            Title = "Settings Reset",
            Content = "🔧 Restored optimal configuration!",
            Duration = 2,
            Image = 4483362458
        })
    end
})

-- Real-time Statistics Update
spawn(function()
    while wait(0.5) do
        StreakLabel:Set(string.format("🏆 Current Streak: %d", State.parryStreak))
        ResponseLabel:Set(string.format("⚡ Avg Response: %.2fms", State.performance.averageResponseTime * 1000))
        SuccessLabel:Set(string.format("🎯 Success Rate: %.1f%%", State.performance.successRate))
    end
end)

-- Cleanup System
local function cleanup()
    for _, connection in pairs(State.connections) do
        if connection then connection:Disconnect() end
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "UltraParryHighlight" then
            obj:Destroy()
        end
    end
end

-- Event Connections
Players.PlayerRemoving:Connect(function(player)
    if player == Player then cleanup() end
end)

game:BindToClose(cleanup)

-- Initialize
Rayfield:Notify({
    Title = "Tux's Ultra Auto Parry v2.0",
    Content = "🚀 Advanced prediction system loaded!",
    Duration = 3,
    Image = 4483362458
})

print("🎯 Tux Hub / My AutoParry!")
print("⚡ Protected By Moonedity")
print("🧠 RIVALS AIMBOT COMMING SOON")
print("🔥 Tux Made This, Creds to Moonedity")
