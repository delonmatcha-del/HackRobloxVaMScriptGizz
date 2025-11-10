-- ==========================================================
-- 💠 FSSY-X ImGUI Framework (Extreme Modern Edition)
-- Author: Fssy | 2025 Ultimate UI Library
-- Inspired by Elerium / Rayfield / Vinzo / ImGui
-- ==========================================================

local FSSYX = {}
FSSYX.__index = FSSYX

-- Roblox services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ==========================================================
-- 🔮 Root GUI + Background Particle (Rain Glow)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FSSY_X_ImGui_Ultimate"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- 🌧️ Neon Rain Effect
task.spawn(function()
	local rainLayer = Instance.new("Frame")
	rainLayer.Size = UDim2.new(1, 0, 1, 0)
	rainLayer.BackgroundTransparency = 1
	rainLayer.ZIndex = 0
	rainLayer.Parent = ScreenGui

	while true do
		local drop = Instance.new("Frame")
		drop.Size = UDim2.new(0, 2, 0, math.random(8, 20))
		drop.Position = UDim2.new(math.random(), 0, -0.1, 0)
		drop.BackgroundColor3 = Color3.fromRGB(150, 80, 255)
		drop.BorderSizePixel = 0
		drop.ZIndex = 0
		local glow = Instance.new("UIStroke", drop)
		glow.Thickness = 1.8
		glow.Color = Color3.fromRGB(190, 120, 255)
		glow.Transparency = 0.4
		drop.Parent = rainLayer
		TweenService:Create(drop, TweenInfo.new(1.8, Enum.EasingStyle.Linear), {
			Position = UDim2.new(drop.Position.X.Scale, 0, 1.2, 0),
			BackgroundTransparency = 1
		}):Play()
		game.Debris:AddItem(drop, 2)
		task.wait(0.05)
	end
end)

-- ==========================================================
-- 🧩 Utility Functions
-- ==========================================================
local function createCorner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
end

local function createGlow(p, col, t)
	local s = Instance.new("UIStroke")
	s.Thickness = t or 1.6
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = col or Color3.fromRGB(170, 120, 255)
	s.Transparency = 0.35
	s.Parent = p
end

local function tween(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.25, Enum.EasingStyle.Sine), p):Play()
end

-- ==========================================================
-- 🪟 Create Main Window
-- ==========================================================
function FSSYX:CreateWindow(title)
	local self = setmetatable({}, FSSYX)
	self.tabs = {}
	self.activeTab = nil
	self.callbacks = {}

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 640, 0, 420)
	main.Position = UDim2.new(0.5, -320, 0.5, -210)
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = true
	main.Parent = ScreenGui
	createCorner(main)
	createGlow(main)

	local titlebar = Instance.new("TextLabel")
	titlebar.Size = UDim2.new(1, 0, 0, 38)
	titlebar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	titlebar.Text = title or "💠 FSSY-X Ultimate Framework"
	titlebar.Font = Enum.Font.GothamBold
	titlebar.TextSize = 16
	titlebar.TextColor3 = Color3.fromRGB(255, 255, 255)
	titlebar.Parent = main
	createCorner(titlebar)
	createGlow(titlebar, Color3.fromRGB(150, 100, 255))

	-- sidebar
	local sidebar = Instance.new("Frame")
	sidebar.Size = UDim2.new(0, 130, 1, -38)
	sidebar.Position = UDim2.new(0, 0, 0, 38)
	sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	sidebar.Parent = main
	createCorner(sidebar)
	createGlow(sidebar)

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 6)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = sidebar

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -140, 1, -48)
	content.Position = UDim2.new(0, 140, 0, 48)
	content.BackgroundTransparency = 1
	content.Parent = main

	self.main = main
	self.sidebar = sidebar
	self.content = content
	return self
end

-- ==========================================================
-- 📂 Tabs
-- ==========================================================
function FSSYX:AddTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 28)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = self.sidebar
	createCorner(btn)
	createGlow(btn)

	local frame = Instance.new("ScrollingFrame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.ScrollBarThickness = 4
	frame.CanvasSize = UDim2.new(0, 0, 0, 0)
	frame.Parent = self.content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame

	self.tabs[name] = frame

	btn.MouseButton1Click:Connect(function()
		for _, t in pairs(self.tabs) do
			t.Visible = false
		end
		frame.Visible = true
		tween(btn, {BackgroundColor3 = Color3.fromRGB(90, 60, 130)}, 0.15)
	end)

	if not self.activeTab then
		self.activeTab = name
		frame.Visible = true
	end

	return frame
end

-- ==========================================================
-- 🟢 Switch / Checkbox
-- ==========================================================
function FSSYX:AddSwitch(tab, label, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 32)
	holder.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	holder.Parent = tab
	createCorner(holder)
	createGlow(holder)

	local txt = Instance.new("TextLabel")
	txt.Text = label
	txt.Size = UDim2.new(1, -40, 1, 0)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(255, 255, 255)
	txt.Font = Enum.Font.Gotham
	txt.TextSize = 14
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.Position = UDim2.new(0, 8, 0, 0)
	txt.Parent = holder

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 28, 0, 28)
	toggle.Position = UDim2.new(1, -34, 0.5, -14)
	toggle.BackgroundColor3 = default and Color3.fromRGB(100, 80, 255) or Color3.fromRGB(70, 70, 90)
	toggle.Text = ""
	toggle.Parent = holder
	createCorner(toggle, 6)
	createGlow(toggle)

	local state = default or false
	toggle.MouseButton1Click:Connect(function()
		state = not state
		tween(toggle, {BackgroundColor3 = state and Color3.fromRGB(130, 100, 255) or Color3.fromRGB(70, 70, 90)}, 0.2)
		if callback then callback(state) end
	end)
