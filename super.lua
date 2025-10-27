--------------------------------------------------------------------
-- GizzVaMToolsX (RAPIH) — Full Player ESP + UI (Rayfield)
-- Diperapikan: spasi, definisi, nama fungsi/variabel, tab visual
-- Perubahan: Box size Drawing ESP mengikuti tinggi avatar + Secondary Color picker
--------------------------------------------------------------------

-- 🌟 Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- 🌟 Create Window
local Window = Rayfield:CreateWindow({
    Name = "GizzVaMToolsX",
    LoadingTitle = "GIZZ ESP Control",
    LoadingSubtitle = "Non-Exploit Visuals",
    ConfigurationSaving = { Enabled = true, FolderName = "GIZZ_UI", FileName = "VisualConfig" },
    Discord = { Enabled = false },
    KeySystem = false
})

-- 🟢 GLOBALS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local mouse = LocalPlayer and LocalPlayer:GetMouse() or nil

-- Visual / Gameplay
local ESPEnabled_Drawing = false   -- FullESP (Drawing library)
local ESPEnabled_Box = false       -- BoxESP (BoxHandleAdornment)
local ESPColor = Color3.fromRGB(0, 255, 100)
local SecondaryColor = Color3.fromRGB(255, 255, 0) -- baru: color kedua untuk health/outline

local TransparencyEnabled = false
local JumpEnabled = false
local JumpPowerValue = 50
local PlayerSpeed = 16

-- Others / Features
local AutoTeleportEnabled = false
local AutoTeleportInterval = 2
local _autoTeleportTimer = 0

_G.PlayMode = "Manual"
_G.LockScreen = false
_G.AutoFly = false
_G.AimbotEnabled = false

-- Storage tables
local DrawingESPData = {}
local BoxESPInstances = {}

--------------------------------------------------------------------
-- Utility: safe pcall wrapper
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

--------------------------------------------------------------------
-- DRAWING-BASED ESP (FullESP)
local okDrawing, DrawingLib = pcall(function() return Drawing end)
local DrawingAvailable = okDrawing and DrawingLib ~= nil

local function createDrawingESP(player)
    if not DrawingAvailable then return end
    if player == LocalPlayer then return end
    if DrawingESPData[player] then return end

    DrawingESPData[player] = {
        box = DrawingLib.new("Square"),
        line = DrawingLib.new("Line"),
        name = DrawingLib.new("Text"),
        health = DrawingLib.new("Line"),
        dist = DrawingLib.new("Text"),
        head = DrawingLib.new("Circle")
    }

    -- Box
    local box = DrawingESPData[player].box
    box.Thickness = 1.5
    box.Color = ESPColor
    box.Filled = false
    box.Visible = false

    -- Line (Tracer)
    local line = DrawingESPData[player].line
    line.Thickness = 1.5
    line.Color = ESPColor
    line.Visible = false

    -- Name
    local nameText = DrawingESPData[player].name
    nameText.Size = 14
    nameText.Center = true
    nameText.Color = ESPColor
    nameText.Outline = true
    nameText.Visible = false

    -- Health bar
    local health = DrawingESPData[player].health
    health.Thickness = 3
    health.Color = SecondaryColor -- gunakan secondary color untuk health
    health.Visible = false

    -- Distance
    local distText = DrawingESPData[player].dist
    distText.Size = 13
    distText.Center = true
    distText.Color = Color3.fromRGB(200, 200, 200)
    distText.Outline = true
    distText.Visible = false

    -- Head dot
    local headDot = DrawingESPData[player].head
    headDot.Thickness = 2
    headDot.NumSides = 20
    headDot.Radius = 4
    headDot.Filled = true
    headDot.Color = ESPColor
    headDot.Visible = false
end

local function removeDrawingESP(player)
    local data = DrawingESPData[player]
    if data then
        for _, obj in pairs(data) do
            safe(function() obj:Remove() end)
        end
        DrawingESPData[player] = nil
    end
end

-- helper: hitung tinggi karakter (head - root) fallback ke 6 jika tidak tersedia
local function getCharacterHeight(character)
    if not character then return 6 end
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    if head and root then
        local h = (head.Position - root.Position).Magnitude
        -- sedikit penyesuaian agar proporsional dengan ukuran box yang diinginkan
        return math.clamp(h * 2.2, 4, 12)
    end
    return 6
end

