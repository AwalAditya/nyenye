--[[
    ═══════════════════════════════════════════════════════════
    FISCH AUTO FARM SCRIPT - CLEAN VERSION
    ═══════════════════════════════════════════════════════════
    
    Fitur:
    - Auto Cast (Lempar Kail Otomatis)
    - Auto Shake (Goyang Otomatis)
    - Auto Reel (Tarik Otomatis)
    - Auto Sell (Jual Otomatis)
    - Auto Appraiser (Nilai Ikan Otomatis)
    - Speed Boost
    - Anti AFK
    - Teleport
    
    Dibuat: Clean Version
    Peringatan: Gunakan di alt account!
--]]

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════════════════════
-- VARIABEL
-- ═══════════════════════════════════════════════════════════
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Settings
local Settings = {
    AutoCast = false,
    AutoShake = false,
    AutoReel = false,
    AutoSell = false,
    AutoAppraiser = false,
    AntiAFK = true,
    SpeedBoost = false,
    SpeedValue = 25,
    SellLocation = "Moosewood" -- Moosewood, Roslit, Snowcap, etc
}

-- ═══════════════════════════════════════════════════════════
-- FUNGSI HELPER
-- ═══════════════════════════════════════════════════════════

-- Function: Tunggu dengan yield
local function Wait(duration)
    task.wait(duration or 0.1)
end

-- Function: Get Rod (Pancing)
local function GetRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") then
            return tool
        end
    end
    
    return nil
end

-- Function: Equip Rod
local function EquipRod()
    local backpack = LocalPlayer.Backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") then
            Humanoid:EquipTool(tool)
            Wait(0.3)
            return true
        end
    end
    return false
end

-- Function: Teleport
local function Teleport(position)
    if not HumanoidRootPart then return end
    
    local tween = TweenService:Create(
        HumanoidRootPart,
        TweenInfo.new(0.5, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position)}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- Function: Get Player Position
local function GetPosition()
    if HumanoidRootPart then
        return HumanoidRootPart.Position
    end
    return Vector3.new(0, 0, 0)
end

-- ═══════════════════════════════════════════════════════════
-- LOKASI TELEPORT
-- ═══════════════════════════════════════════════════════════
local Locations = {
    Moosewood = Vector3.new(387, 135, 236),
    Roslit = Vector3.new(-1436, 135, 672),
    Snowcap = Vector3.new(2648, 140, 2522),
    Volcano = Vector3.new(-1888, 163, 329),
    Ocean = Vector3.new(5000, 135, 5000),
    Mushgrove = Vector3.new(2500, 135, -723)
}

-- ═══════════════════════════════════════════════════════════
-- AUTO CAST (LEMPAR KAIL)
-- ═══════════════════════════════════════════════════════════
local function AutoCast()
    while Settings.AutoCast do
        pcall(function()
            local rod = GetRod()
            
            if not rod then
                EquipRod()
                Wait(1)
                rod = GetRod()
            end
            
            if rod and rod:FindFirstChild("events") then
                local castEvent = rod.events:FindFirstChild("cast")
                if castEvent then
                    castEvent:FireServer(100, 1) -- Power: 100, Type: 1
                    print("[AUTO CAST] Kail dilempar!")
                    Wait(2)
                end
            end
        end)
        Wait(0.5)
    end
end

