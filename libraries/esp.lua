local esp = {}
local camera = workspace.CurrentCamera

local esp_table = {}
local esp_items = {}

function esp.update()
    for identifier, esp_values in pairs(esp_table) do
        local current_items = esp_items[identifier]
        if not current_items then
            esp_items[identifier] = {}
            current_items = esp_items[identifier]
        end

        if esp_values["mode"] == "3D" then
            local top_left_screen, top_left_visible = camera:WorldToViewportPoint(esp_values.top_left)
            local bottom_left_screen, bottom_left_visible = camera:WorldToViewportPoint(esp_values.bottom_left)
            local top_right_screen, top_right_visible = camera:WorldToViewportPoint(esp_values.top_right)
            local bottom_right_screen, bottom_right_visible = camera:WorldToViewportPoint(esp_values.bottom_right)

            if top_left_visible or bottom_left_visible or top_right_visible or bottom_right_visible then
                local outline = current_items["box_outline"] or Drawing.new("Quad")
                outline.Color = Color3.new(0,0,0)
                outline.Thickness = 4
                outline.Filled = true
                outline.PointA = Vector2.new(top_left_screen.X,top_left_screen.Y)
                outline.PointB = Vector2.new(top_right_screen.X,top_right_screen.Y)
                outline.PointD = Vector2.new(bottom_left_screen.X,bottom_left_screen.Y)
                outline.PointC = Vector2.new(bottom_right_screen.X,bottom_right_screen.Y)
                outline.Visible = esp_values.border or false

                local box = current_items["box"] or Drawing.new("Quad")
                box.Color = esp_values.color
                box.Thickness = 2
                box.Filled = false
                box.PointA = Vector2.new(top_left_screen.X,top_left_screen.Y)
                box.PointB = Vector2.new(top_right_screen.X,top_right_screen.Y)
                box.PointD = Vector2.new(bottom_left_screen.X,bottom_left_screen.Y)
                box.PointC = Vector2.new(bottom_right_screen.X,bottom_right_screen.Y)
                box.Visible = esp_values.visible or true

                current_items["box"] = box
                current_items["box_outline"] = outline
            else
                for _, draw in pairs(current_items) do
                    draw.Visible = false
                end
            end
        elseif esp_values["mode"] == "2D" then
            local pos = esp_values.pos or Vector2.new(0,0)
            local width = esp_values.width or Vector2.new(0,0)
            local height = esp_values.height or Vector2.new(0,0)

            local outline = current_items["box_outline"] or Drawing.new("Quad")
            outline.Color = Color3.new(0,0,0)
            outline.Thickness = 4
            outline.Filled = false
            outline.PointA = Vector2.new(pos.X + width,pos.Y - height)
            outline.PointB = Vector2.new(pos.X - width,pos.Y - height)
            outline.PointC = Vector2.new(pos.X - width,pos.Y + height)
            outline.PointD = Vector2.new(pos.X + width,pos.Y + height)
            outline.Visible = (esp_values.visible and esp_values.border) or false

            local box = current_items["box"] or Drawing.new("Quad")
            box.Color = esp_values.color or Color3.new(0,0,1)
            box.Thickness = 2
            box.Filled = false
            box.PointA = Vector2.new(pos.X + width,pos.Y - height)
            box.PointB = Vector2.new(pos.X - width,pos.Y - height)
            box.PointC = Vector2.new(pos.X - width,pos.Y + height)
            box.PointD = Vector2.new(pos.X + width,pos.Y + height)
            box.Visible = esp_values.visible or false

            if esp_values.visible == false then
                box:Remove()
                box = nil
                outline:Remove()
                outline = nil
            end

            current_items["box"] = box
            current_items["box_outline"] = outline
        elseif esp_values["mode"] == "text" then
            local pos = esp_values.pos or Vector2.new(0,0)
            local text = esp_values.text or "me when no text"

            local label = current_items[identifier] or Drawing.new("Text")
            label.Color = esp_values.color or Color3.new(0,0,1)
            label.Thickness = 2
            label.Filled = false
            label.Position = pos - Vector3.new(0, 14/2, 0)
            label.Text = text
            label.Size = 14
            label.Visible = esp_values.visible or true

            if esp_values.visible == false then
                label:Remove()
                label = nil
            end

            current_items[identifier] = label
        end
    end
end

function esp.add_box(identifier, top_left, bottom_left, top_right, bottom_right, color)
    esp_table[identifier] = {
        mode = "3D",
        top_left = top_left,
        bottom_left = bottom_left,
        top_right = top_right,
        bottom_right = bottom_right,
        color = color,
        border = true,
    }
end

function esp.add_2d_box(identifier, pos, width, height, visible, color)
    esp_table[identifier] = {
        mode = "2D",
        pos = pos,
        width = width,
        height = height,
        visible = visible,
        color = color,
        border = true,
    }
end

function esp.add_text(identifier, pos, text, visible, color)
    esp_table[identifier] = {
        mode = "text",
        pos = pos,
        text = text,
        visible = visible,
        color = color,
        border = true,
    }
end

function esp.add_part(identifier, part)
    local cframe = part.CFrame
    local size = part.Size
    local top_left = (cframe * CFrame.new(-size.X/2, size.Y/2, 0)).Position
    local bottom_left = (cframe * CFrame.new(-size.X/2, -size.Y/2, 0)).Position
    local top_right = (cframe * CFrame.new(size.X/2, size.Y/2, 0)).Position
    local bottom_right = (cframe * CFrame.new(size.X/2, -size.Y/2, 0)).Position

    esp.add_box(identifier, top_left, bottom_left, top_right, bottom_right)
end

function esp.add_player(identifier, character, color) -- oh my god its bad looking but im too lazy to fix it (i wasted 3 hour on programming esp, ok?)
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if not (hrp or head) then return end

    local hrp_pos, hrp_visible = camera:WorldToViewportPoint(hrp.Position)
    local head_pos, head_visible = camera:WorldToViewportPoint(head.Position)

    -- local hrp_cframe = hrp.CFrame
    -- local hrp_size = hrp.Size
    -- local head_cframe = hrp_cframe.Rotation + Vector3.new(hrp_cframe.X, head.CFrame.Y, hrp_cframe.Z)
    -- local head_size = head.Size

    -- local top_left =       (head_cframe * CFrame.new(hrp_size.X, head_size.Y/2, 0)).Position
    -- local bottom_left =    (hrp_cframe * CFrame.new(hrp_size.X, -hrp_size.Y/2, 0)).Position - Vector3.new(0, 2.5, 0)
    -- local top_right =      (head_cframe * CFrame.new(-hrp_size.X, head_size.Y/2, 0)).Position
    -- local bottom_right =   (hrp_cframe * CFrame.new(-hrp_size.X, -hrp_size.Y/2, 0)).Position - Vector3.new(0, 2.5, 0)

    -- esp.add_box(identifier, top_left, bottom_left, top_right, bottom_right, color)

    -- new box system (finally)

    local DistanceY = math.clamp((Vector2.new(head_pos.X, head_pos.Y) - Vector2.new(hrp_pos.X, hrp_pos.Y)).Magnitude, 2, math.huge)
    esp.add_2d_box(identifier, hrp_pos, DistanceY, DistanceY * 2, hrp_visible, color)
    -- esp.add_text(identifier.."name", head_pos, character.Name, hrp_visible, color)
end

function esp.clear_items()
    table.clear(esp_table)
end

function esp.clear()
    for _, esp_item in pairs(esp_items) do
        if not esp_item then continue end
        for _, draw in pairs(esp_item) do
            draw:Remove()
        end
    end
    table.clear(esp_items)
end

return esp