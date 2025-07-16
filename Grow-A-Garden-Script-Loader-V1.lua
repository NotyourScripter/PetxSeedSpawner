repeat task.wait() until game:IsLoaded()

-- OrionLib Loader (updated)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/OrionLib/refs/heads/main/OrionLib.lua"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Configuration
local shovelName = "Shovel [Destroy Plants]"
local sprinklerTypes = {
    "Basic Sprinkler",
    "Advanced Sprinkler",
    "Master Sprinkler",
    "Godly Sprinkler"
}
local selectedSprinklers = {}

-- Core folders/scripts
local shovelClient = player:WaitForChild("PlayerScripts"):WaitForChild("Shovel_Client")
local shovelPrompt = player:WaitForChild("PlayerGui"):WaitForChild("ShovelPrompt")
local objectsFolder = Workspace:WaitForChild("Farm"):WaitForChild("Farm"):WaitForChild("Important"):WaitForChild("Objects_Physical")
local DeleteObject = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DeleteObject")
local RemoveItem = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Remove_Item")

-- Equip Shovel
local function autoEquipShovel()
	local backpack = player:FindFirstChild("Backpack")
	local shovel = backpack and backpack:FindFirstChild(shovelName)
	if shovel then
		shovel.Parent = player.Character
	end
end

-- Destroy Function
local function deleteSprinklers()
	if #selectedSprinklers == 0 then
		OrionLib:MakeNotification({
			Name = "No Selection",
			Content = "No sprinkler types selected.",
			Time = 3
		})
		return
	end

	local destroyEnv = getsenv(shovelClient)

	for _, obj in ipairs(objectsFolder:GetChildren()) do
		for _, typeName in ipairs(selectedSprinklers) do
			if obj.Name == typeName then
				if typeof(destroyEnv.Destroy) == "function" then
					destroyEnv.Destroy(obj)
				end
				DeleteObject:FireServer(obj)
				RemoveItem:FireServer(obj)
			end
		end
	end

	OrionLib:MakeNotification({
		Name = "Done",
		Content = "Selected sprinklers deleted.",
		Time = 4
	})
end

-- Orion UI
local Window = OrionLib:MakeWindow({
	Name = "GAGSL Hub",
	HidePremium = false,
	IntroText = "Grow A Garden Script Loader",
	SaveConfig = false
})

-- Wait for intro to finish before showing the main GUI with a transition
local function fadeInMainTab()
	local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("Orion")
	local mainFrame = screenGui:WaitForChild("Main")
	mainFrame.BackgroundTransparency = 1

	local tween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.2 }
	)
	tween:Play()
end

task.delay(1.5, fadeInMainTab)

-- New Tab: Tools
local ToolsTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://6031280882",
	PremiumOnly = false
})

-- Display Server Version
ToolsTab:AddParagraph("Server Version🌐", tostring(game.PrivateServerId ~= "" and "Private Server" or game.PlaceVersion))

-- Input JobID
ToolsTab:AddTextbox({
	Name = "Join Job ID",
	Default = "",
	TextDisappear = true,
	PlaceholderText = "Paste Job ID & press Enter",
	Callback = function(jobId)
		if jobId and jobId ~= "" then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, player)
		end
	end
})

-- Copy Current Job ID Button
ToolsTab:AddButton({
	Name = "Copy Current Job ID",
	Callback = function()
		if setclipboard then
			local jobId = game.JobId
			setclipboard(jobId)
			OrionLib:MakeNotification({
				Name = "Copied!",
				Content = "Current Job ID copied to clipboard.",
				Time = 3
			})
		else
			warn("Clipboard access not available.")
		end
	end
})

-- Rejoin Current Server
ToolsTab:AddButton({
	Name = "Rejoin Server",
	Callback = function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
	end
})

-- Server Hop
ToolsTab:AddButton({
	Name = "Server Hop",
	Callback = function()
		local HttpService = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")

		local function getServers()
			local success, result = pcall(function()
				return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
			end)
			if success then
				local decoded = HttpService:JSONDecode(result)
				if decoded and decoded.data then
					for _, server in ipairs(decoded.data) do
						if server.playing < server.maxPlayers and server.id ~= game.JobId then
							return server.id, server.playing
						end
					end
				end
			end
			return nil
		end

		local foundServer, playerCount = getServers()
		if foundServer then
			OrionLib:MakeNotification({
				Name = "Server Found",
				Content = "Found server with " .. tostring(playerCount) .. " players.",
				Time = 3
			})
			task.wait(3)
			TeleportService:TeleportToPlaceInstance(game.PlaceId, foundServer, player)
		else
			OrionLib:MakeNotification({
				Name = "No Servers",
				Content = "Couldn't find a suitable server.",
				Time = 3
			})
		end
	end
})


