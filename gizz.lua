--============================================================--
-- 🌌 FSSY-X DISCORD × TELEGRAM UI LIBRARY
--============================================================--
-- Author: Fssy Ggf
-- Style: Hybrid Dark Neon (Discord × Telegram)
--============================================================--

local FSSY = {}
FSSY.__index = FSSY

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Utility
local function Tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Make(class, props)
	local o = Instance.new(class)
	for i, v in pairs(props) do o[i] = v end
	return o
end

--============================================================--
-- WINDOW
--============================================================--
function FSSY:CreateWindow(title)
	local gui = Make("ScreenGui", {Parent = game:GetService("CoreGui"), Name = "FSSY_X_UI"})
	local main = Make("Frame", {
		Parent = gui, Size = UDim2.new(0, 600, 0, 400),
		Position = UDim2.new(0.5, -300, 0.5, -200),
		BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	})
	Make("UICorner", {Parent = main, CornerRadius = UDim.new(0, 12)})
	Make("UIStroke", {Parent = main, Color = Color3.fromRGB(100, 0, 255), Thickness = 1.5})

	-- Glow effect
	local glow = Make("ImageLabel", {
		Parent = main, BackgroundTransparency = 1,
		Image = "rbxassetid://4996891970", ImageColor3 = Color3.fromRGB(120, 0, 255),
		Size = UDim2.new(1, 60, 1, 60), Position = UDim2.new(0, -30, 0, -30),
		ImageTransparency = 0.7
	})

	local sidebar = Make("Frame", {
		Parent = main, Size = UDim2.new(0, 140, 1, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	})
	Make("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 12)})

	local header = Make("TextLabel", {
		Parent = sidebar, Size = UDim2.new(1, 0, 0, 50),
		Text = title, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true, BackgroundTransparency = 1
	})

	local btnContainer = Make("Frame", {
		Parent = sidebar, Size = UDim2.new(1, 0, 1, -50),
		Position = UDim2.new(0, 0, 0, 50), BackgroundTransparency = 1
	})
	local btnList = Make("UIListLayout", {Parent = btnContainer, Padding = UDim.new(0, 6)})

	local content = Make("Frame", {
		Parent = main, Size = UDim2.new(1, -150, 1, -20),
		Position = UDim2.new(0, 150, 0, 10), BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	})
	Make("UICorner", {Parent = content, CornerRadius = UDim.new(0, 10)})

	local layout = Make("UIListLayout", {Parent = content, Padding = UDim.new(0, 6)})

	-- Draggable
	local dragging, dragStart, startPos
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	local Window = {Body = content, Sidebar = btnContainer}

	--============================================================--
	-- BUTTON
	--============================================================--
	function Window:AddButton(label, callback)
		local btn = Make("TextButton", {
			Parent = self.Body, Size = UDim2.new(1, -10, 0, 40),
			Text = label, Font = Enum.Font.GothamBold, TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		})
		Make("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 8)})
		btn.MouseButton1Click:Connect(function()
			Tween(btn, {BackgroundColor3 = Color3.fromRGB(100, 0, 255)}, 0.15)
			task.wait(0.15)
			Tween(btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, 0.15)
			callback()
		end)
	end

	--============================================================--
	-- SWITCH
	--============================================================--
	function Window:AddSwitch(label, default, callback)
		local frame = Make("Frame", {
			Parent = self.Body, Size = UDim2.new(1, -10, 0, 40),
			BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		})
		Make("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 8)})

		local txt = Make("TextLabel", {
			Parent = frame, Size = UDim2.new(0.7, 0, 1, 0),
			Text = label, BackgroundTransparency = 1, TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamSemibold
		})

		local toggle = Make("TextButton", {
			Parent = frame, Size = UDim2.new(0.25, 0, 0.8, 0),
			Position = UDim2.new(0.72, 0, 0.1, 0),
			Text = default and "ON" or "OFF", Font = Enum.Font.GothamBold,
			TextScaled = true, BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80),
			TextColor3 = Color3.fromRGB(255, 255, 255)
		})
		Make("UICorner", {Parent = toggle, CornerRadius = UDim.new(0, 8)})
		local state = default
		toggle.MouseButton1Click:Connect(function()
			state = not state
			toggle.Text = state and "ON" or "OFF"
			Tween(toggle, {BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)}, 0.2)
			callback(state)
		end)
	end

	--============================================================--
	-- SLIDER
	--============================================================--
	function Window:AddSlider(label, min, max, def, callback)
		local frame = Make("Frame", {
			Parent = self.Body, Size = UDim2.new(1, -10, 0, 45),
			BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		})
		Make("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 8)})

		local txt = Make("TextLabel", {
			Parent = frame, Size = UDim2.new(1, 0, 0.4, 0),
			Text = label.." ("..def..")", BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255), TextScaled = true, Font = Enum.Font.GothamSemibold
		})
		local bar = Make("Frame", {
			Parent = frame, Size = UDim2.new(0.9, 0, 0.3, 0), Position = UDim2.new(0.05, 0, 0.6, 0),
			BackgroundColor3 = Color3.fromRGB(70, 70, 90)
		})
		Make("UICorner", {Parent = bar, CornerRadius = UDim.new(0, 8)})
		local fill = Make("Frame", {
			Parent = bar, Size = UDim2.new(def / max, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		})
		Make("UICorner", {Parent = fill, CornerRadius = UDim.new(0, 8)})

		local dragging = false
		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(p, 0, 1, 0)
				local val = math.floor(min + (max - min) * p)
				txt.Text = label.." ("..val..")"
				callback(val)
			end
		end)
	end

	--============================================================--
	-- DROPDOWN
	--============================================================--
	function Window:AddDropdown(label, list, callback)
		local frame = Make("Frame", {
			Parent = self.Body, Size = UDim2.new(1, -10, 0, 40),
			BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		})
		Make("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 8)})

		local btn = Make("TextButton", {
			Parent = frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
			Text = label.." ▼", Font = Enum.Font.GothamSemibold, TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255)
		})

		local drop = Make("Frame", {
			Parent = frame, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(35, 35, 50), ClipsDescendants = true
		})
		local layout = Make("UIListLayout", {Parent = drop})
		local open = false
		for _, v in ipairs(list) do
			local opt = Make("TextButton", {
				Parent = drop, Text = v, Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = Color3.fromRGB(50, 50, 80), TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true, Font = Enum.Font.GothamSemibold
			})
			Make("UICorner", {Parent = opt, CornerRadius = UDim.new(0, 6)})
			opt.MouseButton1Click:Connect(function()
				btn.Text = label.." : "..v
				Tween(drop, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
				open = false
				callback(v)
			end)
		end
		btn.MouseButton1Click:Connect(function()
			open = not open
			Tween(drop, {Size = open and UDim2.new(1, 0, 0, #list * 30) or UDim2.new(1, 0, 0, 0)}, 0.25)
		end)
	end

	--============================================================--
	-- NOTIFY
	--============================================================--
	function Window:Notify(text, dur)
		local nf = Make("Frame", {
			Parent = self.Body, Size = UDim2.new(1, -20, 0, 35),
			BackgroundColor3 = Color3.fromRGB(70, 70, 90)
		})
		Make("UICorner", {Parent = nf, CornerRadius = UDim.new(0, 8)})
		local t = Make("TextLabel", {
			Parent = nf, Text = text, Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,
			TextScaled = true, Font = Enum.Font.GothamBold
		})
		Tween(nf, {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}, 0.25)
		task.wait(dur or 2)
		Tween(nf, {BackgroundTransparency = 1}, 0.3)
		task.wait(0.3)
		nf:Destroy()
	end

	return Window
end

return FSSY
