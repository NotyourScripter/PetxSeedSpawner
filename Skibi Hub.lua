local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- UI Window Setup
local Window = Rayfield:CreateWindow({
Name = "ROOTACCESS",
LoadingTitle = "ACCESSING",
LoadingSubtitle = "MADE BY Yura",
ConfigurationSaving = {
Enabled = false
},
Discord = {
Enabled = false
},
KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 0)

-- Dupe Amount Setting
local dupeAmount = 1
MainTab:CreateInput({
Name = "Dupe Amount (1-100)",
PlaceholderText = "Enter a number",
RemoveTextAfterFocusLost = false,
Callback = function(text)
local number = tonumber(text)
if number and number >= 1 and number <= 100 then
dupeAmount = number
else
warn("Enter a number between 1 and 100")
end
end
})

-- Dupe Button
MainTab:CreateButton({
Name = "DUPE",
Callback = function()
local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
if not tool then
warn("No tool to duplicate.")
return
end

for i = 1, dupeAmount do
local clone = tool:Clone()
clone.Parent = player.Backpack
end
end
})

-- Save Duped Pets Button
MainTab:CreateButton({
Name = "SAVE DUPED PETS",
Callback = function()
pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/DUPAHHUB.lua"))()
end)
end
})
