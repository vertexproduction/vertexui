-- Vertex Development UI Library
-- Source.lua

local Vertex = {}
Vertex.__index = Vertex

function Vertex:CreateWindow(config)
local Window = {}
Window.Title = config.Title or "Vertex Development"

```
function Window:CreateTab(name)
    local Tab = {}
    Tab.Name = name

    function Tab:CreateSection(name)
        local Section = {}
        Section.Name = name

        function Section:CreateToggle(data)
            local Toggle = {
                Name = data.Name,
                Value = data.Default or false,
                Callback = data.Callback or function() end
            }

            function Toggle:Set(value)
                self.Value = value
                self.Callback(value)
            end

            return Toggle
        end

        function Section:CreateButton(data)
            return {
                Name = data.Name,
                Callback = data.Callback
            }
        end

        function Section:CreateSlider(data)
            return {
                Name = data.Name,
                Min = data.Min or 0,
                Max = data.Max or 100,
                Default = data.Default or 0,
                Callback = data.Callback
            }
        end

        function Section:CreateDropdown(data)
            return {
                Name = data.Name,
                Options = data.Options or {},
                Callback = data.Callback
            }
        end

        return Section
    end

    return Tab
end

return Window
```

end

function Vertex.new()
return setmetatable({}, Vertex)
end

return Vertex
