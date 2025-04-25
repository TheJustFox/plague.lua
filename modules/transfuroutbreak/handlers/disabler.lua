local module = {}

function module.Initialize(library)
    -- This method is used for calling functions every rendering frame
    module.ui = library.ELEMENTS
    module.library = library

    -- setup SafelockedDoors
    local section = module.ui.values.Misc.Disablers
    local folder = workspace.SafelockedDoors
    for _, object in pairs(folder:GetDescendants()) do
        if object:IsA("BasePart") then
            local signal = nil
            signal = object:GetPropertyChangedSignal("CanCollide"):Connect(function()
                if module.library.ALIVE == false then
                    signal:Disconnect()
                    return
                end
                if section.disable_safelocks then
                    object.CanCollide = false
                end
            end)
        end
    end
    -- update descnands
    local cones = game.Workspace.Cones
    local infections = game.Workspace.Infections
    local connection = nil
    connection = cones.DescendantAdded:Connect(function(descendant)
        if module.library.ALIVE == false then
            connection:Disconnect()
            return
        end
        if descendant:IsA("BasePart") and descendant.CanTouch then
            descendant.CanTouch = not section["disable_cones"]
        end
    end)
    connection = infections.DescendantAdded:Connect(function(descendant)
        if module.library.ALIVE == false then
            connection:Disconnect()
            return
        end
        if descendant:IsA("BasePart") and descendant.CanTouch then
            descendant.CanTouch = not section["disable_goo"]
        end
    end)
end

return module