local function updateDrawingESPs()
    if not DrawingAvailable then return end
    if not ESPEnabled_Drawing then
        for _, data in pairs(DrawingESPData) do
            for _, obj in pairs(data) do obj.Visible = false end
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local root = player.Character.HumanoidRootPart
            local head = player.Character.Head

            local pos3, onScreen = Camera:WorldToViewportPoint(root.Position)
            if not onScreen then
                -- jika tidak on screen, sembunyikan elemen (mengurangi spam)
                if DrawingESPData[player] then
                    for _, obj in pairs(DrawingESPData[player]) do obj.Visible = false end
                end
                continue
            end

            -- ukuran sekarang disesuaikan dengan tinggi karakter
            local charHeight = getCharacterHeight(player.Character)
            local distance = (root.Position - Camera.CFrame.Position).Magnitude
            -- scale tambahan berdasarkan jarak agar box tetap proporsional di layar
            local distanceScale = math.clamp(1000 / math.max(distance, 1), 0.6, 3)
            local width = charHeight * 0.5 * distanceScale
            local height = charHeight * 1.6 * distanceScale

            local data = DrawingESPData[player]
            if not data then createDrawingESP(player); data = DrawingESPData[player] end
            if not data then continue end

            local x, y = pos3.X, pos3.Y

            -- Box
            data.box.Visible = true
            data.box.Size = Vector2.new(width, height)
            data.box.Position = Vector2.new(x - width / 2, y - height / 2)
            data.box.Color = ESPColor

            -- Tracer Line
            data.line.Visible = true
            data.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            data.line.To = Vector2.new(x, y)
            data.line.Color = ESPColor

            -- Name
            data.name.Visible = true
            data.name.Text = player.DisplayName
            data.name.Position = Vector2.new(x, y - height / 1.2)
            data.name.Color = ESPColor

            -- Health
            if humanoid then
                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                data.health.Visible = true
                data.health.From = Vector2.new(x - width / 2 - 5, y + height / 2)
                data.health.To = Vector2.new(x - width / 2 - 5, y + height / 2 - (height * healthPercent))
                data.health.Color = SecondaryColor
            else
                data.health.Visible = false
            end

            -- Distance
            data.dist.Visible = true
            data.dist.Text = string.format("%.0f m", distance)
            data.dist.Position = Vector2.new(x, y + height / 1.5)

            -- Head Dot
            local headScreen = Camera:WorldToViewportPoint(head.Position)
            data.head.Visible = true
            data.head.Position = Vector2.new(headScreen.X, headScreen.Y)
            data.head.Color = ESPColor
        else
            -- Hide / cleanup for players without valid chars
            if DrawingESPData[player] then
                for _, obj in pairs(DrawingESPData[player]) do obj.Visible = false end
            end
        end
    end
end

--------------------------------------------------------------------
-- BOX-BASED ESP (BoxHandleAdornment)
local function createBoxESP(player)
    if not player then return end
    if BoxESPInstances[player] then return end
    if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return end

    local ok, box = pcall(function()
        local b = Instance.new("BoxHandleAdornment")
        -- atur ukuran berdasarkan tinggi karakter jika tersedia
        local charHeight = 6
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if head and root then
                charHeight = math.clamp((head.Position - root.Position).Magnitude * 2.2, 4, 12)
            end
        end
        b.Size = Vector3.new(4, charHeight, 2)
        b.Color3 = ESPColor
        b.Transparency = 0.3
        b.ZIndex = 0
        b.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
        b.AlwaysOnTop = true
        b.Parent = game:GetService("CoreGui")
        return b
    end)

    if ok and box then
        BoxESPInstances[player] = box
    end
end

local function removeBoxESP(player)
    if BoxESPInstances[player] then
        safe(function() BoxESPInstances[player]:Destroy() end)
        BoxESPInstances[player] = nil
    end
end

local function updateAllBoxESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if ESPEnabled_Box then
                createBoxESP(p)
            else
                removeBoxESP(p)
            end
        end
    end
end

--------------------------------------------------------------------
-- PLAYER TRANSPARENCY HELPERS
local function setTransparency(player, transparency)
    if not player or not player.Character then return end
    for _, part in pairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = transparency
        end
    end
end

local function updateTransparencyAll()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if TransparencyEnabled then
                setTransparency(p, 0.5)
            else
                setTransparency(p, 0)
            end
        end
    end
end

