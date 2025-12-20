-- Aimbot Hard Lock tanpa smooth
-- Langsung lock ke head tanpa delay

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Settings (Edit di sini untuk custom FOV)
local FOV_SIZE = 60  -- Ubah angka ini untuk custom FOV
local MAX_DISTANCE = 500
local HARD_LOCK = true

-- Variables
local CurrentTarget = nil
local FOVCircle

-- Buat FOV Circle
FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.3
FOVCircle.NumSides = 64
FOVCircle.Radius = FOV_SIZE

-- Update FOV Circle position (tetap di tengah)
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
end)

-- Fungsi untuk dapatkan posisi head
local function GetHeadPosition(character)
    if not character then return nil end
    local head = character:FindFirstChild("Head")
    return head and head.Position or nil
end

-- Fungsi cari target terbaik dalam FOV
local function FindBestTarget()
    if not LocalPlayer.Character then return nil end
    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    local bestTarget = nil
    local closestDistance = math.huge
    local localPos = humanoidRootPart.Position
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local headPos = GetHeadPosition(character)
        if not headPos then continue end
        
        local distance = (localPos - headPos).Magnitude
        if distance > MAX_DISTANCE then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
        if not onScreen then continue end
        
        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
        local fovDistance = (screenVec - center).Magnitude
        
        if fovDistance <= FOV_SIZE then
            if distance < closestDistance then
                closestDistance = distance
                bestTarget = {
                    player = player,
                    position = headPos,
                    character = character,
                    screenPos = screenVec,
                    distance = distance
                }
            end
        end
    end
    
    return bestTarget
end

-- Aimbot logic hard lock tanpa smooth
local function AimbotLogic()
    if not LocalPlayer.Character then
        CurrentTarget = nil
        return
    end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        CurrentTarget = nil
        return
    end
    
    -- Jika hard lock aktif dan target masih valid, pertahankan
    if HARD_LOCK and CurrentTarget then
        local targetChar = CurrentTarget.character
        if targetChar and targetChar:FindFirstChild("Humanoid") then
            local targetHumanoid = targetChar:FindFirstChild("Humanoid")
            if targetHumanoid and targetHumanoid.Health > 0 then
                local headPos = GetHeadPosition(targetChar)
                if headPos then
                    -- Cek apakah target masih dalam FOV
                    local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
                    if onScreen then
                        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                        local fovDistance = (screenVec - center).Magnitude
                        
                        if fovDistance <= FOV_SIZE then
                            -- Target masih dalam FOV, lock langsung tanpa smooth
                            local cameraPos = Camera.CFrame.Position
                            local direction = (headPos - cameraPos).Unit
                            local targetCFrame = CFrame.new(cameraPos, cameraPos + direction)
                            Camera.CFrame = targetCFrame  -- Tidak ada lerp/smooth
                            return true
                        end
                    end
                end
            end
        end
        -- Target tidak valid lagi
        CurrentTarget = nil
    end
    
    -- Cari target baru
    local target = FindBestTarget()
    if target then
        CurrentTarget = target
        
        local cameraPos = Camera.CFrame.Position
        local direction = (target.position - cameraPos).Unit
        local targetCFrame = CFrame.new(cameraPos, cameraPos + direction)
        Camera.CFrame = targetCFrame  -- Tidak ada lerp/smooth
        return true
    else
        CurrentTarget = nil
    end
    
    return false
end

-- Update setiap frame
RunService.RenderStepped:Connect(function()
    pcall(function()
        AimbotLogic()
    end)
end)

-- Tampilkan status
print("ðŸŽ¯")
print("ðSize: ")
print("ðŸ”’ HardON")
print("âš¡")
print("ðŸ“ : " .. MAX_DISTANCE)
print("ðŸ’¡")
