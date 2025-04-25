--[[
jsonui.lua
Library to convert json input into elements
]]
local jsonui = {}

local unload_elements = {}

local httpservice = game:GetService("HttpService")

function jsonui.Unload()
    for _, element in pairs(unload_elements) do
        element.state = false
        if element.callback then
            element.callback(false)
        end
    end
end

local last_input = {}

local sounds = {
    on = nil;
    off = nil;
}

local preload_sounds = function()
    if sounds.on ~= nil then return end
    local sound_id = 15675059323
    local on_sound = Instance.new("Sound")
    on_sound.Parent = workspace
    on_sound.SoundId = "rbxassetid://"..sound_id

    local off_sound = on_sound:Clone()
    off_sound.Parent = workspace
    off_sound.SoundId = "rbxassetid://"..sound_id
    off_sound.Pitch = 0.7
    sounds.off = off_sound
end

function intrl_ParseElement(path, elements_path, data, section)
    local element_type = data["type"]
    if element_type == "text" then
        section:AddLabel(data["text"])
        return
    elseif element_type == "button" then
        section:AddButton(data["text"],data["callback"])
    elseif element_type == "checkbox" then
        path[data.name] = data["default"] or false
        elements_path[data.name] = section:AddToggle(data["text"],data["default"],data["bind"],function(state)
            if data["callback"] then
                data["callback"](state)
            end
            -- if state == true then
            --     sounds.on:Play()
            -- else
            --     sounds.off:Play()
            -- end
            path[data.name] = state -- So i don't have to type this all of the time
        end, data["friendly_name"])
        table.insert(unload_elements, data)
    elseif element_type == "slider" then
        path[data.name] = data["default"] or 0
        elements_path[data.name] = section:AddSlider(data["text"],data["max"],data["min"],data["default"],function(val)
            path[data.name] = val
            if data["callback"] then
                data["callback"](val)
            end
        end, data["whole"])
    elseif element_type == "color" then
        path[data.name] = data["default"] or Color3.new(0,0,0)
        elements_path[data.name] = section:AddColorPallete(data["text"], data["default"],function(val)
            path[data.name] = val
            if data["callback"] then
                data["callback"](val)
            end
        end)
    elseif element_type == "dropdown" then
        path[data.name] = data["default"] or 1
        section:AddDropdown(data["text"], data["options"], data["default"], function(val)
            -- val is name of the option
            local option_id = 0
            for _, option in pairs(data["options"]) do
                option_id = option_id + 1
                if option == val then
                    break
                end
            end
            path[data.name] = option_id
        end)
    elseif element_type == "players" then
        path[data.name] = nil
        local sanitized = {}
        for _, plr in game:GetService("Players"):GetPlayers() do
            table.insert(sanitized, plr.Name)
        end
        section:AddDropdown(data["text"], sanitized, data["default"], function(val)
            path[data.name] = game:GetService("Players"):FindFirstChild(val).Character
        end)
    end
end

function intrl_ParseUI(input)
    -- preload_sounds()
    local items = input["items"]
    if items == nil then
        return
    end
    last_input = input
    if input["values"] == nil then
        input["values"] = {}
    end
    local values = input["values"]
    if input["elements"] == nil then
        input["elements"] = {}
    end
    local elements = input["elements"]
    for window_name, window_data in pairs(items) do
        local window = jsonui.library.UI:AddWindow(window_name)
        if elements[window_name] == nil then
            elements[window_name] = {}
        end
        if values[window_name] == nil then
            values[window_name] = {}
        end
        for section_name, section_data in pairs(window_data) do
            local section = window:AddSection(section_name)
            if elements[window_name][section_name] == nil then
                elements[window_name][section_name] = {}
            end
            if values[window_name][section_name] == nil then
                values[window_name][section_name] = {}
            end
            for _, object in pairs(section_data) do
                intrl_ParseElement(values[window_name][section_name], elements[window_name][section_name], object, section)
            end
        end
    end
end

function printTable(values)
    for i, v in pairs(values) do
        if type(v) == "table" then
            printTable(v)
        else
            print(i, " ", v)
        end
    end
end

function jsonui.SaveConfig(cfg_name)
    makefolder("plague")
    if not isfolder(string.format("plague/%i", game.PlaceId)) then
        makefolder(string.format("plague/%i", game.PlaceId))
    end

    local data = {}
    for tab_name, tab_data in pairs(last_input.elements) do
        if data[tab_name] == nil then
            data[tab_name] = {}
        end
        for section_name, section_data in pairs(tab_data) do
            if data[tab_name][section_name] == nil then
                data[tab_name][section_name] = {}
            end
            for element_name, element in pairs(section_data) do
                print(tab_name,section_name,element_name)
                if element["get"] then
                    data[tab_name][section_name][element_name] = element:get()
                    continue
                end
                data[tab_name][section_name][element_name] = last_input.values[tab_name][section_name][element_name]
            end
        end
    end

    local config = httpservice:JSONEncode(data)
    writefile(string.format("plague/%i/%s", game.PlaceId, cfg_name), config)
end

function jsonui.LoadConfig(cfg_name)
    if not isfolder(string.format("plague/%i", game.PlaceId)) then
        makefolder(string.format("plague/%i", game.PlaceId))
    end
    local config = readfile(string.format("plague/%i/%s", game.PlaceId, cfg_name))
    if config == nil then
        return
    end

    local config_table = httpservice:JSONDecode(config) -- TODO: anti error
    for window_name, sections in config_table do
        local current_window = last_input.elements[window_name]
        if current_window == nil then continue end

        for section_name, elements in sections do
            local current_section = current_window[section_name]
            if current_window == nil then continue end

            for element_name, element_data in elements do
                if element_data == nil then continue end
                local current_element = current_section[element_name]
                if current_element == nil then continue end

                if current_element["set"] then
                    task.spawn(function()
                        current_element:set(element_data)
                    end)
                end
            end
        end
    end
end

function jsonui.parse(input)
    if type(input) ~= "table" then
        error("Not valid type")
        return nil
    end
    local json_type = input["type"]
    if json_type == "UI" then
        intrl_ParseUI(input)
    end

    return nil
end

function jsonui.Initialize(library)
    jsonui.library = library
end

return jsonui