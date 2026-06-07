--[[
    Vertex UI Library - Full Working Executor Script
    Create modern GUIs directly from your executor.
--]]

local Vertex = {}

-- ========== THEME (easily change colors) ==========
Vertex.Theme = {
    Background = Color3.fromRGB(20, 20, 28),
    Surface = Color3.fromRGB(30, 30, 40),
    Primary = Color3.fromRGB(120, 70, 255),
    PrimaryDark = Color3.fromRGB(90, 50, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(180, 180, 200),
    Danger = Color3.fromRGB(255, 70, 70)
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Helper: create instance with optional corner rounding
local function newInstance(className, props, radius)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        inst[k] = v
    end
    if radius and (className == "Frame" or className == "TextButton" or className == "TextBox" or className == "ScrollingFrame") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius)
        corner.Parent = inst
    end
    return inst
end

-- Helper: add shadow effect
local function addShadow(frame, offset, transparency)
    local shadow = newInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(1, offset*2, 1, offset*2),
        Position = UDim2.new(0, -offset, 0, -offset),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = transparency or 0.7,
        ZIndex = -1,
        BorderSizePixel = 0
    }, 8)
    return shadow
end

-- Notifications (popup)
function Vertex:Notify(title, text, duration)
    duration = duration or 3
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end

    local notif = newInstance("Frame", {
        Parent = gui,
        Size = UDim2.new(0, 300, 0, 60),
        Position = UDim2.new(0.5, -150, 0, -80),
        BackgroundColor3 = Vertex.Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, 8)
    addShadow(notif, 4, 0.8)

    local titleLabel = newInstance("TextLabel", {
        Parent = notif,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Vertex.Theme.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    })

    local descLabel = newInstance("TextLabel", {
        Parent = notif,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 12, 0, 32),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Vertex.Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12
    })

    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Position = UDim2.new(0.5, -150, 0, 12) })
    tweenIn:Play()
    task.wait(duration)
    local tweenOut = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Position = UDim2.new(0.5, -150, 0, -80) })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        notif:Destroy()
    end)
end