--------------------------------------------------------------------
-- SERVER DROPDOWN
local ServerPlayerDropdown = Window:CreateTab("Servers", 4483362458):CreateDropdown({
    Name = "Player List",
    Options = {},
    Flag = "ServerPlayerList",
    Callback = function(Value) end
})

local function refreshServerDropdown()
    local opts = {}
    for _, p in pairs(Players:GetPlayers()) do table.insert(opts, p.Name) end
    pcall(function()
        if ServerPlayerDropdown.RefreshOptions then
            ServerPlayerDropdown:RefreshOptions(opts)
        else
            ServerPlayerDropdown.Options = opts
        end
    end)
end

Players.PlayerAdded:Connect(refreshServerDropdown)
Players.PlayerRemoving:Connect(refreshServerDropdown)
refreshServerDropdown()

--------------------------------------------------------------------
-- HELPERS
local function getRandomTarget()
    local candidates = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
           and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChild("Head") then
            table.insert(candidates, p)
        end
    end
    if #candidates == 0 then return nil end
    return candidates[math.random(1, #candidates)]
end

--------------------------------------------------------------------
-- UI: Tabs & Controls
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local GameTab   = Window:CreateTab("Game",     4483362458)
local OthersTab = Window:CreateTab("Others",   4483362458)

-- Visual Tab: Drawing FullESP toggle
VisualTab:CreateToggle({
    Name = "FullESP (All Types + Wall Penetration)",
    CurrentValue = false,
    Flag = "FullESP",
    Callback = function(Value)
        ESPEnabled_Drawing = Value
        if Value then
            for _, player in pairs(Players:GetPlayers()) do createDrawingESP(player) end
            Rayfield:Notify({ Title = "ESP Activated", Content = "All ESP visible through walls ✅", Duration = 3, Image = 4483362458 })
        else
            for _, player in pairs(Players:GetPlayers()) do removeDrawingESP(player) end
            Rayfield:Notify({ Title = "ESP Disabled", Content = "All ESP removed 🚫", Duration = 3, Image = 4483362458 })
        end
    end
})

-- Visual Tab: BoxESP toggle
VisualTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Flag = "BoxESP",
    Callback = function(Value)
        ESPEnabled_Box = Value
        updateAllBoxESP()
        Rayfield:Notify({ Title = "ESP", Content = Value and "Box ESP Enabled" or "Box ESP Disabled", Duration = 2, Image = 4483362458 })
    end
})

VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = ESPColor,
    Flag = "ESPColor",
    Callback = function(Color)
        ESPColor = Color
        for _, box in pairs(BoxESPInstances) do safe(function() box.Color3 = Color end) end
        pcall(function() if DrawingAvailable and fovCircle then fovCircle.Color = ESPColor end end)
        Rayfield:Notify({ Title = "ESP Color", Content = "Changed", Duration = 2, Image = 4483362458 })
    end
})

-- Visual Tab: Secondary Color picker (baru)
VisualTab:CreateColorPicker({
    Name = "Secondary Color (Health / Outline)",
    Color = SecondaryColor,
    Flag = "ESPSecondaryColor",
    Callback = function(Color)
        SecondaryColor = Color
        -- update current drawing health colors
        for _, data in pairs(DrawingESPData) do
            if data.health then safe(function() data.health.Color = SecondaryColor end) end
        end
        Rayfield:Notify({ Title = "ESP Secondary Color", Content = "Changed", Duration = 2, Image = 4483362458 })
    end
})

--------------------------------------------------------------------
-- GAME Tab Controls
GameTab:CreateToggle({
    Name = "Hide All Players",
    CurrentValue = false,
    Flag = "Transparency",
    Callback = function(Value)
        TransparencyEnabled = Value
        updateTransparencyAll()
        Rayfield:Notify({ Title = "Players", Content = Value and "Hidden" or "Visible", Duration = 2, Image = 4483362458 })
    end
})

