-- Creates the player's objective HUD, atmosphere, and scare feedback.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("ForestGameEvent")

Lighting.ClockTime = 0.2
Lighting.Brightness = 0.7
Lighting.Ambient = Color3.fromRGB(12, 17, 20)
Lighting.OutdoorAmbient = Color3.fromRGB(8, 12, 14)
Lighting.FogColor = Color3.fromRGB(8, 14, 16)
Lighting.FogStart = 35
Lighting.FogEnd = 265
local atmosphere = Lighting:FindFirstChild("ForestAtmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "ForestAtmosphere"
atmosphere.Density = 0.48
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(70, 86, 86)
atmosphere.Decay = Color3.fromRGB(12, 18, 20)
atmosphere.Parent = Lighting

local gui = Instance.new("ScreenGui")
gui.Name = "ForestHorrorHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "ObjectivePanel"
panel.Position = UDim2.fromOffset(24, 24)
panel.Size = UDim2.fromOffset(310, 82)
panel.BackgroundColor3 = Color3.fromRGB(7, 10, 12)
panel.BackgroundTransparency = 0.18
panel.BorderSizePixel = 0
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(16, 10)
title.Size = UDim2.new(1, -32, 0, 25)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(213, 220, 207)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "THE FOREST IS WATCHING"
title.Parent = panel

local progress = Instance.new("TextLabel")
progress.Name = "Progress"
progress.Position = UDim2.fromOffset(16, 42)
progress.Size = UDim2.new(1, -32, 0, 25)
progress.BackgroundTransparency = 1
progress.Font = Enum.Font.Gotham
progress.TextColor3 = Color3.fromRGB(178, 190, 169)
progress.TextSize = 16
progress.TextXAlignment = Enum.TextXAlignment.Left
progress.Text = "Find the papers hidden on trees."
progress.Parent = panel

local message = Instance.new("TextLabel")
message.Name = "Message"
message.AnchorPoint = Vector2.new(0.5, 1)
message.Position = UDim2.new(0.5, 0, 0.88, 0)
message.Size = UDim2.fromOffset(650, 60)
message.BackgroundTransparency = 1
message.Font = Enum.Font.GothamBold
message.TextColor3 = Color3.fromRGB(235, 228, 204)
message.TextStrokeTransparency = 0.5
message.TextSize = 24
message.TextWrapped = true
message.Visible = false
message.Parent = gui

local redFlash = Instance.new("Frame")
redFlash.Name = "DamageFlash"
redFlash.Size = UDim2.fromScale(1, 1)
redFlash.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
redFlash.BackgroundTransparency = 1
redFlash.BorderSizePixel = 0
redFlash.Parent = gui

local function showMessage(text, color, duration)
    message.Text = text
    message.TextColor3 = color or Color3.fromRGB(235, 228, 204)
    message.Visible = true
    task.delay(duration or 3, function()
        if message.Text == text then message.Visible = false end
    end)
end

event.OnClientEvent:Connect(function(kind, first, second)
    if kind == "Progress" then
        progress.Text = string.format("Papers found: %d / %d", first, second)
    elseif kind == "Objective" then
        showMessage("Find every paper. Then reach the gate at the far end.", nil, 6)
    elseif kind == "AllFound" then
        progress.Text = "All papers found. Reach the gate!"
        showMessage("The gate is open. RUN.", Color3.fromRGB(255, 218, 126), 5)
    elseif kind == "NeedMore" then
        showMessage(string.format("The gate is sealed. Find %d more paper(s).", first), Color3.fromRGB(255, 150, 130), 3)
    elseif kind == "Attacked" then
        redFlash.BackgroundTransparency = 0.72
        TweenService:Create(redFlash, TweenInfo.new(0.45), {BackgroundTransparency = 1}):Play()
        showMessage("IT FOUND YOU", Color3.fromRGB(255, 92, 75), 1.2)
    elseif kind == "Won" then
        showMessage("YOU ESCAPED THE FOREST", Color3.fromRGB(157, 255, 174), 999)
        panel.Visible = false
    end
end)
