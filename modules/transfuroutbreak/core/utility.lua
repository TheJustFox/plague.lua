local utility = {}

function utility.UpdateDisabled(path, state)
    -- for _, object in pairs(path:GetDescendants()) do
    --     if object:IsA("BasePart") then
    --         if object.CanTouch ~= state then
    --             object.CanTouch = state
    --         end
    --     end
    -- end
    -- disabled cause detected
end

function utility.GetNearest(range)
    local player = game:GetService("Players").LocalPlayer
    local targets = {}
    for _, target in pairs(game.Players:GetPlayers()) do
        if target == player then continue end
        if target.Team ~= player.Team then
            local character = target.Character
            if character then
                local humanoidrootpart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                local local_hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidrootpart and humanoid and humanoid.Health > 0 and (local_hrp.Position - humanoidrootpart.Position).Magnitude <= range then
                    table.insert(targets, target)
                end
            end
        end
    end
    return targets
end

return utility
