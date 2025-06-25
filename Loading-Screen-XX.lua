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

local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(0, 500, 0, 150)
bgImage.Position = UDim2.new(0.5, -250, 0.1, 0)
bgImage.AnchorPoint = Vector2.new(0, 0)
bgImage.Image = "rbxassetid://90556697972283"
bgImage.BackgroundTransparency = 0.15
bgImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgImage.ScaleType = Enum.ScaleType.Fit
bgImage.ZIndex = 2
bgImage.BorderSizePixel = 0 -- 🔍 Removes the border
bgImage.Parent = loadingGui

-- 📜 Supported Pets Info (closer to Title)
local info = Instance.new("TextLabel")
info.AnchorPoint = Vector2.new(0.5, 0)
info.Position = UDim2.new(0.5, 0, 0.4, 0)
info.Size = UDim2.new(0.9, 0, 0, 22)
info.BackgroundTransparency = 1
info.Text = "⚠️Please Wait While Unloading the Script..."
info.TextColor3 = Color3.fromRGB(255, 220, 180)
info.Font = Enum.Font.Cartoon
info.TextSize = 14
info.TextWrapped = true
info.ZIndex = 2
info.Parent = loadingGui
TweenService:Create(info, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- ✨ Glowing "Duping..." Status Bar
local dupingLabelFrame = Instance.new("Frame")
dupingLabelFrame.AnchorPoint = Vector2.new(0.5, 0)
dupingLabelFrame.Position = UDim2.new(0.5, 0, 0.485, 0)
dupingLabelFrame.Size = UDim2.new(0, 180, 0, 26)
dupingLabelFrame.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
dupingLabelFrame.BackgroundTransparency = 0.1
dupingLabelFrame.BorderSizePixel = 0
dupingLabelFrame.ZIndex = 2
dupingLabelFrame.Parent = loadingGui

local glowCorner = Instance.new("UICorner", dupingLabelFrame)
glowCorner.CornerRadius = UDim.new(0, 12)

local glowStroke = Instance.new("UIStroke", dupingLabelFrame)
glowStroke.Color = Color3.fromRGB(100, 255, 100)
glowStroke.Thickness = 1.8
glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
glowStroke.Transparency = 0.25

local dupingLabel = Instance.new("TextLabel")
dupingLabel.Size = UDim2.new(1, 0, 1, 0)
dupingLabel.BackgroundTransparency = 1
dupingLabel.Text = "Enum.Font.Cartoon"
dupingLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
dupingLabel.Font = Enum.Font.GothamMedium
dupingLabel.TextSize = 14
dupingLabel.TextTransparency = 1
dupingLabel.ZIndex = 3
dupingLabel.Parent = dupingLabelFrame
TweenService:Create(dupingLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- 🔁 Animated Dots
task.spawn(function()
	local states = { "Loading Script.", "Loading Script..", "Loading Script..." }
	local index = 1
	while true do
		dupingLabel.Text = states[index]
		index = index % #states + 1
		wait(0.5)
	end
end)

-- 💡 Optional pulsing glow animation
TweenService:Create(glowStroke, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {
	Transparency = 0.5
}):Play()


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

-- 🔁 Animate Loading (10 minutes)
local duration = 10 -- 10 minutes
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
player:Kick("YOUR EXECUTOR IS OUTDATED PLEASE UPDATE!")