-- ═══════════════════════════════════════════════════════════
-- AUTO SHAKE (GOYANG KAIL)
-- ═══════════════════════════════════════════════════════════
local function AutoShake()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    RunService.RenderStepped:Connect(function()
        if not Settings.AutoShake then return end
        
        pcall(function()
            local shakeUI = playerGui:FindFirstChild("shakeui")
            if shakeUI and shakeUI.Enabled then
                local safezone = shakeUI:FindFirstChild("safezone")
                local button = shakeUI:FindFirstChild("button")
                
                if safezone and button and safezone.Visible then
                    -- Check if button is in safezone
                    local buttonPos = button.AbsolutePosition
                    local safezonePos = safezone.AbsolutePosition
                    local safezoneSize = safezone.AbsoluteSize
                    
                    local inZone = buttonPos.X >= safezonePos.X and 
                                   buttonPos.X <= (safezonePos.X + safezoneSize.X) and
                                   buttonPos.Y >= safezonePos.Y and 
                                   buttonPos.Y <= (safezonePos.Y + safezoneSize.Y)
                    
                    if inZone then
                        -- Click button
                        VirtualInputManager:SendMouseButtonEvent(
                            buttonPos.X + button.AbsoluteSize.X/2,
                            buttonPos.Y + button.AbsoluteSize.Y/2,
                            0, true, game, 0
                        )
                        Wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(
                            buttonPos.X + button.AbsoluteSize.X/2,
                            buttonPos.Y + button.AbsoluteSize.Y/2,
                            0, false, game, 0
                        )
                        print("[AUTO SHAKE] Perfect shake!")
                    end
                end
            end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════
-- AUTO REEL (TARIK IKAN)
-- ═══════════════════════════════════════════════════════════
local function AutoReel()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    RunService.RenderStepped:Connect(function()
        if not Settings.AutoReel then return end
        
        pcall(function()
            local reelUI = playerGui:FindFirstChild("reel")
            if reelUI and reelUI.Enabled then
                local bar = reelUI:FindFirstChild("bar")
                if bar and bar.Visible then
                    local rod = GetRod()
                    if rod and rod:FindFirstChild("events") then
                        local reelEvent = rod.events:FindFirstChild("reelfinished")
                        if reelEvent then
                            -- Auto reel dengan perfect timing
                            reelEvent:FireServer(100, true)
                            print("[AUTO REEL] Ikan ditarik!")
                            Wait(0.5)
                        end
                    end
                end
            end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════
-- AUTO SELL
-- ═══════════════════════════════════════════════════════════
local function AutoSell()
    while Settings.AutoSell do
        Wait(5)
        
        pcall(function()
            -- Check inventory
            local backpack = LocalPlayer.Backpack
            local hasFish = false
            
            for _, item in pairs(backpack:GetChildren()) do
                if item.Name:lower():find("fish") or item.Name:lower():find("shark") then
                    hasFish = true
                    break
                end
            end
            
            if hasFish then
                print("[AUTO SELL] Teleport ke merchant...")
                
                -- Save current position
                local originalPos = GetPosition()
                
                -- Teleport ke merchant
                local merchantPos = Locations[Settings.SellLocation] or Locations.Moosewood
                Teleport(merchantPos)
                Wait(1)
                
                -- Sell fish
                local sellEvent = ReplicatedStorage:FindFirstChild("events")
                if sellEvent and sellEvent:FindFirstChild("sell") then
                    sellEvent.sell:FireServer()
                    print("[AUTO SELL] Ikan dijual!")
                    Wait(2)
                end
                
                -- Return to original position
                Teleport(originalPos)
                print("[AUTO SELL] Kembali ke posisi fishing")
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════
-- AUTO APPRAISER (NILAI IKAN)
-- ═══════════════════════════════════════════════════════════
local function AutoAppraiser()
    while Settings.AutoAppraiser do
        Wait(3)
        
        pcall(function()
            local backpack = LocalPlayer.Backpack
            
            for _, item in pairs(backpack:GetChildren()) do
                if item:FindFirstChild("appraised") and not item.appraised.Value then
                    -- Teleport to appraiser
                    local appraiserPos = Locations.Moosewood -- Adjust based on game
                    Teleport(appraiserPos)
                    Wait(1)
                    
                    -- Appraise
                    local appraiseEvent = ReplicatedStorage:FindFirstChild("events")
                    if appraiseEvent and appraiseEvent:FindFirstChild("appraise") then
                        appraiseEvent.appraise:FireServer(item)
                        print("[AUTO APPRAISER] Item dinilai:", item.Name)
                        Wait(1)
                    end
                end
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════
-- ANTI AFK
-- ═══════════════════════════════════════════════════════════
local function AntiAFK()
    local vu = game:GetService("VirtualUser")
    
    LocalPlayer.Idled:Connect(function()
        if Settings.AntiAFK then
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            Wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            print("[ANTI AFK] AFK bypass activated")
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- SPEED BOOST
-- ═══════════════════════════════════════════════════════════
local function SpeedBoost()
    RunService.RenderStepped:Connect(function()
        if Settings.SpeedBoost and Humanoid then
            Humanoid.WalkSpeed = Settings.SpeedValue
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- GUI (Simple)
-- ═══════════════════════════════════════════════════════════
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    
    ScreenGui.Name = "FischAutoFarm"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
    Frame.Size = UDim2.new(0, 250, 0, 400)
    Frame.Active = true
    Frame.Draggable = true
    
    Title.Parent = Frame
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "FISCH AUTO FARM"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    
    -- Create buttons
    local buttonY = 50
    local buttons = {
        {name = "Auto Cast", setting = "AutoCast", func = AutoCast},
        {name = "Auto Shake", setting = "AutoShake", func = AutoShake},
        {name = "Auto Reel", setting = "AutoReel", func = AutoReel},
        {name = "Auto Sell", setting = "AutoSell", func = AutoSell},
        {name = "Speed Boost", setting = "SpeedBoost", func = nil}
    }
    
    for i, btnData in ipairs(buttons) do
        local Button = Instance.new("TextButton")
        Button.Parent = Frame
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(0, 10, 0, buttonY)
        Button.Size = UDim2.new(0, 230, 0, 35)
        Button.Font = Enum.Font.Gotham
        Button.Text = btnData.name .. ": OFF"
        Button.TextColor3 = Color3.fromRGB(255, 85, 85)
        Button.TextSize = 14
        
        Button.MouseButton1Click:Connect(function()
            Settings[btnData.setting] = not Settings[btnData.setting]
            
            if Settings[btnData.setting] then
                Button.Text = btnData.name .. ": ON"
                Button.TextColor3 = Color3.fromRGB(85, 255, 85)
                
                if btnData.func then
                    spawn(btnData.func)
                end
            else
                Button.Text = btnData.name .. ": OFF"
                Button.TextColor3 = Color3.fromRGB(255, 85, 85)
            end
        end)
        
        buttonY = buttonY + 45
    end
    
    print("[GUI] Loaded successfully!")
end

-- ═══════════════════════════════════════════════════════════
-- INISIALISASI
-- ═══════════════════════════════════════════════════════════
print("═══════════════════════════════════════════════════════════")
print("FISCH AUTO FARM - CLEAN VERSION")
print("═══════════════════════════════════════════════════════════")

-- Start services
AntiAFK()
SpeedBoost()

-- Start auto shake and reel (passive)
spawn(AutoShake)
spawn(AutoReel)

-- Create GUI
CreateGUI()

print("[INFO] Script loaded! Toggle fitur di GUI.")
print("[WARNING] Gunakan di alt account!")
print("═══════════════════════════════════════════════════════════")
