repeat task.wait() until game:IsLoaded()

-- GAGSL Hub Main Loader (Clean Version)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/YuraScripts/GrowAFilipinoy/refs/heads/main/TEST.lua"))()

-- Load all functions from GitHub
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/GG-Functions.lua"))()

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Create Window
local Window = OrionLib:MakeWindow({
	Name = "GAGSL Hub (v1.2)",
	HidePremium = false,
	IntroText = "Grow A Garden Script Loader",
	SaveConfig = false
})

-- Fade in animation
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

-- ========== MAIN TAB ==========
local ToolsTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://6031280882",
	PremiumOnly = false
})

ToolsTab:AddParagraph("Server Version🌐", tostring(game.PrivateServerId ~= "" and "Private Server" or game.PlaceVersion))

ToolsTab:AddTextbox({
	Name = "Join Job ID",
	Default = "",
	TextDisappear = true,
	PlaceholderText = "Paste Job ID & press Enter",
	Callback = Functions.joinJobId
})

ToolsTab:AddButton({
	Name = "Copy Current Job ID",
	Callback = Functions.copyJobId
})

ToolsTab:AddButton({
	Name = "Rejoin Server",
	Callback = Functions.rejoinServer
})

ToolsTab:AddButton({
	Name = "Server Hop",
	Callback = Functions.serverHop
})

-- ========== FARM TAB ==========
local FarmTab = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://6031280882",
	PremiumOnly = false
})

FarmTab:AddParagraph("Shovel Sprikler", "Inf. Sprinkler Glitch")

FarmTab:AddDropdown({
	Name = "Sprinkler Type",
	Default = "Select your Sprinkler",
	Options = Functions.getSprinklerTypes(),
	Callback = Functions.selectSprinklerType
})

FarmTab:AddButton({
	Name = "Refresh Sprinklers",
	Callback = Functions.refreshSprinklers
})

FarmTab:AddToggle({
	Name = "Select All Sprinklers",
	Default = false,
	Callback = Functions.toggleAllSprinklers
})

FarmTab:AddButton({
	Name = "Delete Sprinkler",
	Callback = Functions.deleteSprinklers
})

-- Pet Control Section
FarmTab:AddParagraph("Pet Exploit", "Auto Middle Pets, Select Pet to Exclude.")

-- Initialize pet system
Functions.initializePetSystem()

local petCountLabel = FarmTab:AddLabel("Pets Found: 0 | Selected: 0 | Excluded: 0")
Functions.setPetCountLabel(petCountLabel)

local petDropdown = FarmTab:AddDropdown({
	Name = "Select Pets to Exclude",
	Default = {},
	Options = {"None"},
	Callback = Functions.handlePetExclusion
})

Functions.setPetDropdown(petDropdown)

FarmTab:AddButton({
	Name = "Refresh & Auto Select All Pets",
	Callback = Functions.refreshAndSelectAllPets
})

FarmTab:AddToggle({
	Name = "Auto Middle Pets",
	Default = false,
	Callback = Functions.toggleAutoMiddle
})

-- ========== SHOP TAB ==========
local ShopTab = Window:MakeTab({
	Name = "Shop",
	Icon = "rbxassetid://4835310745",
	PremiumOnly = false
})

ShopTab:AddToggle({
	Name = "Auto Buy Zen",
	Default = false,
	Callback = Functions.toggleAutoBuyZen
})

ShopTab:AddToggle({
	Name = "Auto Buy Traveling Merchants",
	Default = false,
	Callback = Functions.toggleAutoBuyMerchant
})

ShopTab:AddParagraph("AUTO BUY GEARS", "COMING SOON...")
ShopTab:AddParagraph("AUTO BUY SEEDS", "COMING SOON...")

-- ========== MISC TAB ==========
local MiscTab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://6031280882",
	PremiumOnly = false
})

MiscTab:AddParagraph("Performance", "Reduce game lag by removing lag-causing objects.")

MiscTab:AddButton({
	Name = "Reduce Lag",
	Callback = Functions.reduceLag
})

MiscTab:AddButton({
	Name = "Remove Farms (Stay close to your farm)",
	Callback = Functions.removeFarms
})

-- ========== SOCIAL TAB ==========
local SocialTab = Window:MakeTab({
	Name = "Social",
	Icon = "rbxassetid://6031075938",
	PremiumOnly = false
})

SocialTab:AddParagraph("TIKTOK", "@yurahaxyz        |        @yurahayz")
SocialTab:AddParagraph("YOUTUBE", "YUraxYZ")

SocialTab:AddButton({
	Name = "Yura Community Discord",
	Callback = Functions.copyDiscordLink
})

-- Cleanup on exit
Players.PlayerRemoving:Connect(function(player)
	if player == Players.LocalPlayer then
		Functions.cleanup()
	end
end)

-- Final notification
OrionLib:MakeNotification({
	Name = "GAGSL Hub Loaded",
	Content = "GAGSL Hub loaded with +999 Pogi Points!",
})
