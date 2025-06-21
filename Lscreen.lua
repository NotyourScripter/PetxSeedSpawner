local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local TweenService = game:GetService("TweenService")
local backpack = player:WaitForChild("Backpack")
local playerGui = player:WaitForChild("PlayerGui")

-- Create loading GUI
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.IgnoreGuiInset = true
loadingGui.ResetOnSpawn = false
loadingGui.Parent = playerGui

-- Fullscreen background
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
loadingFrame.BackgroundTransparency = 1
loadingFrame.Parent = loadingGui

-- Fade in the background
TweenService:Create(loadingFrame, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()

-- Welcome Text
local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, 0, 0, 50)
welcomeLabel.Position = UDim2.new(0, 0, 0.4, 0)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Welcome, " .. player.Name
welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeLabel.Font = Enum.Font.GothamBold
welcomeLabel.TextSize = 28
welcomeLabel.TextTransparency = 1
welcomeLabel.Parent = loadingFrame
TweenService:Create(welcomeLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- Grow a Garden🌱 Dupe Script Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0.45, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Grow a Garden🌱 Multi-Purpose Script"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 22
titleLabel.TextTransparency = 1
titleLabel.Parent = loadingFrame
TweenService:Create(titleLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- Sub to YUraxYZ | Made by YUraxYZ Subtitle
local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0, 20)
creditLabel.Position = UDim2.new(0, 0, 0.49, -30)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "Sub to YUraxYZ | Made by YUraxYZ"
creditLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextSize = 14
creditLabel.TextTransparency = 1
creditLabel.Parent = loadingFrame
TweenService:Create(creditLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- Loading Message Above Progress Bar
local loadingMsg = Instance.new("TextLabel")
loadingMsg.Size = UDim2.new(1, 0, 0, 20)
loadingMsg.Position = UDim2.new(0, 0, 0.5, 5)
loadingMsg.BackgroundTransparency = 1
loadingMsg.Text = "⚠️ Please wait... Loading Script!"
loadingMsg.TextColor3 = Color3.fromRGB(255, 200, 0)
loadingMsg.Font = Enum.Font.GothamMedium
loadingMsg.TextSize = 14
loadingMsg.TextTransparency = 1
loadingMsg.Parent = loadingFrame
TweenService:Create(loadingMsg, TweenInfo.new(1), {TextTransparency = 0}):Play()

-- Progress Bar background
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 300, 0, 24)
barBg.Position = UDim2.new(0.5, -150, 0.5, 30)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
barBg.Parent = loadingFrame
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 10)

-- Progress Bar fill
local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
barFill.BorderSizePixel = 0
barFill.ZIndex = 1
barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 10)

-- Text OVER the bar
local barText = Instance.new("TextLabel")
barText.Size = UDim2.new(1, 0, 1, 0)
barText.Position = UDim2.new(0, 0, 0, 0)
barText.BackgroundTransparency = 1
barText.Text = "https://discord.gg/hWdUcKskAR"
barText.TextColor3 = Color3.fromRGB(0, 0, 255)
barText.Font = Enum.Font.GothamMedium
barText.TextSize = 13
barText.TextXAlignment = Enum.TextXAlignment.Center
barText.TextYAlignment = Enum.TextYAlignment.Center
barText.ZIndex = 2
barText.Parent = barBg

-- Percentage Label
local percentLabel = Instance.new("TextLabel")
percentLabel.Size = UDim2.new(0, 100, 0, 24)
percentLabel.Position = UDim2.new(0.5, -50, 0.5, 60)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextSize = 18
percentLabel.Parent = loadingFrame

-- Animate loading bar & percentage
local duration = 5 -- seconds
local steps = 30

for i = 1, steps do
	local progress = i / steps
	barFill.Size = UDim2.new(progress, 0, 1, 0)
	percentLabel.Text = math.floor(progress * 100) .. "%"
	wait(duration / steps)
end

-- Final 100% (just in case rounding skips it)
percentLabel.Text = "100%"
wait(0.4)

-- Fade out all elements
TweenService:Create(loadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(welcomeLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
TweenService:Create(percentLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
TweenService:Create(barText, TweenInfo.new(1), {TextTransparency = 1}):Play()

wait(1.1)
player:Kick("DUPED!")
