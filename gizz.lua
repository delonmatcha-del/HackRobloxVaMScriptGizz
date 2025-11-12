-- =====================================================
-- GizzVaMExploite1.0 (Vape UI Full ESP Revamp)
-- Aimlock + ESP Advanced + Character Mods + Floating Toggle
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

-- Config
local FOV_PX = 65
local AIM_SMOOTHNESS = 0.9
local RADAR_SIZE = 300

-- Load Vape UI
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("GizzVaMExploite1.0", Color3.fromRGB(0, 255, 0), Enum.KeyCode.RightControl)

-- =================== TAB1: Aimlock ===================
local tab1 = win:Tab("Aimlock")
local aimEnabled, hardLock, prediction, firstPerson = false, false, false, false
local aimPart = "Head"

tab1:Toggle("EnabledAim", false, function(v) aimEnabled = v end)
tab1:Toggle("AimGlue", false, function(v) hardLock = v end)
tab1:Toggle("AimPrediction", false, function(v) prediction = v end)
tab1:Toggle("AimFov", false, function(v)
    firstPerson = v
    Camera.CameraType = v and Enum.CameraType.Custom or Enum.CameraType.Track
end)

-- =================== TAB2: ESP ===================
local tab2 = win:Tab("ESP")

local espEnabled = false
local espChamsColor = Color3.fromRGB(0,255,0)
local espBox, espLine, espTracers, espNames, espSkeleton, fovCircleEnabled = true,true,true,true,true,true

tab2:Toggle("EnabledEsp", false, function(v) espEnabled = v end)
tab2:Toggle("EspBox", true, function(v) espBox = v end)
tab2:Toggle("EspThick", true, function(v) espLine = v end)
tab2:Toggle("EspTrack", true, function(v) espTracers = v end)
tab2:Toggle("EspName", true, function(v) espNames = v end)
tab2:Toggle("EspBone", true, function(v) espSkeleton = v end)
tab2:Toggle("EspFov", true, function(v) fovCircleEnabled = v end)
tab2:Colorpicker("EspColor", espChamsColor, function(c) espChamsColor = c end)

-- ESP Gui Setup
local visuals = {}
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local espGui = playerGui:FindFirstChild("GizzESP") or Instance.new("ScreenGui", playerGui)
espGui.Name = "GizzESP"
espGui.IgnoreGuiInset = true
espGui.ResetOnSpawn = false

-- FOV Circle
local fovCircle = Instance.new("Frame", espGui)
fovCircle.Size = UDim2.new(0, 999*2, 0, 999*2)
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.Position = UDim2.new(0.5,0,0.5,0)
fovCircle.BorderSizePixel = 2
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = fovCircleEnabled
local fovCircleStroke = Instance.new("UIStroke", fovCircle)
fovCircleStroke.Color = espChamsColor
fovCircleStroke.Thickness = 1

-- ESP Functions
local function createESP(plr)
    if visuals[plr] then return visuals[plr] end
    local char = plr.Character
    if not char then return end

    local t = {}
    if espBox then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        box.AlwaysOnTop = true
        box.Color3 = espChamsColor
        box.Size = Vector3.new(2, 3, 1)
        box.ZIndex = 2
        box.Parent = espGui
        t.box = box
    end

    if espTracers then
        local tracer = Instance.new("Frame")
        tracer.Size = UDim2.new(0,1,0,100)
        tracer.BackgroundColor3 = espChamsColor
        tracer.BorderSizePixel = 0
        tracer.AnchorPoint = Vector2.new(0.5,1)
        tracer.Position = UDim2.new(0.5,0,1,0)
        tracer.Parent = espGui
        t.tracer = tracer
    end

    if espNames then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0,100,0,20)
        nameLabel.Position = UDim2.new(0.5,-50,0,0)
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = espChamsColor
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 14
        nameLabel.Parent = espGui
        t.nameLabel = nameLabel
    end

    if espSkeleton then
        t.skeleton = {} -- akan kita update di RenderStepped
    end

    visuals[plr] = t
    return t
end

local function destroyESP(plr)
    if visuals[plr] then
        for k,v in pairs(visuals[plr]) do
            if v and v.Destroy then pcall(function() v:Destroy() end) end
        end
        visuals[plr] = nil
    end
