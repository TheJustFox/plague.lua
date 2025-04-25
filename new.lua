local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
getgenv().HOST = "https://github.com/TheJustFox/plague.lua/raw/refs/heads/main/"

local Plague = Instance.new("ScreenGui")
local TextLabel = Instance.new("TextLabel")

Plague.Name = "intro"
Plague.Parent = game:GetService("CoreGui")
Plague.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Plague.DisplayOrder = 999

TextLabel.Parent = Plague
TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
TextLabel.Size = UDim2.new(0.300000012, 0, 0.300000012, 0)
TextLabel.Font = Enum.Font.Gotham
TextLabel.Text = "Initializing..."
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 1.000
TextLabel.TextTransparency = 1
TextLabel.TextWrapped = true

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Workspace.CurrentCamera

TweenService:Create(TextLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()
TweenService:Create(blur, TweenInfo.new(1), {Size = 24}):Play()

local library = loadstring(game:HttpGet(getgenv().HOST.."library.lua", true))()

local gamelist = {
    [18955534702] = "transfurholdout",
}

library.Initialize(gamelist[game.PlaceId] or "transfuroutbreak")
local ui = library.UI
ui.GUI.Enabled = false

local main = loadstring(game:HttpGet(library.MAINURL.."main.lua", true))()
main.Initialize(library)

local watermark = nil;
local username = tostring(game.Players.LocalPlayer.DisplayName)
task.spawn(function()
    while task.wait(1) do
        if library.ALIVE == false then
            main.Unload()
            getgenv().MAINURL = nil
            getgenv().Unload = nil
            return
        end
        if watermark == nil then
            watermark = ui:AddWatermark('');
        end
        local fps = tostring(ui.fps);
        local t = '';
        if #fps < 2 then
            t = 'FPS: '..'0'..fps..' | USER: '..username;
        else
            t = 'FPS: '..fps..' | USER: '..username;
        end
        watermark:ChangeText('plague.lua public | '..t);
    end
end)

local settings = ui:AddWindow("Settings")
local main = settings:AddSection("Settings")
local open = true
main:AddKeyBind("Open/Close bind", Enum.KeyCode.Home, function()
    open = not open
    ui.GUI.MAIN.Visible = open
end)
local current_cfg = "Config 1"
main:AddDropdown("Config", {"Slot 1", "Slot 2", "Slot 3", "Slot 4"}, 1, function(cfg)
    current_cfg = cfg
end)
main:AddButton("Save config", function()
    library.JSONUI.SaveConfig(current_cfg)
end)
main:AddButton("Load config", function()
    library.JSONUI.LoadConfig(current_cfg)
end)
main:AddButton("Unload", function()
    getgenv().Unload()
end)

local dbg = settings:AddSection("Debug stuff")
dbg:AddButton("Infinite yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)
dbg:AddButton("Simple spy", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)
dbg:AddButton("Dex", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)
dbg:AddButton("Hydroxide", function()
    local owner = "Upbolt"
    local branch = "revision"

    local function webImport(file)
        return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
    end

    webImport("init")
    webImport("ui/main")
end)

TweenService:Create(TextLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
ui.GUI.Enabled = true
task.wait(3)
Plague:Destroy()
blur:Destroy()
