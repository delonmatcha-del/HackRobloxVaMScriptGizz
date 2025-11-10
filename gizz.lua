-- =====================================================
-- 🌌 GIZZ-X UI Library | Inspired by Supreme Aesthetic
-- Author: Fssy
-- =====================================================

local GizzX = {}
GizzX.__index = GizzX

-- Theme config
local Theme = {
    GlowColor = Color3.fromRGB(0, 255, 170),
    TextColor = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(30, 30, 30),
}

-- Utility
local function createGlow(obj)
    local glow = Instance.new("UIStroke")
    glow.Thickness = 1.8
    glow.Color = Theme.GlowColor
    glow.Transparency = 0.3
    glow.Parent = obj
end

-- Create base window
function GizzX:CreateWindow(title)
    local screen = Instance.new("ScreenGui", game.CoreGui)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 420)
    frame.Position = UDim2.new(0.3, 0, 0.3, 0)
    frame.BackgroundColor3 = Theme.Background
    frame.BorderSizePixel = 0
    frame.Parent = screen
    frame.Active = true
    frame.Draggable = true

    createGlow(frame)

    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1, 0, 0, 45)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "⚡ " .. title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 20
    titleLbl.TextColor3 = Theme.TextColor

    local container = Instance.new("Frame", frame)
    container.Size = UDim2.new(1, -20, 1, -60)
    container.Position = UDim2.new(0, 10, 0, 50)
    container.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 10)

    self.container = container
    return setmetatable({container = container, screen = screen}, GizzX)
end

-- Switch
function GizzX:AddSwitch(text, default, callback)
    local holder = Instance.new("Frame", self.container)
    holder.Size = UDim2.new(1, 0, 0, 35)
    holder.BackgroundColor3 = Theme.Accent
    holder.BorderSizePixel = 0
    createGlow(holder)

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left

    local button = Instance.new("TextButton", holder)
    button.Size = UDim2.new(0.25, 0, 0.7, 0)
    button.Position = UDim2.new(0.7, 10, 0.15, 0)
    button.Text = default and "ON" or "OFF"
    button.BackgroundColor3 = default and Theme.GlowColor or Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Theme.TextColor
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    createGlow(button)

    local state = default
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and Theme.GlowColor or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
end

-- Dropdown
function GizzX:AddDropdown(text, options, callback)
    local frame = Instance.new("Frame", self.container)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.Accent
    frame.BorderSizePixel = 0
    createGlow(frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left

    local dropdown = Instance.new("TextButton", frame)
    dropdown.Size = UDim2.new(1, -20, 0.5, -5)
    dropdown.Position = UDim2.new(0, 10, 0.5, 0)
    dropdown.Text = "Select..."
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdown.TextColor3 = Theme.TextColor
    dropdown.Font = Enum.Font.GothamBold
    dropdown.TextSize = 14
    createGlow(dropdown)

    local menu = Instance.new("Frame", frame)
    menu.Size = UDim2.new(1, -20, 0, #options * 25)
    menu.Position = UDim2.new(0, 10, 1, 0)
    menu.Visible = false
    menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    menu.BorderSizePixel = 0
    createGlow(menu)

    for _, v in ipairs(options) do
        local opt = Instance.new("TextButton", menu)
        opt.Size = UDim2.new(1, 0, 0, 25)
        opt.Text = v
        opt.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        opt.TextColor3 = Theme.TextColor
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 14
        opt.MouseButton1Click:Connect(function()
            dropdown.Text = v
            menu.Visible = false
            callback(v)
        end)
    end

    dropdown.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
end

-- Slider
function GizzX:AddSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame", self.container)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.Accent
    frame.BorderSizePixel = 0
    createGlow(frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("Frame", frame)
    slider.Size = UDim2.new(1, -20, 0.2, 0)
    slider.Position = UDim2.new(0, 10, 0.6, 0)
    slider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    local fill = Instance.new("Frame", slider)
    fill.BackgroundColor3 = Theme.GlowColor
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

    local val = default
    local input = slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local move; move = game:GetService("UserInputService").InputChanged:Connect(function(changed)
                if changed.UserInputType == Enum.UserInputType.MouseMovement then
                    local x = math.clamp((changed.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(x, 0, 1, 0)
                    val = math.floor(min + (max - min) * x)
                    callback(val)
                end
            end)
            game:GetService("UserInputService").InputEnded:Connect(function(e)
                if e.UserInputType == Enum.UserInputType.MouseButton1 then
                    move:Disconnect()
                end
            end)
        end
    end)
end

-- Color Picker
function GizzX:AddColorPicker(text, callback)
    local frame = Instance.new("Frame", self.container)
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Theme.Accent
    createGlow(frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.25, 0, 0.7, 0)
    button.Position = UDim2.new(0.7, 10, 0.15, 0)
    button.BackgroundColor3 = Theme.GlowColor
    button.Text = "Pick"
    button.TextColor3 = Theme.TextColor
    createGlow(button)

    button.MouseButton1Click:Connect(function()
        local color = Color3.fromHSV(math.random(), 1, 1)
        button.BackgroundColor3 = color
        callback(color)
    end)
end

-- Notification
function GizzX:Notify(text, duration)
    local msg = Instance.new("TextLabel", self.screen)
    msg.Size = UDim2.new(0, 250, 0, 40)
    msg.Position = UDim2.new(0.7, 0, 0.1, 0)
    msg.BackgroundColor3 = Theme.Accent
    msg.Text = text
    msg.Font = Enum.Font.GothamBold
    msg.TextSize = 16
    msg.TextColor3 = Theme.TextColor
    msg.BorderSizePixel = 0
    msg.BackgroundTransparency = 0.1
    createGlow(msg)
    game:GetService("TweenService"):Create(msg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
    task.delay(duration or 3, function()
        msg:Destroy()
    end)
end

return GizzX
