local utility = loadstring(game:HttpGet(getgenv().MAINURL.."core/utility.lua", true))()

return {
    type = "UI",
    values = {
        ["Rage"] = {
            ["Auto Melee"] = {
                delay = 1,
                range = 1,
                max_targets = 1,
            },
            ["Auto Fire"] = {}
        },
        ["Visuals"] = {
            ["Players"] = {},
            ["Camera"] = {},
            ["Other"] = {}
        },
        ["Misc"] = {
            ["Global"] = {},
            ["Disablers"] = {},
            ["Weapon Modifier"] = {}
        }
    },
    elements = {},
    items = {
        ["Rage"] = {
            ["Auto Fire"] = {
                {
                    type = "checkbox",
                    text = "Enabled",
                    friendly_name = "AutoFire",
                    name = "enabled",
                    bind = Enum.KeyCode.Unknown,
                },
                {
                    name = "delay",
                    type = "slider",
                    text = "Delay",
                    min = 0.03,
                    max = 3,
                    default = 1,
                    callback = nil,
                },
                {
                    type = "text",
                    text = "if you use burst delay will automatically be 1+ second"
                },
                {
                    name = "wallcheck",
                    type = "checkbox",
                    text = "Wall check",
                    default = true
                },
                {
                    name = "prediction",
                    type = "checkbox",
                    text = "Damage prediction (demo)",
                    default = true
                }
            },
            ["Auto Melee"] = {
                {
                    name = "enabled",
                    type = "checkbox",
                    text = "Enabled",
                    friendly_name = "AutoMelee",
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
                    max = 15,
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
                    text = "Force heavy hits",
                    state = false,
                },
            }
        },
        ["Visuals"] = {
            ["Players"] = {
                {
                    name = "pesp_enabled",
                    type = "checkbox",
                    text = "Enabled",
                },
                {
                    name = "ignore_team",
                    type = "checkbox",
                    text = "Ignore team",
                },
                {
                    name = "box_enabled",
                    type = "checkbox",
                    text = "Box",
                },
                {
                    name = "box_color",
                    type = "color",
                    text = "Box color",
                    default = Color3.new(1,0,0)
                }
            },
            ["Other"] = {
                {
                    type = "text",
                    text = "!!!UNDER CONSTRUCTION!!!"
                },
                {
                    name = "china_hat",
                    type = "checkbox",
                    text = "China hat"
                },
                {
                    name = "china_color",
                    type = "color",
                    text = "Color",
                    default = Color3.new(255,255,255)
                },
            },
            ["Camera"] = {
                {
                    name = "camera_enabled",
                    type = "checkbox",
                    text = "Custom camera"
                },
                {
                    name = "camera_fov",
                    type = "slider",
                    text = "FOV",
                    default = 70,
                    min = 10,
                    max = 120,
                    value = 70,
                },
                {
                    name = "disable_camerahandler",
                    type = "checkbox",
                    text = "Disable camera head follow"
                },
            }
        },
        ["Misc"] = {
            ["Global"] = {
                {
                    name = "inf_stamina",
                    type = "checkbox",
                    text = "infinite stamina",
                    friendly_name = "Infinite stamina",
                    state = false,
                    bind = Enum.KeyCode.Unknown,
                    callback = nil,
                },
                -- Walkspeed stuff
                {
                    name = "walkspeed_enabled",
                    type = "checkbox",
                    text = "walkspeed changer",
                    friendly_name = "Walkspeed",
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
                {
                    name = "fake_block",
                    type = "checkbox",
                    text = "Silent block",
                    state = false,
                },
                {
                    name = "insta_ungrab",
                    type = "checkbox",
                    text = "Instant grab escape",
                    state = false,
                }
            },
            ["Disablers"] = {
                {
                    name = "disable_collision",
                    type = "checkbox",
                    text = "Disable infections/void",
                    state = false,
                },
                {
                    name = "noclip",
                    type = "checkbox",
                    text = "Disable player collision (noclip)",
                    friendly_name = "Noclip",
                    bind = Enum.KeyCode.Unknown,
                    state = false,
                },
                {
                    name = "disable_safelocks",
                    type = "checkbox",
                    text = "Disable safelocked doors",
                    -- workspace.SafelockedDoors
                    state = false,
                    callback = function(state)
                        if state == false then return end
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
                    text = "Disable killfields blockage",
                    state = false,
                    callback = function(state)
                        utility.UpdateDisabled(workspace.KillfieldZone, not state)
                    end
                },
            },
            ["Weapon Modifier"] = {
                {
                    name = "no_recoil",
                    type = "checkbox",
                    text = "Remove recoil"
                },
                {
                    name = "no_spread",
                    type = "checkbox",
                    text = "Remove spread"
                },
            }
        }
    }
}
