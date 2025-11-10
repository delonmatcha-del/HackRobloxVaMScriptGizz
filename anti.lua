-- ==========================================================
-- 💠 FSSY-X ImGUI Framework (Inspired by Elerium)
-- Author: Fssy | 2025 Edition
-- ==========================================================

local FSSYX = {}
FSSYX.__index = FSSYX

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ✅ GUI Root
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FSSY_X_ImGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- 🔲 Utility
local function createCorner(radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	return corner
end

local function tween(object, properties, time)
	TweenService:Create(object, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), properties):Play()
end

-- 💠 Window creation
function FSSYX:CreateWindow(title)
	local self = setmetatable({}, FSSYX)
	self.title = title or "FSSY-X ImGui"
	self.objects = {}
	self.callbacks = {}

	-- FRAME
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 400, 0, 320)
	frame.Position = UDim2.new(0.5, -200, 0.5, -160)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	createCorner(8).Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = self.title
	titleLabel.Size = UDim2.new(1, 0, 0, 35)
	titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.Parent = frame
	createCorner(8).Parent = titleLabel

	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, -10, 1, -45)
	content.Position = UDim2.new(0, 5, 0, 40)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 4
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	frame.Parent = ScreenGui
	self.frame = frame
	self.content = content

	return self
end

-- 🟩 Switch
function FSSYX:AddSwitch(name, default, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 30)
	button.Text = name .. " [" .. (default and "ON" or "OFF") .. "]"
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = self.content
	createCorner(6).Parent = button

	local state = default or false
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = name .. " [" .. (state and "ON" or "OFF") .. "]"
		tween(button, {BackgroundColor3 = state and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(40, 40, 40)}, 0.15)
		if callback then callback(state) end
	end)
end

-- 🟦 Slider
function FSSYX:AddSlider(name, min, max, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 50)
	holder.BackgroundTransparency = 1
	holder.Parent = self.content

	local label = Instance.new("TextLabel")
	label.Text = name .. ": " .. tostring(default)
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = holder

	local slider = Instance.new("TextButton")
	slider.Size = UDim2.new(1, 0, 0, 10)
	slider.Position = UDim2.new(0, 0, 0, 25)
	slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	slider.Text = ""
	slider.Parent = holder
	createCorner(6).Parent = slider

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
	fill.Parent = slider
	createCorner(6).Parent = fill

	local dragging = false
	slider.MouseButton1Down:Connect(function()
		dragging = true
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	game:GetService("RunService").RenderStepped:Connect(function()
		if dragging then
			local pos = math.clamp((game:GetService("UserInputService"):GetMouseLocation().X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(pos, 0, 1, 0)
			local val = math.floor(min + (max - min) * pos)
			label.Text = name .. ": " .. val
			if callback then callback(val) end
		end
	end)
end

-- 🟨 Dropdown
function FSSYX:AddDropdown(name, list, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 30)
	button.Text = name .. ": " .. list[1]
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = self.content
	createCorner(6).Parent = button

	local open = false
	local dropdownFrame

	button.MouseButton1Click:Connect(function()
		if open then
			open = false
			if dropdownFrame then dropdownFrame:Destroy() end
			return
		end
		open = true

		dropdownFrame = Instance.new("Frame")
		dropdownFrame.Size = UDim2.new(1, -10, 0, #list * 25)
		dropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		dropdownFrame.Parent = self.content
		createCorner(6).Parent = dropdownFrame

		local layout = Instance.new("UIListLayout")
		layout.Parent = dropdownFrame

		for _, opt in ipairs(list) do
			local optBtn = Instance.new("TextButton")
			optBtn.Text = opt
			optBtn.Size = UDim2.new(1, 0, 0, 25)
			optBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			optBtn.Font = Enum.Font.Gotham
			optBtn.TextSize = 14
			optBtn.Parent = dropdownFrame
			optBtn.MouseButton1Click:Connect(function()
				button.Text = name .. ": " .. opt
				if callback then callback(opt) end
				dropdownFrame:Destroy()
				open = false
			end)
		end
	end)
end

-- 🔔 Notify
function FSSYX:Notify(msg, duration)
	duration = duration or 3
	local notify = Instance.new("TextLabel")
	notify.Size = UDim2.new(0, 250, 0, 30)
	notify.Position = UDim2.new(1, -270, 1, -50)
	notify.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	notify.TextColor3 = Color3.fromRGB(255, 255, 255)
	notify.Text = msg
	notify.TextSize = 14
	notify.Font = Enum.Font.Gotham
	notify.Parent = ScreenGui
	createCorner(6).Parent = notify

	tween(notify, {Position = UDim2.new(1, -270, 1, -100)}, 0.3)
	task.wait(duration)
	tween(notify, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
	task.wait(0.3)
	notify:Destroy()
end

return setmetatable({}, {__index = FSSYX})
