--============================================================--
-- 🌌 GIZZ SENSI SUPREME UI LIBRARY (FINAL ULTRA EDITION)
--============================================================--
-- Dibuat oleh: Fssy Ggf
-- Style: Solid Dark Neon (Merah-Ungu Glow)
-- Lengkap: Switch, Button, Slider, Dropdown, Checkbox,
-- Color Picker, InputBox, Radio, Console, Notify, Search, dll.
--============================================================--

local GIZZ = {}
GIZZ.__index = GIZZ

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 🔹 Utility Tween
local function Tween(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
end

-- 🔹 Utility Create
local function Make(c, p)
	local o = Instance.new(c)
	for i, v in pairs(p) do o[i] = v end
	return o
end

-- 🔹 Glow Border
local function Glow(parent, color)
	local stroke = Make("UIStroke", {
		Parent = parent,
		Color = color or Color3.fromRGB(170, 0, 255),
		Thickness = 1.8,
		Transparency = 0.25
	})
end

--============================================================--
-- ⚡ WINDOW
--============================================================--
function GIZZ:CreateWindow(title)
	local gui = Make("ScreenGui", {Parent = CoreGui, Name = "GIZZ_SENSI_SUPREME"})
	local main = Make("Frame", {
		Parent = gui,
		Size = UDim2.new(0, 480, 0, 360),
		Position = UDim2.new(0.5, -240, 0.5, -180),
		BackgroundColor3 = Color3.fromRGB(15, 15, 20),
		BorderSizePixel = 0
	})
	Make("UICorner", {Parent = main, CornerRadius = UDim.new(0, 12)})
	Glow(main, Color3.fromRGB(160, 0, 255))

	local header = Make("TextLabel", {
		Parent = main,
		Size = UDim2.new(1, 0, 0, 40),
		Text = "⚡ "..(title or "GIZZ SENSI SUPREME UI").." ⚡",
		BackgroundColor3 = Color3.fromRGB(30, 0, 50),
		TextColor3 = Color3.fromRGB(255, 100, 200),
		TextScaled = true,
		Font = Enum.Font.GothamBold
	})
	Glow(header, Color3.fromRGB(255, 0, 200))
	Make("UICorner", {Parent = header, CornerRadius = UDim.new(0, 12)})

	local body = Make("ScrollingFrame", {
		Parent = main,
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 5
	})
	local layout = Make("UIListLayout", {Parent = body, Padding = UDim.new(0, 6)})

	-- Drag
	local dragging, dragStart, startPos
	header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = i.Position; startPos = main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local d = i.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	local Window = {Body = body}

	--============================================================--
	-- 🔘 SWITCH
	function Window:AddSwitch(label, default, callback)
		local f = Make("Frame", {Parent = body, Size = UDim2.new(1, -10, 0, 35), BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
		Make("UICorner", {Parent = f, CornerRadius = UDim.new(0, 8)}); Glow(f)
		local txt = Make("TextLabel", {Parent = f, Text = label, Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamSemibold, TextScaled = true})
		local btn = Make("TextButton", {Parent = f, Size = UDim2.new(0.25, 0, 0.7, 0), Position = UDim2.new(0.7, 5, 0.15, 0), BackgroundColor3 = default and Color3.fromRGB(160,0,255) or Color3.fromRGB(60,60,60), Text = default and "ON" or "OFF", Font = Enum.Font.GothamBold, TextScaled = true, TextColor3 = Color3.new(1,1,1)})
		Make("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 8)})
		local state = default
		btn.MouseButton1Click:Connect(function()
			state = not state
			btn.Text = state and "ON" or "OFF"
			Tween(btn, {BackgroundColor3 = state and Color3.fromRGB(160,0,255) or Color3.fromRGB(60,60,60)}, 0.15)
			if callback then callback(state) end
		end)
	end

	--============================================================--
	-- 🔺 BUTTON
	function Window:AddButton(label, callback)
		local b = Make("TextButton", {Parent = body, Size = UDim2.new(1, -10, 0, 35), BackgroundColor3 = Color3.fromRGB(50,0,80), Text = label, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextScaled = true})
		Make("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)}); Glow(b)
		b.MouseButton1Click:Connect(function()
			Tween(b, {BackgroundColor3 = Color3.fromRGB(150,0,200)}, 0.1)
			task.wait(0.1)
			Tween(b, {BackgroundColor3 = Color3.fromRGB(50,0,80)}, 0.2)
			if callback then callback() end
		end)
	end

	--============================================================--
	-- 🎚 SLIDER
	function Window:AddSlider(label, min, max, default, callback)
		local f = Make("Frame", {Parent = body, Size = UDim2.new(1, -10, 0, 40), BackgroundColor3 = Color3.fromRGB(25,25,25)})
		Make("UICorner", {Parent=f, CornerRadius=UDim.new(0,8)}); Glow(f)
		local title = Make("TextLabel", {Parent=f, Text=label.." ("..default..")", Size=UDim2.new(1,0,0.4,0), BackgroundTransparency=1, TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamSemibold, TextScaled=true})
		local bar = Make("Frame", {Parent=f, Size=UDim2.new(0.9,0,0.25,0), Position=UDim2.new(0.05,0,0.6,0), BackgroundColor3=Color3.fromRGB(50,0,100)})
		Make("UICorner",{Parent=bar,CornerRadius=UDim.new(0,6)})
		local fill = Make("Frame",{Parent=bar,Size=UDim2.new(default/max,0,1,0),BackgroundColor3=Color3.fromRGB(160,0,255)})
		Make("UICorner",{Parent=fill,CornerRadius=UDim.new(0,6)})
		local drag=false
		bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
		UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
		UserInputService.InputChanged:Connect(function(i)
			if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
				local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
				fill.Size = UDim2.new(pct,0,1,0)
				local val = math.floor(min+(max-min)*pct)
				title.Text = label.." ("..val..")"
				if callback then callback(val) end
			end
		end)
	end

	--============================================================--
	-- 🎨 COLOR PICKER
	function Window:AddColorPicker(label, default, callback)
		local f = Make("Frame", {Parent=body, Size=UDim2.new(1,-10,0,40), BackgroundColor3=Color3.fromRGB(25,25,25)})
		Make("UICorner",{Parent=f,CornerRadius=UDim.new(0,8)}); Glow(f)
		local txt = Make("TextLabel",{Parent=f,Text=label,Size=UDim2.new(0.7,0,1,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamSemibold,TextScaled=true})
		local btn = Make("TextButton",{Parent=f,Size=UDim2.new(0.25,0,0.7,0),Position=UDim2.new(0.7,5,0.15,0),BackgroundColor3=default or Color3.fromRGB(255,0,0),Text="",AutoButtonColor=false})
		Make("UICorner",{Parent=btn,CornerRadius=UDim.new(0,8)}); Glow(btn,default or Color3.fromRGB(255,0,0))
		btn.MouseButton1Click:Connect(function()
			local c = Color3.fromHSV(math.random(),1,1)
			btn.BackgroundColor3=c
			if callback then callback(c) end
		end)
	end

	--============================================================--
	-- 📋 INPUT BOX
	function Window:AddInput(label, placeholder, callback)
		local box = Make("TextBox",{Parent=body,Size=UDim2.new(1,-10,0,35),PlaceholderText=placeholder or "Type here...",Text="",TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextScaled=true,BackgroundColor3=Color3.fromRGB(30,30,40)})
		Make("UICorner",{Parent=box,CornerRadius=UDim.new(0,8)}); Glow(box)
		box.FocusLost:Connect(function() if callback then callback(box.Text) end end)
	end

	--============================================================--
	-- ☑ CHECKBOX
	function Window:AddCheckbox(label, default, callback)
		local f = Make("Frame",{Parent=body,Size=UDim2.new(1,-10,0,30),BackgroundColor3=Color3.fromRGB(25,25,25)})
		Make("UICorner",{Parent=f,CornerRadius=UDim.new(0,8)}); Glow(f)
		local cb = Make("TextButton",{Parent=f,Size=UDim2.new(0,25,0,25),Position=UDim2.new(0,5,0.1,0),BackgroundColor3=default and Color3.fromRGB(150,0,255) or Color3.fromRGB(50,50,50),Text=""})
		Make("UICorner",{Parent=cb,CornerRadius=UDim.new(0,5)})
		local txt = Make("TextLabel",{Parent=f,Text=label,Size=UDim2.new(1,-35,1,0),Position=UDim2.new(0,35,0,0),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextScaled=true})
		local state=default
		cb.MouseButton1Click:Connect(function()
			state=not state
			Tween(cb,{BackgroundColor3=state and Color3.fromRGB(150,0,255) or Color3.fromRGB(50,50,50)},0.15)
			if callback then callback(state) end
		end)
	end

	--============================================================--
	-- 🔘 RADIO GROUP
	function Window:AddRadio(label, options, callback)
		local group = Make("Frame",{Parent=body,Size=UDim2.new(1,-10,0,#options*30+20),BackgroundColor3=Color3.fromRGB(25,25,25)})
		Make("UICorner",{Parent=group,CornerRadius=UDim.new(0,8)}); Glow(group)
		Make("TextLabel",{Parent=group,Text=label,Size=UDim2.new(1,0,0,25),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextScaled=true})
		local selected=nil
		for i,opt in ipairs(options) do
			local b=Make("TextButton",{Parent=group,Text=opt,Size=UDim2.new(1,-10,0,25),Position=UDim2.new(0,5,0,25*i),BackgroundColor3=Color3.fromRGB(40,0,60),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextScaled=true})
			Make("UICorner",{Parent=b,CornerRadius=UDim.new(0,6)})
			b.MouseButton1Click:Connect(function()
				if selected then Tween(selected,{BackgroundColor3=Color3.fromRGB(40,0,60)},0.2) end
				selected=b
				Tween(b,{BackgroundColor3=Color3.fromRGB(150,0,255)},0.2)
				if callback then callback(opt) end
			end)
		end
	end

	--============================================================--
	-- 💻 CONSOLE EXECUTE
	function Window:AddConsole(callback)
		local frame=Make("Frame",{Parent=body,Size=UDim2.new(1,-10,0,120),BackgroundColor3=Color3.fromRGB(20,20,30)})
		Make("UICorner",{Parent=frame,CornerRadius=UDim.new(0,8)}); Glow(frame)
		local box=Make("TextBox",{Parent=frame,MultiLine=true,Text="",TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=14,ClearTextOnFocus=false,BackgroundColor3=Color3.fromRGB(30,30,45),Size=UDim2.new(1,-10,1,-35),Position=UDim2.new(0,5,0,5)})
		local btn=Make("TextButton",{Parent=frame,Text="▶ Execute",Size=UDim2.new(1,-10,0,25),Position=UDim2.new(0,5,1,-30),BackgroundColor3=Color3.fromRGB(90,0,150),TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextScaled=true})
		Make("UICorner",{Parent=btn,CornerRadius=UDim.new(0,6)})
		btn.MouseButton1Click:Connect(function() if callback then callback(box.Text) end end)
	end

	--============================================================--
	-- 🔔 NOTIFY
	function Window:Notify(msg,dur)
		local n=Make("TextLabel",{Parent=main,Text=msg,Size=UDim2.new(0,280,0,35),Position=UDim2.new(1,-300,1,0),BackgroundColor3=Color3.fromRGB(60,0,90),TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextScaled=true})
		Make("UICorner",{Parent=n,CornerRadius=UDim.new(0,8)}); Glow(n)
		Tween(n,{Position=UDim2.new(1,-300,1,-60)},0.3)
		task.wait(dur or 3)
		Tween(n,{Position=UDim2.new(1,-300,1,0),TextTransparency=1,BackgroundTransparency=1},0.4)
		task.wait(0.4); n:Destroy()
	end

	return Window
end

return GIZZ
