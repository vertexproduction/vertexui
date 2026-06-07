local Vertex = {}

function Vertex:CreateWindow(config)
    local gui = Instance.new("ScreenGui")
    gui.Name = "VertexUI"
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    mainFrame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = config.Title or "Vertex"
    title.Size = UDim2.new(1,0,0,30)
    title.BackgroundColor3 = Color3.fromRGB(50,50,70)
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = mainFrame
    
    -- More instance creation...
    
    local Window = {}
    function Window:CreateTab(name)
        -- Create tab button and content frame
        return Tab
    end
    return Window
end

return Vertex