GameTab:CreateSlider({
    Name = "Camera FOV",
    Range = {60, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = Camera.FieldOfView,
    Flag = "PlayerFOV",
    Callback = function(Value)
        Camera.FieldOfView = Value
        Rayfield:Notify({ Title = "FOV", Content = Value, Duration = 2, Image = 4483362458 })
    end
})

GameTab:CreateToggle({
    Name = "Enable Jump",
    CurrentValue = false,
    Flag = "JumpToggle",
    Callback = function(Value)
        JumpEnabled = Value
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Value and JumpPowerValue or 50 end
    end
})

GameTab:CreateSlider({
    Name = "Jump Power",
    Range = {40, 120},
    Increment = 1,
    Suffix = " power",
    CurrentValue = JumpPowerValue,
    Flag = "JumpPower",
    Callback = function(Value)
        JumpPowerValue = Value
        if JumpEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = Value end
        end
    end
})

GameTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 120},
    Increment = 1,
    Suffix = " speed",
    CurrentValue = PlayerSpeed,
    Flag = "PlayerSpeed",
    Callback = function(Value)
        PlayerSpeed = Value
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Value end
        end
    end
})

GameTab:CreateSlider({
    Name = "Brightness",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = Lighting.Brightness,
    Flag = "Brightness",
    Callback = function(Value) Lighting.Brightness = Value end
})

--------------------------------------------------------------------
-- OTHERS Tab Controls
OthersTab:CreateToggle({
    Name = "AutoTeleport",
    CurrentValue = false,
    Flag = "AutoTeleportToggle",
    Callback = function(Value)
        AutoTeleportEnabled = Value
        _autoTeleportTimer = 0
        Rayfield:Notify({ Title = "AutoTeleport", Content = Value and "Enabled" or "Disabled", Duration = 2, Image = 4483362458 })
    end
})

OthersTab:CreateToggle({
    Name = "Aimbot (Head)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        _G.AimbotEnabled = Value
        Rayfield:Notify({ Title = "Aimbot", Content = Value and "Head Lock Enabled" or "Disabled", Duration = 2, Image = 4483362458 })
    end
})

OthersTab:CreateSlider({
    Name = "Seconds",
    Range = {0.5, 10},
    Increment = 0.5,
    Suffix = " s",
    CurrentValue = AutoTeleportInterval,
    Flag = "AutoTeleportInterval",
    Callback = function(Value) AutoTeleportInterval = Value end
})

--------------------------------------------------------------------
-- AIMBOT + FOV (existing code preserved, formatting only)
local LegitAimbotEnabled = false
local FOVAimbotEnabled = false
local AimbotSmooth = 0.18
local AimbotFOVSize = 150
local fovCircle = nil

if DrawingAvailable then
    safe(function()
        fovCircle = DrawingLib.new("Circle")
        fovCircle.Visible = false
        fovCircle.Filled = false
        fovCircle.Transparency = 1
        fovCircle.Thickness = 2
        fovCircle.Color = ESPColor
    end)
end

local function getScreenCenter()
    local vs = Camera.ViewportSize
    return Vector2.new(vs.X / 2, vs.Y / 2)
end

local function smoothLook(currentCFrame, targetPosition, smooth)
    local camPos = currentCFrame.Position
    local targetCF = CFrame.new(camPos, targetPosition)
    if smooth <= 0 then return targetCF end
    local curLook = currentCFrame.LookVector
    local tgtLook = (targetPosition - camPos).Unit
    local look = (curLook:Lerp(tgtLook, math.clamp(1 - smooth, 0, 1))).Unit
    return CFrame.new(camPos, camPos + look)
end

local function doLegitAim(targetHead, smooth)
    if not targetHead or not LocalPlayer.Character then return end
    safe(function()
        Camera.CFrame = smoothLook(Camera.CFrame, targetHead.Position, smooth)
    end)
end

local function getPlayersInFOV(radius)
    local center = getScreenCenter()
    local results = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local svp, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local screenPos = Vector2.new(svp.X, svp.Y)
                local d = (screenPos - center).Magnitude
                if d <= radius then table.insert(results, {player = p, dist = d, screen = screenPos}) end
            end
        end
    end
    table.sort(results, function(a,b) return a.dist < b.dist end)
    return results
end

local function doFovAim()
    local inFov = getPlayersInFOV(AimbotFOVSize)
    if #inFov == 0 then return end
    local best = inFov[1].player
    if best and best.Character and best.Character:FindFirstChild("Head") then
        doLegitAim(best.Character.Head, AimbotSmooth)
    end
end

OthersTab:CreateToggle({
    Name = "Aimbot Legit (Head)",
    CurrentValue = false,
    Flag = "AimbotLegitToggle",
    Callback = function(Value)
        LegitAimbotEnabled = Value
        Rayfield:Notify({ Title = "Aimbot Legit", Content = Value and "Enabled" or "Disabled", Duration = 2, Image = 4483362458 })
    end
})