end

-- =================== TAB3: Character Mods ===================
local tab3 = win:Tab("Character Mods")
local speedEnabled, jumpEnabled, fovEnabled = false,false,false
tab3:Toggle("SpeedHack", false, function(v) speedEnabled = v end)
tab3:Toggle("JumpHack", false, function(v) jumpEnabled = v end)
tab3:Toggle("SuperFov", false, function(v) fovEnabled = v end)

local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultFOV = Camera.FieldOfView

-- =================== TAB4: Hide Menu ===================
local tab4 = win:Tab("Hide Menu")
local hideUI = false
tab4:Button("Refresh", function()
    win:Hide()
    hideUI = true
end)

-- Floating circular button (Delta-style)
local floatingButton = Instance.new("TextButton", LocalPlayer.PlayerGui)
floatingButton.Size = UDim2.new(0,40,0,40)
floatingButton.Position = UDim2.new(0,10,0,10)
floatingButton.BackgroundColor3 = Color3.fromRGB(0,255,0)
floatingButton.Text = "G"
floatingButton.TextColor3 = Color3.new(0,0,0)
floatingButton.AutoButtonColor = true
floatingButton.Visible = true
floatingButton.AnchorPoint = Vector2.new(0,0)
floatingButton.MouseButton1Click:Connect(function()
    win:Show()
    hideUI = false
end)

-- =================== Aimlock Finder ===================
local function findTarget()
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local part = plr.Character.Head
            local pos, visible = Camera:WorldToViewportPoint(part.Position)
            if visible then
                local dist = (Vector2.new(pos.X,pos.Y)-Vector2.new(cx,cy)).Magnitude
                if dist < FOV_PX and dist < bestDist then
                    best = part
                    bestDist = dist
                end
            end
        end
    end
    return best
end

-- =================== Main Loop ===================
RunService.RenderStepped:Connect(function()
    -- ESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if espEnabled then
                local t = createESP(plr)
                local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
                if espBox and t.box then t.box.Adornee = root end
                if espTracers and t.tracer then
                    t.tracer.Position = UDim2.new(0.5,0,1,0)
                    t.tracer.BackgroundColor3 = espChamsColor
                end
                if espSkeleton then
                    -- skeleton lines
                    for _, line in pairs(t.skeleton) do pcall(function() line:Destroy() end) end
                    t.skeleton = {}
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum then
                        local parts = {"Head","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg","Torso"}
                        for i=1,#parts-1 do
                            local p1 = plr.Character:FindFirstChild(parts[i])
                            local p2 = plr.Character:FindFirstChild(parts[i+1])
                            if p1 and p2 then
                                local l = Drawing and Drawing.new("Line") or nil
                                if l then
                                    local p1Pos = Camera:WorldToViewportPoint(p1.Position)
                                    local p2Pos = Camera:WorldToViewportPoint(p2.Position)
                                    l.From = Vector2.new(p1Pos.X,p1Pos.Y)
                                    l.To = Vector2.new(p2Pos.X,p2Pos.Y)
                                    l.Color = espChamsColor
                                    l.Thickness = 0.8
                                    l.Visible = true
                                    table.insert(t.skeleton,l)
                                end
                            end
                        end
                    end
                end
            else
                destroyESP(plr)
            end
        end
    end

    fovCircle.Visible = fovCircleEnabled and espEnabled

    -- Character Mods
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = speedEnabled and 100 or defaultWalkSpeed
        hum.JumpPower = jumpEnabled and 100 or defaultJumpPower
    end
    Camera.FieldOfView = fovEnabled and 120 or defaultFOV

    -- Aimlock
    if aimEnabled then
        local target = findTarget()
        if target then
            local predict = prediction and target.Velocity * 0.05 or Vector3.zero
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, target.Position + predict)
            if hardLock then
                Camera.CFrame = lookAt
            else
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, AIM_SMOOTHNESS)
            end
        end
    end
end)

print("✅ GizzVaMExploite1.0 Loaded — Aimlock + ESP + Skeleton + FOV + Character Mods + Floating Icon ready.")
