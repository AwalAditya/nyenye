--[[
    ═══════════════════════════════════════════════════════════
    ROBLOX AUTO FARM SCRIPT - CLEAN VERSION
    ═══════════════════════════════════════════════════════════
    
    Fitur:
    - Auto Farm (Farming Otomatis)
    - Auto Collect (Kumpul Item Otomatis)
    - Auto Sell (Jual Otomatis)
    - Speed Boost (Jalan Cepat)
    - Anti AFK (Anti Kick)
    - Teleport
    - ESP (Lihat Item dari Jauh)
    
    Dibuat: Clean Version
    Peringatan: Gunakan di alt account!
--]]

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- ═══════════════════════════════════════════════════════════
-- VARIABEL UTAMA
-- ═══════════════════════════════════════════════════════════
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Settings
local Settings = {
    AutoFarm = false,
    AutoCollect = false,
    AutoSell = false,
    SpeedBoost = false,
    SpeedValue = 30,
    AntiAFK = true,
    ESP = false,
    SafeMode = true, -- Mode aman, delay lebih lama
    FarmRadius = 50 -- Radius farm dari posisi player
}

-- ═══════════════════════════════════════════════════════════
-- FUNGSI HELPER
-- ═══════════════════════════════════════════════════════════

-- Function: Wait dengan yield
local function Wait(duration)
    task.wait(duration or 0.1)
end

-- Function: Teleport dengan Tween (lebih aman)
local function TeleportTo(position, speed)
    if not HumanoidRootPart then return end
    
    speed = speed or 100
    local distance = (HumanoidRootPart.Position - position).Magnitude
    local duration = distance / speed
    
    if duration < 0.1 then duration = 0.1 end
    if duration > 3 then duration = 3 end
    
    local tween = TweenService:Create(
        HumanoidRootPart,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position)}
    )
    
    tween:Play()
    tween.Completed:Wait()
end

-- Function: Instant Teleport (berbahaya, bisa detect)
local function InstantTeleport(position)
    if not HumanoidRootPart then return end
    HumanoidRootPart.CFrame = CFrame.new(position)
end

-- Function: Get Current Position
local function GetPosition()
    if HumanoidRootPart then
        return HumanoidRootPart.Position
    end
    return Vector3.new(0, 0, 0)
end

-- Function: Get Distance
local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Function: Fire Remote
local function FireRemote(remoteName, ...)
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        if remote then
            if remote:IsA("RemoteEvent") then
                remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(...)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- ANTI AFK
-- ═══════════════════════════════════════════════════════════
local function InitAntiAFK()
    LocalPlayer.Idled:Connect(function()
        if Settings.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            print("[ANTI AFK] Bypass activated")
        end
    end)
    
    print("[ANTI AFK] Initialized")
end

-- ═══════════════════════════════════════════════════════════
-- SPEED BOOST
-- ═══════════════════════════════════════════════════════════
local function InitSpeedBoost()
    RunService.Heartbeat:Connect(function()
        if Settings.SpeedBoost and Humanoid then
            Humanoid.WalkSpeed = Settings.SpeedValue
        end
    end)
    
    print("[SPEED BOOST] Initialized")
end

-- ═══════════════════════════════════════════════════════════
-- AUTO COLLECT (Kumpul Item/Coin/Drop)
-- ═══════════════════════════════════════════════════════════
local function AutoCollect()
    while Settings.AutoCollect do
        pcall(function()
            local workspace = game:GetService("Workspace")
            local currentPos = GetPosition()
            
            -- Cari semua item di workspace
            for _, obj in pairs(workspace:GetDescendants()) do
                if not Settings.AutoCollect then break end
                
                -- Deteksi item yang bisa dikumpulkan
                -- Sesuaikan dengan game Anda (contoh: Coin, Drop, Item, dll)
                local isCollectible = obj:IsA("BasePart") and 
                                     (obj.Name:lower():find("coin") or 
                                      obj.Name:lower():find("drop") or
                                      obj.Name:lower():find("item") or
                                      obj.Name:lower():find("collect"))
                
                if isCollectible then
                    local distance = GetDistance(currentPos, obj.Position)
                    
                    -- Hanya collect dalam radius
                    if distance <= Settings.FarmRadius then
                        -- Teleport ke item
                        if Settings.SafeMode then
                            TeleportTo(obj.Position, 80)
                        else
                            InstantTeleport(obj.Position)
                        end
                        
                        Wait(0.1)
                        
                        -- Touch item (auto collect)
                        firetouchinterest(HumanoidRootPart, obj, 0)
                        Wait(0.05)
                        firetouchinterest(HumanoidRootPart, obj, 1)
                        
                        print("[AUTO COLLECT] Collected:", obj.Name)
                        
                        if Settings.SafeMode then
                            Wait(0.3)
                        end
                    end
                end
            end
        end)
        
        Wait(1) -- Delay antar cycle
    end