end

-- ==========================================================
-- 🔘 Button
-- ==========================================================
function FSSYX:AddButton(tab, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = tab
	createCorner(btn)
	createGlow(btn)
	btn.MouseButton1Click:Connect(function()
		tween(btn, {BackgroundColor3 = Color3.fromRGB(100, 80, 200)}, 0.1)
		task.wait(0.1)
		tween(btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 65)}, 0.2)
		if callback then callback() end
	end)
end

-- ==========================================================
-- 🎚️ Slider
-- ==========================================================
function FSSYX:AddSlider(tab, label, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 50)
	frame.BackgroundTransparency = 1
	frame.Parent = tab

	local lbl = Instance.new("TextLabel")
	lbl.Text = label .. ": " .. tostring(default)
	lbl.Size = UDim2.new(1, 0, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.Parent = frame

	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1, 0, 0, 8)
	slider.Position = UDim2.new(0, 0, 0, 26)
	slider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	slider.Parent = frame
	createCorner(slider)
	createGlow(slider)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(130, 100, 255)
	fill.Parent = slider
	createCorner(fill)
	createGlow(fill)

	local dragging = false
	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging then
			local pos = math.clamp((UserInputService:GetMouseLocation().X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(pos, 0, 1, 0)
			local val = math.floor(min + (max - min) * pos)
			lbl.Text = label .. ": " .. val
			if callback then callback(val) end
		end
	end)
end

-- ==========================================================
-- 🟣 Dropdown (with spin animation)
-- ==========================================================
function FSSYX:AddDropdown(tab, label, options, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Text = label .. ": " .. tostring(options[1])
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = tab
	createCorner(btn)
	createGlow(btn)

	local open = false
	local dropFrame

	btn.MouseButton1Click:Connect(function()
		if open then
			open = false
			if dropFrame then dropFrame:Destroy() end
			return
		end
		open = true
		dropFrame = Instance.new("Frame")
		dropFrame.Size = UDim2.new(1, -10, 0, #options * 26)
		dropFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
		dropFrame.Parent = tab
		createCorner(dropFrame)
		createGlow(dropFrame)
		local list = Instance.new("UIListLayout", dropFrame)
		list.Padding = UDim.new(0, 4)

		for _, opt in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Size = UDim2.new(1, 0, 0, 24)
			optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
			optBtn.Text = opt
			optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			optBtn.Font = Enum.Font.Gotham
			optBtn.TextSize = 13
			optBtn.Parent = dropFrame
			createCorner(optBtn)
			optBtn.MouseButton1Click:Connect(function()
				btn.Text = label .. ": " .. opt
				if callback then callback(opt) end
				dropFrame:Destroy()
				open = false
			end)
		end
	end)
end

-- ==========================================================
-- 🎨 Color Picker
-- ==========================================================
function FSSYX:AddColorPicker(tab, label, default, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -10, 0, 30)
	b.Text = label
	b.BackgroundColor3 = default or Color3.fromRGB(100, 100, 255)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.Parent = tab
	createCorner(b)
	createGlow(b)
	b.MouseButton1Click:Connect(function()
		local c = Color3.fromHSV(math.random(), 1, 1)
		tween(b, {BackgroundColor3 = c}, 0.2)
		if callback then callback(c) end
	end)
end

-- ==========================================================
-- 🔍 Search Box
-- ==========================================================
function FSSYX:AddSearchBox(tab, placeholder, callback)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -10, 0, 30)
	box.PlaceholderText = placeholder or "Search..."
	box.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.Parent = tab
	createCorner(box)
	createGlow(box)
	box:GetPropertyChangedSignal("Text"):Connect(function()
		if callback then callback(box.Text) end
	end)
end

-- ==========================================================
-- 🔔 Notification
-- ==========================================================
function FSSYX:Notify(msg, duration)
	local n = Instance.new("TextLabel")
	n.Text = msg
	n.Size = UDim2.new(0, 250, 0, 30)
	n.Position = UDim2.new(1, -270, 1, -60)
	n.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
	n.TextColor3 = Color3.fromRGB(255, 255, 255)
	n.Font = Enum.Font.Gotham
	n.TextSize = 14
	n.Parent = ScreenGui
	createCorner(n)
	createGlow(n)
	tween(n, {Position = UDim2.new(1, -270, 1, -110)}, 0.35)
	task.wait(duration or 3)
	tween(n, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
	task.wait(0.3)
	n:Destroy()
end

-- ==========================================================
-- 🧠 Console Execute
-- ==========================================================
function FSSYX:AddConsole(tab)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -10, 0, 100)
	box.PlaceholderText = "Type Lua command..."
	box.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Code
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = Enum.TextYAlignment.Top
	box.MultiLine = true
	box.TextSize = 14
	box.ClearTextOnFocus = false
	box.Parent = tab
	createCorner(box)
	createGlow(box)

	local runBtn = Instance.new("TextButton")
	runBtn.Size = UDim2.new(1, -10, 0, 28)
	runBtn.Text = "Execute"
	runBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 100)
	runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	runBtn.Font = Enum.Font.GothamBold
	runBtn.TextSize = 14
	runBtn.Parent = tab
	createCorner(runBtn)
	createGlow(runBtn)
	runBtn.MouseButton1Click:Connect(function()
		local code = box.Text
		if code and #code > 0 then
			loadstring(code)()
			self:Notify("✅ Executed successfully!", 2)
		else
			self:Notify("⚠️ Empty script!", 2)
		end
	end)
end

return setmetatable({}, {__index = FSSYX})