-- Main Window Creator
function Vertex:CreateWindow(config)
    config = config or {}
    local screenGui = newInstance("ScreenGui", {
        Name = "VertexUI",
        ResetOnSpawn = false,
        Parent = LocalPlayer:WaitForChild("PlayerGui")
    })

    -- Main frame
    local mainFrame = newInstance("Frame", {
        Parent = screenGui,
        Size = UDim2.fromOffset(700, 480),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Vertex.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, 12)
    addShadow(mainFrame, 6, 0.75)

    -- Dragging logic
    local dragStart, dragPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = true
            dragPos = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragPos
            mainFrame.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = false
        end
    end)

    -- Title bar
    local titleBar = newInstance("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Vertex.Theme.Surface,
        BorderSizePixel = 0
    }, 12)
    -- Only top corners rounded
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    local titleClip = newInstance("Frame", {
        Parent = titleBar,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })
    local titleLabel = newInstance("TextLabel", {
        Parent = titleClip,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "Vertex Hub",
        TextColor3 = Vertex.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 18
    })
    local closeBtn = newInstance("TextButton", {
        Parent = titleClip,
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -42, 0.5, -18),
        Text = "✕",
        BackgroundColor3 = Vertex.Theme.Surface,
        TextColor3 = Vertex.Theme.TextMuted,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AutoButtonColor = false
    }, 8)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Vertex.Theme.Danger
        closeBtn.TextColor3 = Vertex.Theme.Text
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Vertex.Theme.Surface
        closeBtn.TextColor3 = Vertex.Theme.TextMuted
    end)

    -- Left sidebar (tabs)
    local sidebar = newInstance("Frame", {
        Parent = mainFrame,
        Size = UDim2.fromOffset(180, 0),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Vertex.Theme.Surface,
        BorderSizePixel = 0
    })
    local tabContainer = newInstance("Frame", {
        Parent = sidebar,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })
    local tabLayout = newInstance("UIListLayout", {
        Parent = tabContainer,
        Padding = UDim.new(0, 4)
    })
    local tabPadding = newInstance("UIPadding", {
        Parent = tabContainer,
        PaddingTop = UDim.new(0, 12)
    })

    -- Content area
    local contentArea = newInstance("Frame", {
        Parent = mainFrame,
        Position = UDim2.fromOffset(180, 42),
        Size = UDim2.new(1, -180, 1, -42),
        BackgroundTransparency = 1
    })

    local Window = { Tabs = {} }

    function Window:CreateTab(tabName)
        -- Tab button
        local tabBtn = newInstance("TextButton", {
            Parent = tabContainer,
            Size = UDim2.new(1, -20, 0, 40),
            Text = tabName,
            BackgroundColor3 = Vertex.Theme.Surface,
            TextColor3 = Vertex.Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            AutoButtonColor = false
        }, 8)
        tabBtn.MouseEnter:Connect(function()
            if tabBtn.BackgroundColor3 ~= Vertex.Theme.Primary then
                tabBtn.BackgroundColor3 = Vertex.Theme.Surface
                TweenService:Create(tabBtn, TweenInfo.new(0.1), { BackgroundColor3 = Vertex.Theme.Surface }):Play()
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if tabBtn.BackgroundColor3 ~= Vertex.Theme.Primary then
                tabBtn.BackgroundColor3 = Vertex.Theme.Surface
            end
        end)

        -- Content page (ScrollingFrame)
        local page = newInstance("ScrollingFrame", {
            Parent = contentArea,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            CanvasSize = UDim2.new(),
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = Vertex.Theme.PrimaryDark,
            BorderSizePixel = 0,
            Visible = false
        }, 8)
        local pageLayout = newInstance("UIListLayout", {
            Parent = page,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        local pagePadding = newInstance("UIPadding", {
            Parent = page,
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        })

        local function updateCanvas()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 16)
        end
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.defer(updateCanvas)

        -- Show page when tab clicked
        tabBtn.MouseButton1Click:Connect(function()
            for _, other in ipairs(contentArea:GetChildren()) do
                if other:IsA("ScrollingFrame") then
                    other.Visible = false
                end
            end
            page.Visible = true
            for _, btn in ipairs(tabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Vertex.Theme.Surface
                end
            end
            tabBtn.BackgroundColor3 = Vertex.Theme.Primary
        end)

        -- If first tab, show it
        if #Window.Tabs == 0 then
            page.Visible = true
            tabBtn.BackgroundColor3 = Vertex.Theme.Primary
        end

        local Tab = {
            Name = tabName,
            Button = tabBtn,
            Page = page
        }

        -- ========== UI Element Constructors ==========
        function Tab:AddSection(text)
            local section = newInstance("Frame", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1
            })
            local label = newInstance("TextLabel", {
                Parent = section,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = string.upper(text),
                TextColor3 = Vertex.Theme.Primary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.GothamBold,
                TextSize = 14
            })
            local line = newInstance("Frame", {
                Parent = section,
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 1, -2),
                BackgroundColor3 = Vertex.Theme.Primary,
                BorderSizePixel = 0
            }, 1)
            return section
        end

        function Tab:AddLabel(text)
            return newInstance("TextLabel", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 28),
                Text = text,
                BackgroundTransparency = 1,
                TextColor3 = Vertex.Theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 13
            })
        end

        function Tab:AddParagraph(title, content)
            local frame = newInstance("Frame", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundTransparency = 1
            })
            local titleLbl = newInstance("TextLabel", {
                Parent = frame,
                Size = UDim2.new(1, 0, 0, 24),
                Text = title,
                BackgroundTransparency = 1,
                TextColor3 = Vertex.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.GothamBold,
                TextSize = 14
            })
            local contentLbl = newInstance("TextLabel", {
                Parent = frame,
                Position = UDim2.new(0, 0, 0, 26),
                Size = UDim2.new(1, 0, 0, 34),
                Text = content,
                BackgroundTransparency = 1,
                TextColor3 = Vertex.Theme.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextWrapped = true,
                TextYAlignment = Enum.TextYAlignment.Top
            })
            local function adjust()
                local bounds = contentLbl.TextBounds
                local need = math.max(60, bounds.Y + 36)
                frame.Size = UDim2.new(1, 0, 0, need)
                contentLbl.Size = UDim2.new(1, 0, 0, bounds.Y + 8)
            end
            contentLbl:GetPropertyChangedSignal("Text"):Connect(adjust)
            adjust()
            return frame
        end

        function Tab:AddDivider()
            return newInstance("Frame", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = Vertex.Theme.Surface,
                BorderSizePixel = 0
            }, 1)
        end

        function Tab:AddButton(data)
            local btn = newInstance("TextButton", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 38),
                Text = data.Name or "Button",
                BackgroundColor3 = Vertex.Theme.Primary,
                TextColor3 = Vertex.Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                AutoButtonColor = false
            }, 8)
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Vertex.Theme.PrimaryDark
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Vertex.Theme.Primary
            end)
            btn.MouseButton1Click:Connect(function()
                if data.Callback then data.Callback() end
            end)
            return btn
        end

        function Tab:AddToggle(data)
            local state = data.Default or false
            local frame = newInstance("Frame", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Vertex.Theme.Surface,
                BorderSizePixel = 0
            }, 8)
            local label = newInstance("TextLabel", {
                Parent = frame,
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = data.Name or "Toggle",
                TextColor3 = Vertex.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 14
            })
            local toggleBtn = newInstance("TextButton", {
                Parent = frame,
                Size = UDim2.new(0, 44, 0, 24),
                Position = UDim2.new(1, -56, 0.5, -12),
                BackgroundColor3 = state and Vertex.Theme.Primary or Vertex.Theme.Surface,
                Text = "",
                AutoButtonColor = false
            }, 12)
            local knob = newInstance("Frame", {
                Parent = toggleBtn,
                Size = UDim2.new(0, 20, 0, 20),
                Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Vertex.Theme.Text,
                BorderSizePixel = 0
            }, 10)

            local function update()
                toggleBtn.BackgroundColor3 = state and Vertex.Theme.Primary or Vertex.Theme.Surface
                local newPos = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                TweenService:Create(knob, TweenInfo.new(0.12), { Position = newPos }):Play()
                if data.Callback then data.Callback(state) end
            end
            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                update()
            end)
            update()
            return {
                SetValue = function(v)
                    state = v
                    update()
                end
            }
        end

        function Tab:AddSlider(data)
            local min = data.Min or 0
            local max = data.Max or 100
            local value = data.Default or min
            local frame = newInstance("Frame", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Vertex.Theme.Surface,
                BorderSizePixel = 0
            }, 8)
            local label = newInstance("TextLabel", {
                Parent = frame,
                Size = UDim2.new(1, -20, 0, 22),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text = (data.Name or "Slider") .. ": " .. tostring(value),
                TextColor3 = Vertex.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                TextSize = 13
            })
            local sliderBar = newInstance("Frame", {
                Parent = frame,
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 12, 0, 38),
                BackgroundColor3 = Vertex.Theme.Surface,
                BorderSizePixel = 0
            }, 2)
            local fill = newInstance("Frame", {
                Parent = sliderBar,
                Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
                BackgroundColor3 = Vertex.Theme.Primary,
                BorderSizePixel = 0
            }, 2)
            local grab = newInstance("TextButton", {
                Parent = sliderBar,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((value-min)/(max-min), -7, 0.5, -7),
                BackgroundColor3 = Vertex.Theme.Text,
                Text = "",
                AutoButtonColor = false
            }, 7)

            local dragging = false
            grab.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + rel * (max - min))
                    label.Text = (data.Name or "Slider") .. ": " .. tostring(value)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    grab.Position = UDim2.new(rel, -7, 0.5, -7)
                    if data.Callback then data.Callback(value) end
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            return {
                SetValue = function(v)
                    value = v
                    local r = (value-min)/(max-min)
                    fill.Size = UDim2.new(r, 0, 1, 0)
                    grab.Position = UDim2.new(r, -7, 0.5, -7)
                    label.Text = (data.Name or "Slider") .. ": " .. tostring(value)
                    if data.Callback then data.Callback(value) end
                end
            }
        end

        function Tab:AddDropdown(data)
            local options = data.Options or {}
            local selected = data.Default or options[1]
            local btn = newInstance("TextButton", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 38),
                Text = (data.Name or "Dropdown") .. ": " .. tostring(selected),
                BackgroundColor3 = Vertex.Theme.Surface,
                TextColor3 = Vertex.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                AutoButtonColor = false
            }, 8)
            local dropdownFrame = newInstance("Frame", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Vertex.Theme.Surface,
                Visible = false,
                ClipsDescendants = true
            }, 8)
            local listLayout = newInstance("UIListLayout", {
                Parent = dropdownFrame,
                Padding = UDim.new(0, 2)
            })
            for _, opt in ipairs(options) do
                local optBtn = newInstance("TextButton", {
                    Parent = dropdownFrame,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = opt,
                    BackgroundColor3 = Vertex.Theme.Surface,
                    TextColor3 = Vertex.Theme.TextMuted,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    AutoButtonColor = false
                }, 6)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    btn.Text = (data.Name or "Dropdown") .. ": " .. tostring(selected)
                    dropdownFrame.Visible = false
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
                    if data.Callback then data.Callback(selected) end
                end)
            end
            btn.MouseButton1Click:Connect(function()
                local vis = dropdownFrame.Visible
                dropdownFrame.Visible = not vis
                dropdownFrame.Size = vis and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 0, #options * 34)
            end)
            return {
                SetValue = function(v)
                    if table.find(options, v) then
                        selected = v
                        btn.Text = (data.Name or "Dropdown") .. ": " .. tostring(selected)
                        if data.Callback then data.Callback(selected) end
                    end
                end
            }
        end

        function Tab:AddTextbox(data)
            local box = newInstance("TextBox", {
                Parent = page,
                Size = UDim2.new(1, 0, 0, 38),
                PlaceholderText = data.Name or "Enter text...",
                Text = "",
                BackgroundColor3 = Vertex.Theme.Surface,
                TextColor3 = Vertex.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                ClearTextOnFocus = false
            }, 8)
            box.FocusLost:Connect(function()
                if data.Callback then data.Callback(box.Text) end
            end)
            return box
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

