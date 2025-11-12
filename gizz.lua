-- =====================================================
-- GizzVaMExploite1.0 (Final Edition)
-- Aimlock + ESP (Line, Box, Chams, Outline, FOV Circle) + Character Mods + Effects
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
	repeat task.wait() until Players.LocalPlayer
	LocalPlayer = Players.LocalPlayer
end

-- =================== CONFIG ===================
local FOV_PX = 50
local AIM_SMOOTHNESS = 1.0
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local DEFAULT_FOV = Camera.FieldOfView

-- =================== LOAD UI ===================
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("GizzVaMExploite1.0", Color3.fromRGB(0,255,0), Enum.KeyCode.RightControl)

-- =================== TAB1: AIMLOCK ===================
local tab1 = win:Tab("AimSettings")
local aimEnabled, hardLock, prediction, firstPerson = false, false, false, false

tab1:Toggle("EnabledAim", false, function(v) aimEnabled = v end)
tab1:Toggle("AimGlue", false, function(v) hardLock = v end)
tab1:Toggle("AimPrediction", false, function(v) prediction = v end)
tab1:Toggle("AimFovFirstPerson", false, function(v)
	firstPerson = v
	Camera.CameraType = v and Enum.CameraType.Custom or Enum.CameraType.Track
end)
tab1:Textbox("AimSize", true, function(str)
	local num = tonumber(str)
	if num and num >= 10 and num <= 500 then
		FOV_PX = num
	end
end)

-- =================== TAB2: ESP ===================
local tab2 = win:Tab("EspSettings")
local espEnabled, espLine, espBoxEnabled, fovCircleEnabled, espChams, espOutline = false, true, true, true, false, false
local espChamsColor = Color3.fromRGB(0,255,0)

tab2:Toggle("EnabledEsp", false, function(v) espEnabled = v end)
tab2:Toggle("EspLine", true, function(v) espLine = v end)
tab2:Toggle("EspBox", true, function(v) espBoxEnabled = v end)
tab2:Toggle("EspFov", true, function(v) fovCircleEnabled = v end)
tab2:Toggle("EspChams", true, function(v) espChams = v end)
tab2:Toggle("EspOutline", true, function(v) espOutline = v end)
tab2:Colorpicker("EspColor", espChamsColor, function(c) espChamsColor = c end)

-- =================== TAB3: Character Mods ===================
local tab3 = win:Tab("StaticHack")
local speedEnabled, jumpEnabled, fovEnabled = false, false, false
tab3:Toggle("SpeedHack", false, function(v) speedEnabled = v end)
tab3:Toggle("JumpHack", false, function(v) jumpEnabled = v end)
tab3:Toggle("SuperFov", false, function(v) fovEnabled = v end)

-- =================== TAB4: OTHER ===================
local tab4 = win:Tab("ServerSettings")

-- efek control
local wallTrans, fireFx, antennaFx = false, false, false

tab4:Toggle("XRayObjects", false, function(v)
	wallTrans = v
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Transparency < 0.5 then
			obj.Transparency = v and 0.5 or 0
		end
	end
end)

tab4:Toggle("AntenaNeon", false, function(v)
	antennaFx = v
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr ~= LocalPlayer then
			local head = plr.Character:FindFirstChild("Head")
			if head then
				if v then
					-- Pasang antena (Bagian visual stick)
					if not head:FindFirstChild("Antenna") then
						local antenna = Instance.new("Part")
						antenna.Name = "Antenna"
						antenna.Size = Vector3.new(0.2, 4, 0.2)
						antenna.Color = Color3.fromRGB(0, 255, 0)
						antenna.Material = Enum.Material.Neon
						antenna.Anchored = false
						antenna.CanCollide = false
						antenna.CFrame = head.CFrame * CFrame.new(0, 2.5, 0)

						local weld = Instance.new("WeldConstraint")
						weld.Part0 = head
						weld.Part1 = antenna
						weld.Parent = antenna

						antenna.Parent = head
					end
				else
					-- Hapus antena jika toggle dimatikan
					for _, obj in pairs(head:GetChildren()) do
						if obj.Name == "Antenna" and obj:IsA("Part") then
							obj:Destroy()
						end
					end
				end
			end
		end
	end
end)

tab4:Toggle("EffectsFireServer", false, function(v)
	fireFx = v
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr ~= LocalPlayer then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				if v then
					if not hrp:FindFirstChild("Fire") then
						local f = Instance.new("Fire", hrp)
						f.Size = 12
						f.Heat = 10
					end
				else
					for _, f in pairs(hrp:GetChildren()) do
						if f:IsA("Fire") then f:Destroy() end
					end
				end
			end
		end
	end
end)