end

-- ═══════════════════════════════════════════════════════════
-- AUTO FARM (Bunuh Enemy/NPC)
-- ═══════════════════════════════════════════════════════════
local function AutoFarm()
    while Settings.AutoFarm do
        pcall(function()
            local workspace = game:GetService("Workspace")
            local currentPos = GetPosition()
            
            -- Cari enemy/NPC
            local enemies = workspace:FindFirstChild("Enemies") or 
                           workspace:FindFirstChild("NPCs") or
                           workspace:FindFirstChild("Mobs")
            
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    if not Settings.AutoFarm then break end
                    
                    -- Check jika enemy masih hidup
                    local enemyHumanoid = enemy:FindFirstChild("Humanoid")
                    if enemyHumanoid and enemyHumanoid.Health > 0 then
                        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or 
                                         enemy:FindFirstChild("Torso")
                        
                        if enemyRoot then
                            local distance = GetDistance(currentPos, enemyRoot.Position)
                            
                            -- Farm dalam radius
                            if distance <= Settings.FarmRadius then
                                print("[AUTO FARM] Attacking:", enemy.Name)
                                
                                -- Teleport ke enemy
                                local attackPos = enemyRoot.Position + Vector3.new(0, 3, 5)
                                TeleportTo(attackPos, 100)
                                
                                -- Attack loop
                                while enemyHumanoid.Health > 0 and Settings.AutoFarm do
                                    -- Fire attack remote (sesuaikan dengan game)
                                    FireRemote("Attack", enemy)
                                    FireRemote("Damage", enemy)
                                    FireRemote("Combat", enemy)
                                    
                                    -- Atau gunakan tool
                                    local tool = Character:FindFirstChildOfClass("Tool")
                                    if tool then
                                        tool:Activate()
                                    end
                                    
                                    Wait(0.2)
                                end
                                
                                print("[AUTO FARM] Defeated:", enemy.Name)
                                Wait(0.5)
                            end
                        end
                    end
                end
            end
        end)
        
        Wait(1)
    end
end

-- ═══════════════════════════════════════════════════════════
-- AUTO SELL
-- ═══════════════════════════════════════════════════════════
local SellLocations = {
    Default = Vector3.new(0, 10, 0), -- Sesuaikan dengan game
    Shop1 = Vector3.new(100, 10, 100),
    Shop2 = Vector3.new(-100, 10, -100)
}

local function AutoSell()
    while Settings.AutoSell do
        Wait(30) -- Check setiap 30 detik
        
        pcall(function()
            local backpack = LocalPlayer.Backpack
            local inventory = LocalPlayer:FindFirstChild("Inventory")
            
            -- Check jika ada item untuk dijual
            local hasItems = false
            
            if backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") or item.Name:lower():find("item") then
                        hasItems = true
                        break
                    end
                end
            end
            
            if inventory then
                -- Check inventory value (sesuaikan dengan game)
                local value = inventory:FindFirstChild("Value")
                if value and value.Value > 0 then
                    hasItems = true
                end
            end
            
            if hasItems then
                print("[AUTO SELL] Teleporting to sell location...")
                
                -- Save position
                local originalPos = GetPosition()
                
                -- Teleport ke sell location
                TeleportTo(SellLocations.Default, 150)
                Wait(1)
                
                -- Fire sell remote
                FireRemote("Sell")
                FireRemote("SellAll")
                FireRemote("SellItems")
                
                print("[AUTO SELL] Items sold!")
                Wait(2)
                
                -- Return to original position
                TeleportTo(originalPos, 150)
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════
-- ESP (Extra Sensory Perception)
-- ═══════════════════════════════════════════════════════════
local ESPObjects = {}

local function CreateESP(object, color, text)
    if ESPObjects[object] then return end
    
    local BillboardGui = Instance.new("BillboardGui")
    local TextLabel = Instance.new("TextLabel")
    
    BillboardGui.Parent = object
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 100, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    
    TextLabel.Parent = BillboardGui
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = text or object.Name
    TextLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    TextLabel.TextStrokeTransparency = 0.5
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.GothamBold
    
    ESPObjects[object] = BillboardGui
end

local function InitESP()
    RunService.Heartbeat:Connect(function()
        if not Settings.ESP then return end
        
        pcall(function()
            local workspace = game:GetService("Workspace")
            
            -- ESP untuk enemies
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    local root = enemy:FindFirstChild("HumanoidRootPart")
                    if root and not ESPObjects[root] then
                        CreateESP(root, Color3.fromRGB(255, 85, 85), enemy.Name)
                    end
                end
            end
            
            -- ESP untuk items
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("item") or obj.Name:lower():find("coin")) then
                    if not ESPObjects[obj] then
                        CreateESP(obj, Color3.fromRGB(85, 255, 85), obj.Name)
                    end
                end
            end
        end)
    end)
    
    print("[ESP] Initialized")
