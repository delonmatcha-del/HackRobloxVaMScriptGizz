```lua
-- SimpleUI Library (single-file)
-- Raw-ready for hosting on GitHub (raw .lua)
-- Features:
--  - CreateWindow(title)
--  - AddSwitch(label, default, callback)
--  - AddCheckbox(label, default, callback)
--  - AddDropdown(label, options, defaultIndex, callback)
--  - AddTextBox(label, placeholder, callback)
--  - AddSlider(label, min, max, default, callback)
--  - AddSearchDropdown(label, options, defaultIndex, callback)
--  - AddRadioGroup(label, options, defaultIndex, callback)
--  - AddConsoleExecute(label, placeholder) - executes Lua in pcall(loadstring(...))
--  - Notify(text, duration)
-- Usage:
--   local SimpleUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourname/repo/main/simpleui.lua"))()
--   local win = SimpleUI:CreateWindow("Example")
--   win:AddButton(...), etc.
-- NOTE: This library creates UI in CoreGui (protected for some executors).
-- Adjust parent if required.

local SimpleUI = {}
SimpleUI.__index = SimpleUI

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local guiParent = (syn and syn.protect_gui) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Utilities
local function new(class, props)
	local inst = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				inst.Parent = v
			else
				pcall(function() inst[k] = v end)
			end
		end
	end
	return inst
end

local function tween(inst, props, time, style, dir)
	time = time or 0.18
	style = style or Enum.EasingStyle.Quad
	dir = dir or Enum.EasingDirection.Out
	local ok, t = pcall(function()
		return TweenService:Create(inst, TweenInfo.new(time, style, dir), props)
	end)
	if ok and t then t:Play() end
end

local function clamp(v, a, b) if v < a then return a end if v > b then return b end return v end

-- DPI scaling helper
local function getScale()
	local cam = workspace.CurrentCamera
	if not cam then return 1 end
	local vw = cam.ViewportSize.X
	-- base width 1366, clamp from 0.6 to 1.3
	local s = clamp(vw / 1366, 0.7, 1.25)
	return s
end

-- Create the Notification manager
local notifications = {}
local function notify(text, duration)
	duration = duration or 3
	local screen = guiParent
	local notifGui = new("ScreenGui", {Parent = screen, ResetOnSpawn = false, Name = "SimpleUINotif"})
	local frame = new("Frame", {
		Parent = notifGui,
		Size = UDim2.new(0, 340, 0, 48),
		Position = UDim2.new(1, -360, 0, 40 + (#notifications * 56)),
		BackgroundColor3 = Color3.fromRGB(28, 20, 40),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0,0),
	})
	new("UICorner", {Parent = frame, CornerRadius = UDim.new(0,8)})
	local stroke = new("UIStroke", {Parent = frame, Color = Color3.fromRGB(170, 90, 255), Thickness = 1.2, Transparency = 0.2})
	local label = new("TextLabel", {
		Parent = frame,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(225,225,235),
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	table.insert(notifications, notifGui)
	-- animate in
	frame.Position = UDim2.new(1, 400, 0, frame.Position.Y.Offset)
	tween(frame, {Position = UDim2.new(1, -360, 0, frame.Position.Y.Offset)}, 0.28)
	delay(duration, function()
		tween(frame, {Position = UDim2.new(1, 400, 0, frame.Position.Y.Offset), BackgroundTransparency = 1}, 0.28)
		task.wait(0.28)
		pcall(function() notifGui:Destroy() end)
	end)
end

-- Main API
function SimpleUI:CreateWindow(title)
	local self = setmetatable({}, SimpleUI)
	local scale = getScale()

	-- ScreenGui
	local screen = new("ScreenGui", {Parent = guiParent, ResetOnSpawn = false, Name = ("SimpleUI_%s"):format(tostring(title):gsub("%s+",""))})
	self.ScreenGui = screen

	-- Root frame (centered)
	local rootW, rootH = math.floor(520 * scale), math.floor(360 * scale)
	local root = new("Frame", {
		Parent = screen,
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, rootW, 0, rootH),
		BackgroundColor3 = Color3.fromRGB(18,18,22),
		BorderSizePixel = 0,
	})
	new("UICorner", {Parent = root, CornerRadius = UDim.new(0,10)})
	self.Root = root

	-- Top bar
	local top = new("Frame", {Parent = root, Size = UDim2.new(1,0,0,36), BackgroundColor3 = Color3.fromRGB(20,20,26), BorderSizePixel = 0})
	new("UICorner", {Parent = top, CornerRadius = UDim.new(0,8)})
	local titleLbl = new("TextLabel", {
		Parent = top,
		Text = title or "Simple UI",
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(235,235,240),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		Position = UDim2.new(0,12,0,4),
		Size = UDim2.new(1,-24,1,0),
		TextXAlignment = Enum.TextXAlignment.Left
	})

	-- content scrolling
	local content = new("ScrollingFrame", {
		Parent = root,
		Position = UDim2.new(0, 10, 0, 46),
		Size = UDim2.new(1, -20, 1, -56),
		CanvasSize = UDim2.new(0,0,0,0),
		ScrollBarThickness = 8,
		BackgroundTransparency = 1
	})
	new("UICorner", {Parent = content, CornerRadius = UDim.new(0,8)})
	local layout = new("UIListLayout", {Parent = content})
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	self.Content = content
	self.Layout = layout

	-- drop shadow / glow frame
	local stroke = new("UIStroke", {Parent = root, Color = Color3.fromRGB(170, 80, 255), Transparency = 0.7, Thickness = 1.2})
	self._elements = {}

	-- draggable
	do
		local dragging, dragInput, dragStart, startPos
		root.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = root.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		root.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)
		RunService.RenderStepped:Connect(function()
			if dragging and dragInput and dragStart then
				local delta = UserInputService:GetMouseLocation() - Vector2.new(dragStart.X, dragStart.Y)
				root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	-- helper to update CanvasSize
	local function updateCanvas()
		content.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
	updateCanvas()

	-- element creators
	function self:AddLabel(text)
		local f = new("Frame", {Parent = content, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,22)})
		local lbl = new("TextLabel", {
			Parent = f,
			BackgroundTransparency = 1,
			Text = text or "",
			TextColor3 = Color3.fromRGB(220,220,230),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0,6,0,0),
			Size = UDim2.new(1,-12,1,0)
		})
		return lbl
	end

	function self:AddSwitch(label, default, callback)
		local f = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,32), BackgroundTransparency = 1})
		local lbl = new("TextLabel", {Parent = f, BackgroundTransparency = 1, Text = label or "", TextColor3 = Color3.fromRGB(220,220,230), Font = Enum.Font.Gotham, TextSize = 14, Position = UDim2.new(0,6,0,0), Size = UDim2.new(0.7,-8,1,0), TextXAlignment = Enum.TextXAlignment.Left})
		local box = new("Frame", {Parent = f, Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1,-48,0,5), BackgroundColor3 = Color3.fromRGB(28,28,34)})
		new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
		local knob = new("Frame", {Parent = box, Size = UDim2.new(default and 1 or 0,0,1,0), BackgroundColor3 = Color3.fromRGB(170,80,255)})
		new("UICorner", {Parent = knob, CornerRadius = UDim.new(0,6)})
		local state = default and true or false
		box.InputBegan:Connect(function()
			state = not state
			tween(knob, {Size = state and UDim2.new(1,0,1,0) or UDim2.new(0,0,1,0)}, 0.12)
			pcall(callback, state)
		end)
		return {
			Set = function(v) state = v; knob.Size = v and UDim2.new(1,0,1,0) or UDim2.new(0,0,1,0) end,
			Get = function() return state end
		}
	end

	function self:AddCheckbox(label, default, callback)
		local f = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1})
		local lbl = new("TextLabel", {Parent = f, BackgroundTransparency = 1, Text = label or "", TextColor3 = Color3.fromRGB(220,220,230), Font = Enum.Font.Gotham, TextSize = 14, Position = UDim2.new(0,6,0,0), Size = UDim2.new(0.7,-8,1,0), TextXAlignment = Enum.TextXAlignment.Left})
		local box = new("TextButton", {Parent = f, Text = "", Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-30,0,4), BackgroundColor3 = Color3.fromRGB(30,30,38)})
		new("UICorner", {Parent = box, CornerRadius = UDim.new(0,4)})
		local mark = new("TextLabel", {Parent = box, Text = default and "✓" or "", BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(220,220,230), Font = Enum.Font.GothamBold, TextSize = 16})
		local state = default and true or false
		box.MouseButton1Click:Connect(function()
			state = not state
			mark.Text = state and "✓" or ""
			pcall(callback, state)
		end)
		return {
			Set = function(v) state = v; mark.Text = v and "✓" or "" end,
			Get = function() return state end
		}
	end

	function self:AddDropdown(label, options, defaultIndex, callback)
		options = options or {}
		defaultIndex = defaultIndex or 1
		local f = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
		local lbl = new("TextLabel", {Parent = f, BackgroundTransparency = 1, Text = label or "", TextColor3 = Color3.fromRGB(220,220,230), Font = Enum.Font.Gotham, TextSize = 14, Position = UDim2.new(0,6,0,0), Size = UDim2.new(1,-12,0,18), TextXAlignment = Enum.TextXAlignment.Left})
		local btn = new("TextButton", {Parent = f, Text = tostring(options[defaultIndex] or ""), Size = UDim2.new(1, -12, 0, 20), Position = UDim2.new(0,6,0,16), BackgroundColor3 = Color3.fromRGB(28,28,34)})
		new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
		local list = new("Frame", {Parent = self.Root, Visible = false, Size = UDim2.new(0, 200, 0, 120), BackgroundColor3 = Color3.fromRGB(20,20,24)})
		new("UICorner", {Parent = list, CornerRadius = UDim.new(0,6)})
		local ul = new("UIListLayout", {Parent = list})
		ul.Padding = UDim.new(0,4)
		local function refresh()
			for _,c in pairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
			for i,v in ipairs(options) do
				local it = new("TextButton", {Parent = list, Text = tostring(v), Size = UDim2.new(1,-12,0,28), Position = UDim2.new(0,6,0, (i-1)*32), BackgroundColor3 = Color3.fromRGB(30,30,36), TextColor3 = Color3.fromRGB(230,230,235), Font = Enum.Font.Gotham, TextSize = 14})
				new("UICorner", {Parent = it, CornerRadius = UDim.new(0,6)})
				it.MouseButton1Click:Connect(function()
					btn.Text = tostring(v)
					list.Visible = false
					pcall(callback, v, i)
				end)
			end
		end
		btn.MouseButton1Click:Connect(function()
			local pos = btn.AbsolutePosition
			list.Position = UDim2.new(0, pos.X, 0, pos.Y + btn.AbsoluteSize.Y + 4)
			list.Visible = not list.Visible
		end)
		refresh()
		return {
			SetOptions = function(t) options = t or {}; refresh() end,
			Set = function(idx) btn.Text = tostring(options[idx] or ""); pcall(callback, options[idx], idx) end
		}
	end

	function self:AddTextBox(label, placeholder, callback)
		local f = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
		local lbl = new("TextLabel", {Parent = f, BackgroundTransparency = 1, Text = label or "", TextColor3 = Color3.fromRGB(220,220,230), Font = Enum.Font.Gotham, TextSize = 14, Position = UDim2.new(0,6,0,0), Size = UDim2.new(1,-12,0,18), TextXAlignment = Enum.TextXAlignment.Left})
		local box = new("TextBox", {Parent = f, Text = "", PlaceholderText = placeholder or "", Size = UDim2.new(1, -12, 0, 20), Position = UDim2.new(0,6,0,16), BackgroundColor3 = Color3.fromRGB(30,30,36), TextColor3 = Color3.fromRGB(230,230,235), Font = Enum.Font.Gotham, TextSize = 14})
		new("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
		box.FocusLost:Connect(function(enter)
			if enter then pcall(callback, box.Text) end
		end)
		return box
	end

	function self:AddSlider(label, min, max, default, callback)
		min = min or 0; max = max or 100; default = default or min
		local f = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,46), BackgroundTransparency = 1})
		local lbl = new("TextLabel", {Parent = f, BackgroundTransparency = 1, Text = label or "", TextColor3 = Color3.fromRGB(220,220,230), Font = Enum.Font.Gotham, TextSize = 14, Position = UDim2.new(0,6,0,0), Size = UDim2.new(1,-12,0,18), TextXAlignment = Enum.TextXAlignment.Left})
		local barBg = new("Frame", {Parent = f, Position = UDim2.new(0,6,0,22), Size = UDim2.new(1,-12,0,10), BackgroundColor3 = Color3.fromRGB(30,30,36)})
		new("UICorner", {Parent = barBg, CornerRadius = UDim.new(0,6)})
		local fill = new("Frame", {Parent = barBg, Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = Color3.fromRGB(170,80,255)})
		new("UICorner", {Parent = fill, CornerRadius = UDim.new(0,6)})
		local handle = new("Frame", {Parent = barBg, Size = UDim2.new(0,14,0,14), BackgroundColor3 = Color3.fromRGB(22,22,26), Position = UDim2.new(fill.Size.X.Scale, -7, 0.5, -7)})
		new("UICorner", {Parent = handle, CornerRadius = UDim.new(0,8)})
		local dragging = false
		handle.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
		end)
		UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local abs = barBg.AbsoluteSize.X
				local relX = clamp(input.Position.X - barBg.AbsolutePosition.X, 0, abs)
				local frac = relX/abs
				fill.Size = UDim2.new(frac,0,1,0)
				handle.Position = UDim2.new(fill.Size.X.Scale, -7, 0.5, -7)
				local value = math.floor(min + (max-min)*frac + 0.5)
				pcall(callback, value)
			end
		end)
		return {
			Set = function(v) local frac = clamp((v-min)/(max-min),0,1); fill.Size = UDim2.new(frac,0,1,0); handle.Position = UDim2.new(frac, -7, 0.5, -7) end,
			Get = function() return math.floor(min + (max-min)*fill.Size.X.Scale + 0.5) end
		}
	end

	function self:AddSearchDropdown(label, options, defaultIndex, callback)
		options = options or {}
		defaultIndex = defaultIndex or 1
		local ddObj = self:AddDropdown(label, options, defaultIndex, callback)
		-- we will create a search box tying into the same list underneath
		local searchBox = self:AddTextBox("Search", "Type to filter...", function(v)
			-- filter options and update dropdown
			local filtered = {}
			local lower = string.lower(tostring(v or ""))
			for i,opt in ipairs(options) do
				if lower == "" or string.find(string.lower(tostring(opt)), lower, 1, true) then
					table.insert(filtered, opt)
				end
			end
			ddObj.SetOptions(filtered)
		end)
		-- return dd API + searchBox for external access
		return {
			Clear = function() ddObj.SetOptions({}) end,
			Add = function(t) if typeof(t) == "table" then for _,v in ipairs(t) do table.insert(options, v) end end ddObj.SetOptions(options) end
		}
	end

	function self:AddRadioGroup(label, options, defaultIndex, callback)
		options = options or {}
		defaultIndex = defaultIndex or 1
		local f = new("Frame", {Parent = content, Size = UDim2.new(1,0,0, (20 * #options) + 28), BackgroundTransparency = 1})
		new("TextLabel", {Parent = f, BackgroundTransparency = 1, Text = label or "", TextColor3 = Color3.fromRGB(220,220,230), Font = Enum.Font.Gotham, TextSize = 14, Position = UDim2.new(0,6,0,0), Size = UDim2.new(1,-12,0,18), TextXAlignment = Enum.TextXAlignment.Left})
		local group = {}
		local selected = defaultIndex
		for i,v in ipairs(options) do
			local it = new("TextButton", {Parent = f, Text = tostring(v), BackgroundColor3 = Color3.fromRGB(28,28,34), TextColor3 = Color3.fromRGB(220,220,230), Font = Enum.Font.Gotham, TextSize = 14, Size = UDim2.new(1,-12,0,20), Position = UDim2.new(0,6,0, 18 + (i-1)*22)})
			new("UICorner", {Parent = it, CornerRadius = UDim.new(0,6)})
			it.MouseButton1Click:Connect(function()
				selected = i
				for _,c in ipairs(group) do c.BackgroundColor3 = Color3.fromRGB(28,28,34) end
				it.BackgroundColor3 = Color3.fromRGB(170,80,255)
				pcall(callback, v, i)
			end)
			if i == defaultIndex then it.BackgroundColor3 = Color3.fromRGB(170,80,255) end
			table.insert(group, it)
		end
		return {
			Set = function(idx) if group[idx] then group[idx].BackgroundColor3 = Color3.fromRGB(170,80,255) end end,
			Get = function() return options[selected], selected end
		}
	end

	function self:AddConsoleExecute(label, placeholder)
		local tb = self:AddTextBox(label or "Console", placeholder or "-- lua", function(v) end)
		local runBtn = new("TextButton", {Parent = self.Content, Text = "Run (pcall loadstring)", Size = UDim2.new(1,-20,0,30), BackgroundColor3 = Color3.fromRGB(170,80,255), TextColor3 = Color3.fromRGB(20,20,28), Font = Enum.Font.GothamBold, TextSize = 14})
		new("UICorner", {Parent = runBtn, CornerRadius = UDim.new(0,6)})
		runBtn.MouseButton1Click:Connect(function()
			local src = tb.Text
			local ok, fn = pcall(loadstring, src)
			if not ok or not fn then
				notify("Compile error: " .. tostring(fn), 4)
				return
			end
			local success, result = pcall(fn)
			if success then
				notify("Executed (ok).", 2)
			else
				notify("Runtime error: "..tostring(result), 4)
			end
		end)
		return tb
	end

	function self:Notify(text, duration)
		notify(text, duration)
	end

	-- expose a destroy method
	function self:Destroy()
		pcall(function() screen:Destroy() end)
	end

	return self
end

-- Return the library
return {
	CreateWindow = function(title) return SimpleUI:CreateWindow(title) end,
	Notify = function(t,d) notify(t,d) end
}
```