OthersTab:CreateSlider({
    Name = "Legit Smooth",
    Range = {0, 0.9},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = AimbotSmooth,
    Flag = "AimbotLegitSmooth",
    Callback = function(Value) AimbotSmooth = Value end
})

OthersTab:CreateToggle({
    Name = "Aimbot (FOV)",
    CurrentValue = false,
    Flag = "AimbotFOVToggle",
    Callback = function(Value)
        FOVAimbotEnabled = Value
        if fovCircle then safe(function() fovCircle.Visible = Value end) end
        Rayfield:Notify({ Title = "Aimbot FOV", Content = Value and "Enabled" or "Disabled", Duration = 2, Image = 4483362458 })
    end
})

OthersTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 800},
    Increment = 5,
    Suffix = " px",
    CurrentValue = AimbotFOVSize,
    Flag = "AimbotFOVSize",
    Callback = function(Value) AimbotFOVSize = Value end
})

--------------------------------------------------------------------
-- MAIN LOOP
RunService:BindToRenderStep("GizzVaMToolsX_Main", Enum.RenderPriority.Camera.Value + 1, function(delta)
    -- FOV Circle draw/update
    if fovCircle then
        local center = getScreenCenter()
        safe(function()
            fovCircle.Position = center
            fovCircle.Radius = AimbotFOVSize
            fovCircle.Color = ESPColor
            fovCircle.Visible = FOVAimbotEnabled
        end)
    end

    -- Legit Aim (closest by world distance)
    if LegitAimbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        local humRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso")
        if humRoot then
            local best, bestDist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local dist = (p.Character.Head.Position - humRoot.Position).Magnitude
                    if dist < bestDist then best, bestDist = p, dist end
                end
            end
            if best and best.Character and best.Character:FindFirstChild("Head") then
                doLegitAim(best.Character.Head, AimbotSmooth)
            end
        end
    end

    -- FOV Aim
    if FOVAimbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        doFovAim()
    end

    -- Drawing ESP Update
    updateDrawingESPs()

    -- Box ESP Update (ensures instances follow characters)
    updateAllBoxESP()

    -- Local player features (AutoTeleport / AutoFly / LockScreen / Classic aimbot)
    if LocalPlayer.Character then
        local humRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humRoot and hum then
            -- AutoTeleport
            if AutoTeleportEnabled then
                _autoTeleportTimer = _autoTeleportTimer + delta
                if _autoTeleportTimer >= AutoTeleportInterval then
                    _autoTeleportTimer = 0
                    local target = getRandomTarget()
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        safe(function() humRoot.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0) end)
                    end
                end
            end

            -- AutoFly
            if _G.AutoFly then safe(function() humRoot.CFrame = humRoot.CFrame + Vector3.new(0, 0.3, 0) end) end

            -- LockScreen
            if _G.LockScreen then
                local camCF = Camera.CFrame
                safe(function() humRoot.CFrame = CFrame.new(humRoot.Position, humRoot.Position + camCF.LookVector) end)
                hum.WalkSpeed = 0
            else
                hum.WalkSpeed = PlayerSpeed
            end

            -- Classic Aimbot (original)
            if _G.AimbotEnabled then
                local closest, bestDist = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local dist = (p.Character.Head.Position - humRoot.Position).Magnitude
                        if dist < bestDist then closest, bestDist = p, dist end
                    end
                end
                if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                    safe(function()
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
                    end)
                end
            end
        end
    end
end)

--------------------------------------------------------------------
-- Player add/remove handling
Players.PlayerAdded:Connect(function(plr)
    refreshServerDropdown()
    if ESPEnabled_Drawing then createDrawingESP(plr) end
    if ESPEnabled_Box then createBoxESP(plr) end
end)

Players.PlayerRemoving:Connect(function(plr)
    refreshServerDropdown()
    removeDrawingESP(plr)
    removeBoxESP(plr)
end)

--------------------------------------------------------------------
-- Notification
Rayfield:Notify({
    Title = "GizzVaMToolsX",
    Content = "Loaded: ESP (AlwaysOnTop), AutoTeleport, Aimbot (Head) ✅",
    Duration = 5,
    Image = 4483362458
})

print("✅ GizzVaMToolsX fully loaded (rapi).")
--------------------------------------------------------------------
