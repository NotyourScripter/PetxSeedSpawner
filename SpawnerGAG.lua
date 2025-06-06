-- Create the GUI container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DraggableGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Create a frame to hold the button
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 30) -- Darker than #000435
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Add rounded corners to the frame
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12) -- Adjust the radius as needed
frameCorner.Parent = frame

-- Create the "Open" button
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(1, -20, 0, 40)
openButton.Position = UDim2.new(0, 10, 0.5, -20)
openButton.BackgroundColor3 = Color3.fromRGB(0, 0, 30)
openButton.Text = "Open"
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Font = Enum.Font.SourceSansBold
openButton.TextScaled = true
openButton.Parent = frame

-- Add rounded corners to the button
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = openButton

-- Connect the button to the test command
openButton.MouseButton1Click:Connect(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/DUPAHHUB.lua"))()
end)
