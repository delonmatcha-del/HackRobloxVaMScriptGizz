--============================================================--
-- 🌌 GIZZ SENSI SUPREME UI LIBRARY v4 (FULL REBUILD)
--============================================================--
-- ⚡ Full UI Library by Fssy Ggf
--============================================================--

local GizzLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- 🧩 THEME
GizzLib.Theme = {
    Primary = Color3.fromRGB(0, 162, 255),
    Background = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(25, 25, 25),
    Button = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(240, 240, 240),
    Accent = Color3.fromRGB(0, 132, 255)
}

-- 🌟 Smooth Tween
local function Tween(o, p, t)
    TweenService:Create(o, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
end

-- ⚙️ UI Loader
function GizzLib:CreateWindow(cfg)
    local title = cfg.Title or "GIZZ SENSI SUPREME"
    local iconURL = cfg.IconURL or "https://i.imgur.com/6q5JkDg.png"

    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "GizzSensiUI"
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 640, 0, 400)
    Main.Position = UDim2.new(0.5, -320, 0.5, -200)
    Main.BackgroundColor3 = GizzLib.Theme.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 12)

    -- 🔹 Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = GizzLib.Theme.Sidebar
    Sidebar.BorderSizePixel = 0

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SideLayout.Padding = UDim.new(0, 4)

    local TopTitle = Instance.new("TextLabel", Sidebar)
    TopTitle.Size = UDim2.new(1, 0, 0, 36)
    TopTitle.Text = "🌌 " .. title
    TopTitle.Font = Enum.Font.GothamBold
    TopTitle.TextColor3 = GizzLib.Theme.Text
    TopTitle.BackgroundTransparency = 1
    TopTitle.TextSize = 16

    -- 🔸 Hide/Show Button
    local Hide = Instance.new("ImageButton", Sidebar)
    Hide.Size = UDim2.new(0, 36, 0, 36)
    Hide.Position = UDim2.new(1, -42, 0, 4)
    Hide.Image = iconURL
    Hide.BackgroundTransparency = 1
    Hide.ImageColor3 = GizzLib.Theme.Accent

    local visible = true
    Hide.MouseButton1Click:Connect(function()
        visible = not visible
        if visible then
            Tween(Main, {Size = UDim2.new(0, 640, 0, 400)}, 0.35)
        else
            Tween(Main, {Size = UDim2.new(0, 50, 0, 50)}, 0.35)
        end
    end)

    -- 🔸 Content
    local Content = Instance.new("Frame", Main)
    Content.Position = UDim2.new(0, 160, 0, 0)
    Content.Size = UDim2.new(1, -160, 1, 0)
    Content.BackgroundTransparency = 1

    local PageFolder = Instance.new("Folder", Content)
    PageFolder.Name = "Pages"

    local ui = {}

    -- =====================================
    -- 🧭 PAGE CREATOR
    -- =====================================
    function ui:CreatePage(name)
        local page = Instance.new("ScrollingFrame", PageFolder)
        page.Name = name:gsub("%s", "_")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.CanvasSize = UDim2.new(0, 0, 0, 800)
        page.ScrollBarThickness = 4
        page.BackgroundTransparency = 1
        page.Visible = false

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        -- Sidebar Button
        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(1, -10, 0, 32)
        btn.Text = "  " .. name
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = GizzLib.Theme.Text
        btn.TextSize = 14
        btn.BackgroundColor3 = GizzLib.Theme.Button
        btn.AutoButtonColor = false

        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = GizzLib.Theme.Primary}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = GizzLib.Theme.Button}, 0.15)
        end)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageFolder:GetChildren()) do
                p.Visible = false
            end
            page.Visible = true
        end)

        if #PageFolder:GetChildren() == 1 then
            page.Visible = true
        end

        -- 🎛️ Add Components
        local components = {}

        function components:AddLabel(txt)
            local l = Instance.new("TextLabel", page)
            l.Text = txt
            l.Size = UDim2.new(0, 420, 0, 24)
            l.BackgroundTransparency = 1
            l.TextColor3 = GizzLib.Theme.Text
            l.Font = Enum.Font.Gotham
            l.TextSize = 14
            l.TextXAlignment = Enum.TextXAlignment.Left
            return l
        end

        function components:AddButton(txt, callback)
            local b = Instance.new("TextButton", page)
            b.Text = txt
            b.Size = UDim2.new(0, 420, 0, 36)
            b.BackgroundColor3 = GizzLib.Theme.Button
            b.TextColor3 = GizzLib.Theme.Text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 14
            b.AutoButtonColor = false
            b.MouseEnter:Connect(function() Tween(b, {BackgroundColor3 = GizzLib.Theme.Primary}, 0.1) end)
            b.MouseLeave:Connect(function() Tween(b, {BackgroundColor3 = GizzLib.Theme.Button}, 0.1) end)
            b.MouseButton1Click:Connect(function() pcall(callback) end)
            return b
        end

        function components:AddToggle(txt, callback)
            local frame = Instance.new("Frame", page)
            frame.Size = UDim2.new(0, 420, 0, 36)
            frame.BackgroundTransparency = 1

            local lbl = Instance.new("TextLabel", frame)
            lbl.Text = txt
            lbl.Size = UDim2.new(0.8, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = GizzLib.Theme.Text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local switch = Instance.new("Frame", frame)
            switch.Size = UDim2.new(0, 46, 0, 22)
            switch.Position = UDim2.new(1, -50, 0.5, -11)
            switch.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            local corner = Instance.new("UICorner", switch)
            corner.CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", switch)
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.Position = UDim2.new(0, 2, 0.5, -9)
            knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            local knCorner = Instance.new("UICorner", knob)
            knCorner.CornerRadius = UDim.new(1, 0)

            local state = false
            switch.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    Tween(knob, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.15)
                    Tween(switch, {BackgroundColor3 = state and GizzLib.Theme.Primary or Color3.fromRGB(45, 45, 45)}, 0.15)
                    pcall(callback, state)
                end
            end)
            return switch
        end

        return components
    end

    return ui
end

--============================================================--
-- ✅ USAGE EXAMPLE
--============================================================--
--[[

local UI = GizzLib:CreateWindow({
    Title = "Fish Go Controller",
    IconURL = "https://i.imgur.com/2qSvvHs.png"
})

local Page = UI:CreatePage("Auto Fish")
Page:AddLabel("🎣 Auto Fishing Control")
Page:AddButton("Start Fishing", function()
    print("Fishing started...")
end)
Page:AddToggle("Auto Catch", function(state)
    print("Auto Catch:", state)
end)

]]

return GizzLib
