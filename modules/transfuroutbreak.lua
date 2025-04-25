--[[
universal.lua
Universal settings for all games
]]
local module = {}
local runservice = game:GetService("RunService")
local replicatedstorage = game:GetService("ReplicatedStorage")
function UpdateDisabled(path, state)
    for _, object in pairs(path:GetDescendants()) do
        if object:IsA("BasePart") then
            if object.CanTouch ~= state then
                object.CanTouch = state
            end
        end
    end
end

local ui_data = {
    type = "UI",
    values = {
        ["Rage"] = {
            ["Auto Melee"] = {
                delay = 1,
                range = 1,
                max_targets = 1,
            }
        },
        ["Misc"] = {
            ["Global"] = {},
            ["Disablers"] = {},
        }
    },
    items = {
        ["Rage"] = {
            ["Silent aimbot"] = {
                {
                    type = "text",
                    text = "IN DEVELOPMENT"
                },
                {
                    type = "enabled",
                    text = "Enable",
                    name = "aimbot_enabled",
                    bind = Enum.KeyCode.Unknown,
                },

            },
            ["Auto Melee"] = {
                {
                    name = "enabled",
                    type = "checkbox",
                    text = "Enabled",
                    bind = Enum.KeyCode.Unknown,
                },
                {
                    type = "text",
                    text = "NOTE: high target count + small delay = kick"
                },
                {
                    name = "delay",
                    type = "slider",
                    text = "delay",
                    default = 1,
                    min = 0.1,
                    max = 1,
                    callback = nil,
                },
                {
                    name = "range",
                    type = "slider",
                    text = "range",
                    default = 1,
                    min = 1,
                    max = 30,
                    value = 1,
                    callback = nil,
                },
                {
                    name = "max_targets",
                    type = "slider",
                    text = "Maximum targets per hit",
                    default = 1,
                    min = 1,
                    max = 15,
                    value = 1,
                    callback = nil,
                    whole = true,
                },
                {
                    name = "heavy_hits",
                    type = "checkbox",
                    text = "Only heavy hits"
                }
            },
        },
        ["Misc"] = {
            ["Global"] = {
                {
                    type = "text",
                    text = "works both for infected and humans"
                },
                {
                    name = "inf_stamina",
                    type = "checkbox",
                    text = "infinite stamina",
                    state = false,
                    bind = Enum.KeyCode.Unknown,
                    callback = nil,
                },
                -- Walkspeed stuff
                {
                    name = "walkspeed_enabled",
                    type = "checkbox",
                    text = "walkspeed changer",
                    before_state = false,
                    state = false,
                    bind = Enum.KeyCode.Unknown,
                    callback = nil,
                },
                {
                    name = "walkspeed",
                    type = "slider",
                    text = "walkspeed",
                    default = 16,
                    min = 0,
                    max = 100,
                    value = 16,
                    callback = nil,
                },
            },
            ["Disablers"] = {
                {
                    name = "disable_goo",
                    type = "checkbox",
                    text = "disable goo",
                    state = false,
                    callback = function(state)
                        UpdateDisabled(game.Workspace.Infections, not state)
                    end,
                },
                {
                    name = "disable_cones",
                    type = "checkbox",
                    text = "disable cones",
                    state = false,
                    callback = function(state)
                        UpdateDisabled(game.Workspace.Cones, not state)
                    end,
                },
                {
                    name = "disable_safelocks",
                    type = "checkbox",
                    text = "disable safelocked doors",
                    -- workspace.SafelockedDoors
                    state = false,
                    callback = function(state)
                        local folder = workspace.SafelockedDoors
                        for _, object in pairs(folder:GetDescendants()) do
                            if object:IsA("BasePart") then
                                object.CanCollide = not state
                            end
                        end
                    end
                },
                {
                    type = "text",
                    text = "^ this one also allows you to enter safezone with combat"
                },
                {
                    name = "disable_safezones",
                    type = "checkbox",
                    text = "disable killfields blockage",
                    state = false,
                    callback = function(state)
                        UpdateDisabled(workspace.KillfieldZone, not state)
                    end
                },
            }
        }
    }
}

local items = ui_data.values
local misc = items.Misc
local player = game.Players.LocalPlayer