-- =================== ESP GUI ===================
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local espGui = playerGui:FindFirstChild("GizzESP") or Instance.new("ScreenGui")
espGui.Name = "GizzESP"
espGui.Parent = playerGui
espGui.IgnoreGuiInset = true
espGui.ResetOnSpawn = false

-- FOV Circle
local fovCircle = Instance.new("Frame", espGui)
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.Position = UDim2.new(0.5,0,0.5,0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = fovCircleEnabled
local fovCorner = Instance.new("UICorner", fovCircle)
fovCorner.CornerRadius = UDim.new(1,0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = espChamsColor
fovStroke.Thickness = 1

-- ESP storage
local visuals = {}

-- =================== FUNCTIONS ===================
local function findTarget()
	local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
	local best, bestDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
			local pos, vis = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if vis then
				local dist = (Vector2.new(pos.X,pos.Y)-Vector2.new(cx,cy)).Magnitude
				if dist < FOV_PX and dist < bestDist then
					best = plr.Character.Head
					bestDist = dist
				end
			end
		end
	end
	return best
end

local function createESP(plr)
	if visuals[plr] then return visuals[plr] end
	local data = {}
	if espLine then
		local line = Drawing.new("Line")
		line.Color = espChamsColor
		line.Thickness = 2
		line.Visible = true
		data.line = line
	end
	if espBoxEnabled then
		local box = Drawing.new("Square")
		box.Color = espChamsColor
		box.Thickness = 1
		box.Filled = false
		box.Visible = true
		data.box = box
	end
	if espChams or espOutline then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = espChamsColor
		highlight.OutlineColor = espChamsColor
		highlight.FillTransparency = espChams and 0.6 or 1
		highlight.OutlineTransparency = espOutline and 0 or 1
		highlight.Adornee = plr.Character
		highlight.Parent = espGui
		data.highlight = highlight
	end
	visuals[plr] = data
	return data
end

local function destroyESP(plr)
	if visuals[plr] then
		for _, v in pairs(visuals[plr]) do
			pcall(function() v:Remove() end)
			pcall(function() v:Destroy() end)
		end
		visuals[plr] = nil
	end
end

-- =================== MAIN LOOP ===================
RunService.RenderStepped:Connect(function()
	local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2

	fovCircle.Size = UDim2.new(0, FOV_PX*2, 0, FOV_PX*2)
	fovCircle.Visible = fovCircleEnabled and espEnabled
	fovStroke.Color = espChamsColor

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local head = plr.Character:FindFirstChild("Head")
			if hrp and head then
				if espEnabled then
					local data = createESP(plr)
					if data.line then
						local hrpPos, hrpVis = Camera:WorldToViewportPoint(hrp.Position)
						local headPos, headVis = Camera:WorldToViewportPoint(head.Position)
						if hrpVis and headVis then
							data.line.From = Vector2.new(hrpPos.X, hrpPos.Y)
							data.line.To = Vector2.new(headPos.X, headPos.Y)
							data.line.Color = espChamsColor
							data.line.Visible = true
						else
							data.line.Visible = false
						end
					end

					if data.box then
						local headPos, vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
						if vis then
							local size = 40
							data.box.Position = Vector2.new(headPos.X - size/2, headPos.Y - size/2)
							data.box.Size = Vector2.new(size, size)
							data.box.Color = espChamsColor
							data.box.Visible = true
						else
							data.box.Visible = false
						end
					end

					if data.highlight then
						data.highlight.FillColor = espChamsColor
						data.highlight.OutlineColor = espChamsColor
						data.highlight.Enabled = espChams or espOutline
					end
				else
					destroyESP(plr)
				end
			end
		end
	end

	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		local hum = LocalPlayer.Character.Humanoid
		hum.WalkSpeed = speedEnabled and 100 or DEFAULT_WALKSPEED
		hum.JumpPower = jumpEnabled and 100 or DEFAULT_JUMPPOWER
	end
	Camera.FieldOfView = fovEnabled and 120 or DEFAULT_FOV

	if aimEnabled then
		local target = findTarget()
		if target then
			local predict = prediction and target.Velocity*0.05 or Vector3.zero
			local lookAt = CFrame.lookAt(Camera.CFrame.Position, target.Position + predict)
			if hardLock then
				Camera.CFrame = lookAt
			else
				Camera.CFrame = Camera.CFrame:Lerp(lookAt, AIM_SMOOTHNESS)
			end
		end
	end
end)

print("✅ GizzVaMExploite1.0 Final Edition Loaded — ESP + Aimlock + Character Mods + Antenna FX")
