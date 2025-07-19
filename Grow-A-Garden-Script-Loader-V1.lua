-- Main GAGSL Hub Script
repeat task.wait() until game:IsLoaded()

local CoreFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/GG-Functions.lua))()

local PetFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/PFunctions.lua"))()

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/YuraScripts/GrowAFilipinoy/refs/heads/main/TEST.lua"))()

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Orion UI
local Window = OrionLib:MakeWindow({
	Name = "GAGSL Hub (v1.2)",
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
	Icon = "rbxassetid://6031280882",
	PremiumOnly = false
})

-- Sprinkler Section
Tab:AddParagraph("Shovel Sprikler", "Inf. Sprinkler Glitch")

-- Dropdown for single sprinkler type
Tab:AddDropdown({
	Name = "Sprinkler Type",
	Default = "Select your Sprinkler",
	Options = CoreFunctions.getSprinklerTypes(),
	Callback = function(selected)
		CoreFunctions.setSelectedSprinklers({selected})
	end
})

-- Refresh Sprinklers Button (connected to dropdown)
Tab:AddButton({
	Name = "Refresh Sprinklers",
	Callback = function()
		local selectedSprinklers = CoreFunctions.getSelectedSprinklers()
		if #selectedSprinklers == 0 then
			OrionLib:MakeNotification({
				Name = "No Selection",
				Content = "No sprinkler types selected to refresh.",
				Time = 3
			})
			return
		end

		local shovelClient = player:WaitForChild("PlayerScripts"):WaitForChild("Shovel_Client")
		local objectsFolder = game.Workspace:WaitForChild("Farm"):WaitForChild("Farm"):WaitForChild("Important"):WaitForChild("Objects_Physical")
		local DeleteObject = game.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DeleteObject")
		local RemoveItem = game.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Remove_Item")
		
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

		CoreFunctions.setSelectedSprinklers({})
		OrionLib:MakeNotification({
			Name = "Refreshed",
			Content = "Selected sprinklers removed and selection cleared.",
			Time = 3
		})
	end
})

-- Toggle for Select All Sprinklers
Tab:AddToggle({
	Name =