-- ========== EXAMPLE USAGE ==========
-- Create a window
local mainWindow = Vertex:CreateWindow({ Title = "Vertex Hub" })

-- Create tabs
local mainTab = mainWindow:CreateTab("Main")
local settingsTab = mainWindow:CreateTab("Settings")
local aboutTab = mainWindow:CreateTab("About")

-- Main tab content
mainTab:AddSection("Welcome")
mainTab:AddLabel("This is a fully functional UI library.")
mainTab:AddParagraph("Description", "You can add buttons, toggles, sliders, dropdowns, and more.")
mainTab:AddDivider()

mainTab:AddButton({
    Name = "Click Me",
    Callback = function()
        Vertex:Notify("Button", "You clicked the button!", 2)
    end
})

local myToggle = mainTab:AddToggle({
    Name = "Enable Feature",
    Default = true,
    Callback = function(state)
        print("Toggle state:", state)
    end
})

mainTab:AddSlider({
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 75,
    Callback = function(val)
        print("Volume set to", val)
    end
})

-- Settings tab
settingsTab:AddSection("Appearance")
settingsTab:AddDropdown({
    Name = "Theme",
    Options = {"Dark", "Purple", "Midnight"},
    Default = "Purple",
    Callback = function(opt)
        print("Theme changed to", opt)
    end
})
settingsTab:AddTextbox({
    Name = "Enter your name",
    Callback = function(text)
        Vertex:Notify("Hello", text, 2)
    end
})

-- About tab
aboutTab:AddSection("Vertex UI Library")
aboutTab:AddLabel("Version 1.0")
aboutTab:AddLabel("Created for Roblox Executors")
aboutTab:AddParagraph("Credits", "Vertex Development - Modern UI Library")

-- Show startup notification
Vertex:Notify("Vertex UI", "Library loaded successfully!", 3)

return Vertex