local heartbeat = nil

function Stamina()
    if misc.Global.inf_stamina then
        replicatedstorage.SprintStamina.Value = 100
    end
end

function Humanoid()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if misc.Global.walkspeed_enabled then
                if math.floor(humanoid.WalkSpeed) ~= math.floor(misc.Global.walkspeed or 0) then
                    misc.Global["old_walkspeed"] = humanoid.WalkSpeed
                end
                humanoid.WalkSpeed = misc.Global.walkspeed
            else
                if misc.Global["old_walkspeed"] and math.floor(misc.Global["old_walkspeed"]) ~= 0 then
                    humanoid.WalkSpeed = misc.Global["old_walkspeed"]
                    misc.Global["old_walkspeed"] = 0
                end
            end
        end
    end
end

function GetNearest()
    local targets = {}
    for _, target in pairs(game.Players:GetPlayers()) do
        if target.Team ~= player.Team then
            local character = target.Character
            if character then
                local humanoidrootpart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                local local_hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidrootpart and humanoid and humanoid.Health > 0 and (local_hrp.Position-humanoidrootpart.Position).Magnitude <= items.Rage["Auto Melee"].range then
                    table.insert(targets, target)
                end
            end
        end
    end
    return targets
end

local KillAura_Tick = 0
local MeleeRemote = replicatedstorage:FindFirstChild("MeleeDamage")
function KillAura()
    if not items.Rage["Auto Melee"].enabled then
        return
    end
    local targets = GetNearest()
    local character = player.Character
    if not character then
        return
    end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        return
    end
    local version = tool:FindFirstChild("ScriptVersion")
    if not version or not string.find(version.Value, "Melee") then
        return
    end
    if #targets <= 0 then return end
    
    if (tick() - KillAura_Tick) < items.Rage["Auto Melee"].delay then
        return
    end
    KillAura_Tick = tick()

    local target_count = 0
    for _, target in pairs(targets) do
        target_count = target_count + 1
        if target_count > items.Rage["Auto Melee"].max_targets then
            return
        end
        MeleeRemote:FireServer(target.Character:FindFirstChildOfClass("Humanoid"), nil, items.Rage["Auto Melee"].heavy_hits)
    end
end

function module.Initialize(library)
    -- Remove anticheat
    local AC = game.Players.LocalPlayer.PlayerScripts:FindFirstChild("AC")
    if AC then
        AC.Name = "ez bypass"
        local kick_shit = game.ReplicatedStorage:WaitForChild("Color")
        if kick_shit then
            kick_shit.Name = "ezez"
        end
        -- because we bricked antiantianticheat we can now delete anticheat instance
        AC:Destroy()
    end
    local namecall
    -- Yeah, shitty way but works!!!

    -- local debugtext = Drawing.new("Text")
    -- debugtext.Text =  "BINDS (placeholder)"
    -- debugtext.Visible = true
    -- debugtext.Size = 14
    -- debugtext.Color = Color3.new(1,0,0)

    module.library = library

    ui_data.UpdateValues = function(new_table)
        ui_data.values = new_table
    end
    module.library.JSONUI.parse(ui_data)

    heartbeat = runservice.Heartbeat:Connect(function()
        if module.library.ALIVE == false then
            -- debugtext:Remove()
            heartbeat:Disconnect()
            return
        end
        KillAura()
        Stamina()
        Humanoid()
    end)
    -- setup SafelockedDoors
    local folder = workspace.SafelockedDoors
    for _, object in pairs(folder:GetDescendants()) do
        if object:IsA("BasePart") then
            local signal = nil
            signal = object:GetPropertyChangedSignal("CanCollide"):Connect(function()
                if module.library.ALIVE == false then
                    signal:Disconnect()
                    return
                end
                if misc.Disablers.disable_safelocks then
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
            descendant.CanTouch = not misc.Disablers["disable_cones"]
        end
    end)
    connection = infections.DescendantAdded:Connect(function(descendant)
        if module.library.ALIVE == false then
            connection:Disconnect()
            return
        end
        if descendant:IsA("BasePart") and descendant.CanTouch then
            descendant.CanTouch = not misc.Disablers["disable_goo"]
        end
    end)
end

return module