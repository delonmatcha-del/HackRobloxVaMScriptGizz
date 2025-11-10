-- ============================================
-- Modern UI Library Roblox Lua (GitHub Raw Ready)
-- Author: Custom @You
-- Style: ImGui + Sidebar Kiri + Hide/Show Icon
-- ============================================

-- ======= LIBRARY DEFINITION =======
local ModernUI = {}
ModernUI.__index = ModernUI

function ModernUI:CreateWindow(title)
    local selfObj = {}
    setmetatable(selfObj, ModernUI)

    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = title or "ModernUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sidebar.Size = UDim2.new(0, 200, 1, 0)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    sidebar.Parent = screenGui

    -- Main Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    content.Size = UDim2.new(1, -200, 1, 0)
    content.Position = UDim2.new(0, 200, 0, 0)
    content.Parent = screenGui

    -- UIListLayout Sidebar
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 8)
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    sidebarLayout.Parent = sidebar

    -- Store references
    selfObj.ScreenGui = screenGui
    selfObj.Sidebar = sidebar
    selfObj.Content = content
    selfObj.Elements = {}

    -- Load custom ImGui font (automatic)
    local font = Instance.new("TextLabel")
    font.Font = Enum.Font.GothamBold
    font.Text = ""
    font.Parent = screenGui
    selfObj.Font = font.Font

    -- ======== Tambahkan Hide/Show Icon ========
    local toggleIcon = Instance.new("ImageButton")
    toggleIcon.Size = UDim2.new(0, 30, 0, 30)
    toggleIcon.Position = UDim2.new(0, 10, 0, 10)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Image = "rbxassetid://7072728475" -- bisa diganti dengan custom link
    toggleIcon.Parent = screenGui

    toggleIcon.MouseButton1Click:Connect(function()
        selfObj.ScreenGui.Enabled = not selfObj.ScreenGui.Enabled
    end)

    selfObj.ToggleIcon = toggleIcon
    -- ============================================

    return selfObj
end

-- ======= ADD TOGGLE =======
function ModernUI:AddToggle(name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 35)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = self.Sidebar

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Font = self.Font
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 20, 0, 20)
    button.Position = UDim2.new(1, -30, 0.5, -10)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
    button.Text = ""
    button.Parent = toggleFrame

    local state = default
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
        if callback then
            callback(state)
        end
    end)

    table.insert(self.Elements, toggleFrame)
end

-- ======= ADD BUTTON =======
function ModernUI:AddButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = self.Font
    btn.TextSize = 16
    btn.Text = name
    btn.Parent = self.Sidebar
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    table.insert(self.Elements, btn)
end

-- ======= ADD SLIDER =======
function ModernUI:AddSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    frame.BorderSizePixel = 0
    frame.Parent = self.Sidebar

    local label = Instance.new("TextLabel")
    label.Text = name .. ": " .. tostring(default)
    label.Font = self.Font
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local slider = Instance.new("TextButton")
    slider.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    slider.Size = UDim2.new(1, -20, 0, 8)
    slider.Position = UDim2.new(0, 10, 0, 25)
    slider.Text = ""
    slider.Parent = frame

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = game.Players.LocalPlayer:GetMouse()
            local relativeX = math.clamp(mouse.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            local value = min + (relativeX/slider.AbsoluteSize.X)*(max-min)
            label.Text = name .. ": " .. string.format("%.2f", value)
            if callback then callback(value) end
        end
    end)

    table.insert(self.Elements, frame)
end

-- ======= SHOW / HIDE VIA FUNCTION =======
function ModernUI:ToggleVisibility()
    self.ScreenGui.Enabled = not self.ScreenGui.Enabled
end

-- ======= RETURN LIBRARY =======
return ModernUI