end

-- ═══════════════════════════════════════════════════════════
-- GUI
-- ═══════════════════════════════════════════════════════════
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local UICorner = Instance.new("UICorner")
    
    -- Setup ScreenGui
    ScreenGui.Name = "AutoFarmGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
    MainFrame.Size = UDim2.new(0, 280, 0, 450)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "AUTO FARM SCRIPT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Create Buttons
    local buttonY = 60
    local buttons = {
        {name = "Auto Farm", setting = "AutoFarm", func = AutoFarm},
        {name = "Auto Collect", setting = "AutoCollect", func = AutoCollect},
        {name = "Auto Sell", setting = "AutoSell", func = AutoSell},
        {name = "Speed Boost", setting = "SpeedBoost"},
        {name = "ESP", setting = "ESP"},
        {name = "Safe Mode", setting = "SafeMode"}
    }
    
    for i, btnData in ipairs(buttons) do
        local Button = Instance.new("TextButton")
        local ButtonCorner = Instance.new("UICorner")
        
        Button.Name = btnData.name
        Button.Parent = MainFrame
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(0, 15, 0, buttonY)
        Button.Size = UDim2.new(0, 250, 0, 40)
        Button.Font = Enum.Font.GothamBold
        Button.Text = btnData.name .. ": OFF"
        Button.TextColor3 = Color3.fromRGB(255, 85, 85)
        Button.TextSize = 14
        
        ButtonCorner.CornerRadius = UDim.new(0, 8)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            Settings[btnData.setting] = not Settings[btnData.setting]
            
            if Settings[btnData.setting] then
                Button.Text = btnData.name .. ": ON"
                Button.TextColor3 = Color3.fromRGB(85, 255, 85)
                Button.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
                
                if btnData.func then
                    spawn(function()
                        btnData.func()
                    end)
                end
            else
                Button.Text = btnData.name .. ": OFF"
                Button.TextColor3 = Color3.fromRGB(255, 85, 85)
                Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end
        end)
        
        buttonY = buttonY + 50
    end
    
    -- Credits
    local Credits = Instance.new("TextLabel")
    Credits.Parent = MainFrame
    Credits.BackgroundTransparency = 1
    Credits.Position = UDim2.new(0, 0, 1, -30)
    Credits.Size = UDim2.new(1, 0, 0, 30)
    Credits.Font = Enum.Font.Gotham
    Credits.Text = "Clean Version | Use at your own risk"
    Credits.TextColor3 = Color3.fromRGB(150, 150, 150)
    Credits.TextSize = 10
    
    print("[GUI] Loaded successfully!")
end

-- ═══════════════════════════════════════════════════════════
-- INISIALISASI
-- ═══════════════════════════════════════════════════════════
print("═══════════════════════════════════════════════════════════")
print("AUTO FARM SCRIPT - CLEAN VERSION")
print("═══════════════════════════════════════════════════════════")

-- Initialize passive features
InitAntiAFK()
InitSpeedBoost()
InitESP()

-- Create GUI
Wait(1)
CreateGUI()

print("[INFO] Script loaded successfully!")
print("[WARNING] Gunakan di alt account!")
print("[INFO] Toggle fitur melalui GUI")
print("═══════════════════════════════════════════════════════════")
