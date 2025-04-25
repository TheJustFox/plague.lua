local main = {}

local modules = {}
local elements = {}

function main.Initialize(library)
    -- execute autorun
    local handlers = library.MAINURL.."handlers/"
    local config = library.MAINURL.."config/"

    -- load elements
    elements = loadstring(game:HttpGet(config.."ui_data.lua", true))()
    library.JSONUI.parse(elements)
    library.ELEMENTS = elements

    local autoruns = loadstring(game:HttpGet(handlers.."autorun.lua", true))()
    for _, path in pairs(autoruns) do
        local global_path = library.MAINURL..path
        local module = loadstring(game:HttpGet(global_path, true))()
        if module and module["Initialize"] then
            modules[path] = module
            module.Initialize(library) -- not all modules use library, but some do
        end
    end
end

function main.Unload()
    for _, module in pairs(modules) do
        if module and module["Unload"] then
            module.Unload()
        end
    end
end

return main