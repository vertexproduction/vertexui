--[[
    Vertex UI Library - Full Feature Set
    Dark modern purple UI system - complete and executor ready
    Style preserved exactly as requested.
--]]

local Vertex = {}
Vertex.__index = Vertex

------------------------------------------------
-- THEME (unchanged)
------------------------------------------------
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(20, 20, 28),
    Accent = Color3.fromRGB(140, 80, 255),
    Text = Color3.fromRGB(235, 235, 235),
    SubText = Color3.fromRGB(160, 160, 160)
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Helper: create instance with corner rounding
local function newInstance(className, props, radius)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        inst[k] = v
    end
    if radius and (className == "Frame" or className == "TextButton" or className == "ScrollingFrame") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius)
        corner.Parent = inst
    end
    return inst
end

-- Helper: add shadow (optional, keeps modern look)
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

------------------------------------------------
-- NOTIFICATION SYSTEM
------------------------------------------------
function Vertex:Notify(title, text, duration)
    duration = duration or 3
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end

    local notif = newInstance("Frame", {
        Parent = gui,
        Size = UDim2.new(0, 320, 0, 60),
        Position = UDim2.new(0.5, -160, 0, -80),
        BackgroundColor3 = Theme.Sidebar,
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
        TextColor3 = Theme.Accent,
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
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12
    })

    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Position = UDim2.new(0.5, -160, 0, 12) })
    tweenIn:Play()
    task.wait(duration)
    local tweenOut = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Position = UDim2.new(0.5, -160, 0, -80) })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        notif:Destroy()
    end)
end