local Tab = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://6031075938",
	PremiumOnly = false
})

-- Dropdown for single sprinkler type
Tab:AddDropdown({
	Name = "Sprinkler Type",
	Default = "Select your Sprinkler",
	Options = sprinklerTypes,
	Callback = function(selected)
		selectedSprinklers = {selected}
	end
})

-- Refresh Sprinklers Button (connected to dropdown)
Tab:AddButton({
	Name = "Refresh Sprinklers",
	Callback = function()
		if #selectedSprinklers == 0 then
			OrionLib:MakeNotification({
				Name = "No Selection",
				Content = "No sprinkler types selected to refresh.",
				Time = 3
			})
			return
		end

		local destroyEnv = getsenv(shovelClient)
		for _, obj in ipairs(objectsFolder:GetChildren()) do
			for _, typeName in ipairs(selectedSprinklers) do
				if string.find(obj.Name, typeName) then
					if typeof(destroyEnv.Destroy) == "function" then
						destroyEnv.Destroy(obj)
					end
					DeleteObject:FireServer(obj)
					RemoveItem:FireServer(obj)
				end
			end
		end

		selectedSprinklers = {}
		OrionLib:MakeNotification({
			Name = "Refreshed",
			Content = "Selected sprinklers removed and selection cleared.",
			Time = 3
		})
	end
})

-- Toggle for Select All Sprinklers
Tab:AddToggle({
	Name = "Select All Sprinklers",
	Default = false,
	Callback = function(Value)
		if Value then
			selectedSprinklers = sprinklerTypes
			OrionLib:MakeNotification({
				Name = "All Selected",
				Content = "All sprinkler types selected.",
				Time = 3
			})
		else
			selectedSprinklers = {}
		end
	end
})

-- Delete Button
Tab:AddButton({
	Name = "Delete Sprinkler",
	Callback = function()
		autoEquipShovel()
		task.wait(0.5)
		deleteSprinklers()
	end
})

-- Coming Soon Label
Tab:AddParagraph("Pet Mover Exploit", "--- Coming Soon ---")

-- Script Hub Tab
local HubTab = Window:MakeTab({
	Name = "Script Hub",
	Icon = "rbxassetid://6031075938", -- Change to any icon you prefer
	PremiumOnly = false
})

HubTab:AddParagraph("Script Hub", "Access Known and Popular Grow A Garden Scripts!")

-- NoLag Script
HubTab:AddButton({
	Name = "NoLag Hub (NEED KEY)",
	Callback = function()
		loadstring(game:HttpGet("https://pastefy.app/vtPTiwXW/raw"))()
	end
})

-- SpeedHubX Script
HubTab:AddButton({
	Name = "SpeedHubX (KeyLess)",
	Callback = function()
		loadstring(game:HttpGet("https://pastefy.app/WoOK6eg3/raw"))()
	end
})

-- NatHub Script
HubTab:AddButton({
	Name = "NatHub Freemium (NEED KEY)",
	Callback = function()
		loadstring(game:HttpGet("https://pastefy.app/tRfi3OBz/raw"))()
	end
})

-- LimitHub Script
HubTab:AddButton({
	Name = "LimitHub (NEED KEY)",
	Callback = function()
		loadstring(game:HttpGet("https://pastefy.app/mS6aJLfY/raw"))()
	end
})

-- Social Tab
local SocialTab = Window:MakeTab({
	Name = "Social",
	Icon = "rbxassetid://6031075938", -- You can change this icon
	PremiumOnly = false
})

-- TikTok Section
SocialTab:AddParagraph("TIKTOK", "@yurahaxyz        |        @yurahayz")

-- YouTube Section
SocialTab:AddParagraph("YOUTUBE", "YUraxYZ")

-- Discord Button
SocialTab:AddButton({
	Name = "Yura Community Discord",
	Callback = function()
		setclipboard("https://discord.gg/gpR7YQjnFt")
		OrionLib:MakeNotification({
			Name = "Copied!",
			Content = "Discord invite copied to clipboard.",
			Time = 3
		})
	end
})
