--[[
universal.lua
Universal settings for all games
]]
local module = {}

local ui_data = {
    type = "UI",
    items = {
        ["General"] = {
            ["Main"] = {
                {
                    type = "text",
                    text = "Hello World!"
                },
                {
                    type = "button",
                    text = "Button",
                    callback = function()
                        print("you pressed button!")
                    end
                },
                {
                    type = "checkbox",
                    text = "check me!",
                    state = false,
                    bind = Enum.KeyCode.Unknown,
                    callback = nil,
                }
            }
        }
    }
}

function module.Initialize(library)
    module.library = library
 
    module.library.JSONUI.parse(ui_data)
end

return module