------------------------------------------------
-- WINDOW CREATION
------------------------------------------------
function Vertex:CreateWindow(config)
    config = config or {}

    local ScreenGui = newInstance("ScreenGui", {
        Name = "VertexUI",
        ResetOnSpawn = false,
        Parent = LocalPlayer:WaitForChild("PlayerGui")
    })

    -- Main window frame
    local Main = newInstance("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, 10)

    -- Dragging logic
    local dragStart, dragMousePos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = true
            dragMousePos = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragMousePos
            Main.Position = UDim2.new(0.5, -300 + delta.X, 0.5, -200 + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = false
        end
    end)

    -- Sidebar
    local Sidebar = newInstance("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    }, 10)

    -- Title (in sidebar)
    local Title = newInstance("TextLabel", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = config.Title or "Vertex Development",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    })

    -- Container for tab buttons (UIListLayout for automatic stacking)
    local TabContainer = newInstance("Frame", {
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 1, -45),
        BackgroundTransparency = 1
    })
    local TabLayout = newInstance("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    local TabPadding = newInstance("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })

    -- Pages container (right side)
    local PagesContainer = newInstance("Frame", {
        Parent = Main,
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(1, -150, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    local Window = {
        Tabs = {},
        Pages = {},
        ScreenGui = ScreenGui,
        Main = Main,
        Sidebar = Sidebar
    }

    ------------------------------------------------
    -- TAB CREATION
    ------------------------------------------------
    function Window:CreateTab(name)
        -- Tab button
        local TabButton = newInstance("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, 0, 0, 32),
            Text = name,
            BackgroundColor3 = Theme.Sidebar,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            AutoButtonColor = false
        }, 6)

        -- Scrolling page
        local Page = newInstance("ScrollingFrame", {
            Parent = PagesContainer,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Visible = false,
            CanvasSize = UDim2.new(),
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0
        }, 8)

        -- Page layout (sections will be added here)
        local PageLayout = newInstance("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        local PagePadding = newInstance("UIPadding", {
            Parent = Page,
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        })

        -- Update canvas size when content changes
        local function updateCanvas()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 16)
        end
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.defer(updateCanvas)

        -- Tab switching
        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(PagesContainer:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true
            -- Update button appearance
            for _, btn in ipairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Theme.Sidebar
                end
            end
            TabButton.BackgroundColor3 = Theme.Accent
        end)

        -- If first tab, show it
        if #Window.Tabs == 0 then
            Page.Visible = true
            TabButton.BackgroundColor3 = Theme.Accent
        end

        local Tab = {
            Name = name,
            Button = TabButton,
            Page = Page,
            Sections = {}
        }

        ------------------------------------------------
        -- SECTION CREATION (with dynamic elements)
        ------------------------------------------------
        function Tab:CreateSection(sectionName)
            local Section = newInstance("Frame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 0),  -- height will be determined by content
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            }, 8)

            -- Section title
            local Label = newInstance("TextLabel", {
                Parent = Section,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Container for elements (buttons, toggles, etc.)
            local ElementsContainer = newInstance("Frame", {
                Parent = Section,
                Position = UDim2.new(0, 0, 0, 28),
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            local ElementsLayout = newInstance("UIListLayout", {
                Parent = ElementsContainer,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            local ElementsPadding = newInstance("UIPadding", {
                Parent = ElementsContainer,
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })

            local SectionAPI = {}

            -- Helper to add a generic element frame
            local function addElementFrame(height)
                local frame = newInstance("Frame", {
                    Parent = ElementsContainer,
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundTransparency = 1
                })
                return frame
            end

            ------------------------------------------------
            -- TOGGLE
            ------------------------------------------------
            function SectionAPI:CreateToggle(data)
                local frame = addElementFrame(32)
                local label = newInstance("TextLabel", {
                    Parent = frame,
                    Size = UDim2.new(1, -70, 1, 0),
                    BackgroundTransparency = 1,
                    Text = data.Name or "Toggle",
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Gotham,
                    TextSize = 14
                })
                local state = data.Default or false
                local toggleBtn = newInstance("TextButton", {
                    Parent = frame,
                    Size = UDim2.new(0, 44, 0, 24),
                    Position = UDim2.new(1, -56, 0.5, -12),
                    BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(35,35,50),
                    Text = "",
                    AutoButtonColor = false
                }, 12)
                local knob = newInstance("Frame", {
                    Parent = toggleBtn,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0
                }, 10)

                local function update()
                    toggleBtn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(35,35,50)
                    TweenService:Create(knob, TweenInfo.new(0.12), {
                        Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                    }):Play()
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

            ------------------------------------------------
            -- BUTTON
            ------------------------------------------------
            function SectionAPI:CreateButton(data)
                local frame = addElementFrame(36)
                local btn = newInstance("TextButton", {
                    Parent = frame,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = data.Name or "Button",
                    BackgroundColor3 = Theme.Accent,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    AutoButtonColor = false
                }, 6)
                btn.MouseButton1Click:Connect(function()
                    if data.Callback then data.Callback() end
                end)
                return btn
            end

            ------------------------------------------------
            -- SLIDER
            ------------------------------------------------
            function SectionAPI:CreateSlider(data)
                local min = data.Min or 0
                local max = data.Max or 100
                local value = data.Default or min
                local frame = addElementFrame(50)
                local label = newInstance("TextLabel", {
                    Parent = frame,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = (data.Name or "Slider") .. ": " .. tostring(value),
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Gotham,
                    TextSize = 13
                })
                local sliderBar = newInstance("Frame", {
                    Parent = frame,
                    Size = UDim2.new(1, 0, 0, 4),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundColor3 = Color3.fromRGB(35,35,50),
                    BorderSizePixel = 0
                }, 2)
                local fill = newInstance("Frame", {
                    Parent = sliderBar,
                    Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0
                }, 2)
                local grab = newInstance("TextButton", {
                    Parent = sliderBar,
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((value-min)/(max-min), -7, 0.5, -7),
                    BackgroundColor3 = Theme.Text,
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
                        value = math.clamp(v, min, max)
                        local rel = (value-min)/(max-min)
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        grab.Position = UDim2.new(rel, -7, 0.5, -7)
                        label.Text = (data.Name or "Slider") .. ": " .. tostring(value)
                        if data.Callback then data.Callback(value) end
                    end
                }
            end

            ------------------------------------------------
            -- DROPDOWN
            ------------------------------------------------
            function SectionAPI:CreateDropdown(data)
                local options = data.Options or {}
                local selected = data.Default or options[1]
                local frame = addElementFrame(36)
                local btn = newInstance("TextButton", {
                    Parent = frame,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = (data.Name or "Dropdown") .. ": " .. tostring(selected),
                    BackgroundColor3 = Color3.fromRGB(35,35,50),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    AutoButtonColor = false
                }, 6)
                local dropdownFrame = newInstance("Frame", {
                    Parent = frame,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = Theme.Sidebar,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 2
                }, 6)
                local listLayout = newInstance("UIListLayout", {
                    Parent = dropdownFrame,
                    Padding = UDim.new(0, 2)
                })
                for _, opt in ipairs(options) do
                    local optBtn = newInstance("TextButton", {
                        Parent = dropdownFrame,
                        Size = UDim2.new(1, 0, 0, 30),
                        Text = opt,
                        BackgroundColor3 = Theme.Sidebar,
                        TextColor3 = Theme.SubText,
                        Font = Enum.Font.Gotham,
                        TextSize = 13,
                        AutoButtonColor = false
                    }, 4)
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
                    dropdownFrame.Size = vis and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 0, #options * 32)
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

            ------------------------------------------------
            -- TEXTBOX
            ------------------------------------------------
            function SectionAPI:CreateTextbox(data)
                local frame = addElementFrame(36)
                local box = newInstance("TextBox", {
                    Parent = frame,
                    Size = UDim2.new(1, 0, 1, 0),
                    PlaceholderText = data.Name or "Enter text...",
                    Text = "",
                    BackgroundColor3 = Color3.fromRGB(35,35,50),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    ClearTextOnFocus = false
                }, 6)
                box.FocusLost:Connect(function()
                    if data.Callback then data.Callback(box.Text) end
                end)
                return box
            end

            ------------------------------------------------
            -- KEYBIND
            ------------------------------------------------
            function SectionAPI:CreateKeybind(data)
                local key = data.Default or Enum.KeyCode.None
                local frame = addElementFrame(36)
                local btn = newInstance("TextButton", {
                    Parent = frame,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = (data.Name or "Keybind") .. ": " .. (key.Name or "None"),
                    BackgroundColor3 = Color3.fromRGB(35,35,50),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    AutoButtonColor = false
                }, 6)
                local listening = false
                btn.MouseButton1Click:Connect(function()
                    listening = true
                    btn.Text = "... press a key ..."
                end)
                local function onInput(input, processed)
                    if not listening or processed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        btn.Text = (data.Name or "Keybind") .. ": " .. (key.Name or "None")
                        listening = false
                        if data.Callback then data.Callback(key) end
                    end
                end
                UserInputService.InputBegan:Connect(onInput)
                return {
                    SetValue = function(k)
                        key = k
                        btn.Text = (data.Name or "Keybind") .. ": " .. (key.Name or "None")
                        if data.Callback then data.Callback(key) end
                    end
                }
            end

            ------------------------------------------------
            -- COLOR PICKER (simple palette)
            ------------------------------------------------
            function SectionAPI:CreateColorPicker(data)
                local color = data.Default or Theme.Accent
                local frame = addElementFrame(36)
                local btn = newInstance("TextButton", {
                    Parent = frame,
                    Size = UDim2.new(1, -50, 1, 0),
                    Text = data.Name or "Color Picker",
                    BackgroundColor3 = Color3.fromRGB(35,35,50),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    AutoButtonColor = false
                }, 6)
                local colorDisplay = newInstance("Frame", {
                    Parent = frame,
                    Size = UDim2.new(0, 30, 0, 30),
                    Position = UDim2.new(1, -40, 0.5, -15),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0
                }, 6)

                btn.MouseButton1Click:Connect(function()
                    local picker = newInstance("Frame", {
                        Parent = PagesContainer,
                        Size = UDim2.new(0, 200, 0, 150),
                        Position = UDim2.new(0.5, -100, 0.5, -75),
                        BackgroundColor3 = Theme.Sidebar,
                        ZIndex = 20
                    }, 10)
                    addShadow(picker, 4, 0.8)
                    local palette = {Color3.fromRGB(255,80,80), Color3.fromRGB(80,255,80), Color3.fromRGB(80,80,255),
                                     Color3.fromRGB(255,255,80), Color3.fromRGB(255,80,255), Color3.fromRGB(80,255,255),
                                     Color3.fromRGB(255,128,0), Color3.fromRGB(0,255,128), Color3.fromRGB(128,0,255)}
                    for i, c in ipairs(palette) do
                        local swatch = newInstance("TextButton", {
                            Parent = picker,
                            Size = UDim2.new(0, 50, 0, 50),
                            Position = UDim2.new(0.1 + ((i-1)%3)*0.27, 0, 0.15 + math.floor((i-1)/3)*0.3, 0),
                            BackgroundColor3 = c,
                            Text = "",
                            AutoButtonColor = false
                        }, 8)
                        swatch.MouseButton1Click:Connect(function()
                            color = c
                            colorDisplay.BackgroundColor3 = color
                            if data.Callback then data.Callback(color) end
                            picker:Destroy()
                        end)
                    end
                    local closePicker = newInstance("TextButton", {
                        Parent = picker,
                        Size = UDim2.new(0, 60, 0, 28),
                        Position = UDim2.new(0.5, -30, 0.8, 0),
                        Text = "Close",
                        BackgroundColor3 = Theme.Accent,
                        TextColor3 = Theme.Text,
                        Font = Enum.Font.Gotham,
                        TextSize = 13
                    }, 6)
                    closePicker.MouseButton1Click:Connect(function()
                        picker:Destroy()
                    end)
                end)

                return {
                    SetValue = function(c)
                        color = c
                        colorDisplay.BackgroundColor3 = c
                        if data.Callback then data.Callback(c) end
                    end
                }
            end

            table.insert(Tab.Sections, SectionAPI)
            return SectionAPI
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

------------------------------------------------
-- CONSTRUCTOR
------------------------------------------------
function Vertex.new()
    return setmetatable({}, Vertex)
end

-- Return the library
return Vertex
