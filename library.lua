--[[
library.lua
This file is for initializing all of libraries correctly
]]
local library = {}
library.URL = getgenv().HOST
local libraries = library.URL.."libraries/"

function library.Initialize(gamename)
    library.UI = loadstring(game:HttpGet(libraries.."ui.lua", true))()
    library.JSONUI = loadstring(game:HttpGet(libraries.."jsonui.lua", true))()
    library.ALIVE = true
    library.JSONUI.Initialize(library)

    if gamename then
        library.MAINURL = library.URL.."modules/"..gamename.."/"
        getgenv().MAINURL = library.MAINURL
    end

    getgenv().Unload = function()
        library.ALIVE = false
        library.UI.Unload()
        library.JSONUI.Unload()
    end
end

return library