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

repeat task.wait() until game:IsLoaded()

-- OrionLib Loader
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/YuraScripts/GrowAFilipinoy/refs/heads/main/TEST.lua"))()

-- Load all functions from GitHub
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/GG-Functions.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Pet Radius Control Configuration
local RADIUS = 0.5
local LOOP_DELAY = 1
local INITIAL_LOOP_TIME = 5
local ZONE_ABILITY_DELAY = 3
local ZONE_ABILITY_LOOP_TIME = 3

-- Auto buy state
local autoBuyEnabled = false
local buyConnection

-- Pet control variables
local autoMiddleEnabled = false
local autoMiddleConnection = nil
local zoneAbilityConnection = nil
local loopTimer = nil
local delayTimer = nil
local isLooping = false
local petCountLabel = nil
local petDropdown = nil

-- Function to start the heartbeat loop
local function startLoop()
    if autoMiddleConnection then
        autoMiddleConnection:Disconnect()
    end
    
    isLooping = true
    autoMiddleConnection = RunService.Heartbeat:Connect(function()
        if not isLooping then return end
        Functions.runAutoMiddleLoop(RADIUS)
        task.wait(LOOP_DELAY)
    end)
end

-- Function to stop the heartbeat loop
local function stopLoop()
    isLooping = false
    if autoMiddleConnection then
        autoMiddleConnection:Disconnect()
        autoMiddleConnection = nil
    end
end

-- Function to start initial loop
local function startInitialLoop()
    if not autoMiddleEnabled then return end
    
    startLoop()
    
    if loopTimer then
        task.cancel(loopTimer)
    end
    
    loopTimer = task.spawn(function()
        task.wait(INITIAL_LOOP_TIME)
        if autoMiddleEnabled then
            stopLoop()
        end
    end)
end

-- Function to handle PetZoneAbility detection
local function onPetZoneAbility()
    if not autoMiddleEnabled then return end
    
    if delayTimer then
        task.cancel(delayTimer)
    end
    
    delayTimer = task.spawn(function()
        task.wait(ZONE_ABILITY_DELAY)
        if autoMiddleEnabled then
            startLoop()
            task.wait(ZONE_ABILITY_LOOP_TIME)
            if autoMiddleEnabled then
                stopLoop()
            end
        end
    end)
end

-- Function to setup PetZoneAbility listener
local function setupZoneAbilityListener()
    if zoneAbilityConnection then
        zoneAbilityConnection:Disconnect()
    end
    local PetZoneAbility = game:GetService("ReplicatedStorage").GameEvents.PetZoneAbility
    zoneAbilityConnection = PetZoneAbility.OnClientEvent:Connect(onPetZoneAbility)
end

-- Function to cleanup all timers and connections
local function cleanup()
    stopLoop()
    
    if zoneAbilityConnection then
        zoneAbilityConnection:Disconnect()
        zoneAbilityConnection = nil
    end
    
    if loopTimer then
        task.cancel(loopTimer)
        loopTimer = nil
    end
    if delayTimer then
        task.cancel(delayTimer)
        delayTimer = nil
    end
    
    -- Clean up ESP markers
    for petId, esp in pairs(Functions.excludedPetESPs) do
        if esp then
            esp:Destroy()
        end
    end
    Functions.excludedPetESPs = {}
end

-- Function to update pet count
local function updatePetCount()
    local pets = Functions.getAllPets()
    local selectedCount = 0
    local excludedCount = 0
    
    for petId, _ in pairs(Functions.selectedPets) do
        selectedCount = selectedCount + 1
    end
    
    for petId, _ in pairs(Functions.excludedPets) do
        excludedCount = excludedCount + 1
    end
    
    if Functions.allPetsSelected then
        selectedCount = #pets
    end
    
    if petCountLabel then
        petCountLabel:Set("Pets Found: " .. #pets .. " | Selected: " .. selectedCount .. " | Excluded: " .. excludedCount)
    end
end

-- Orion UI
local Window = OrionLib:MakeWindow({
    Name = "GAGSL Hub (v1.2)",
    HidePremium = false,
    IntroText = "Grow A Garden Script Loader",
    SaveConfig = false
})

-- Wait for intro to finish before showing the main GUI with a transition
task.delay(1.5, Functions.fadeInMainTab)

-- Tools Tab
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
        local foundServer, playerCount = Functions.serverHop()
        if foundServer then
            OrionLib:MakeNotification({
                Name = "Server Found",
                Content = "Found server with " .. tostring(playerCount) .. " players.",
                Time = 3
            })
            task.wait(3)
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, foundServer, player)
        else
            OrionLib:MakeNotification({
                Name = "No Servers",
                Content = "Couldn't find a suitable server.",
                Time = 3
            })
        end
    end
})

-- Farm Tab
local Tab = Window:MakeTab({
    Name = "Farm",
    Icon = "rbxassetid://6031280882",
    PremiumOnly = false
})

-- Sprinkler Section
Tab:AddParagraph("Shovel Sprikler", "Inf. Sprinkler Glitch")

local selectedSprinklers = {}

-- Dropdown for single sprinkler type
Tab:AddDropdown({
    Name = "Sprinkler Type",
    Default = "Select your Sprinkler",
    Options = Functions.sprinklerTypes,
    Callback = function(selected)
        selectedSprinklers = {selected}
    end
})

-- Delete Button
Tab:AddButton({
    Name = "Delete Sprinkler",
    Callback = function()
        Functions.autoEquipShovel()
        task.wait(0.5)
        Functions.deleteSprinklers(selectedSprinklers, OrionLib)
    end
})

-- Toggle for Select All Sprinklers
Tab:AddToggle({
    Name = "Select All Sprinklers",
    Default = false,
    Callback = function(Value)
        if Value then
            selectedSprinklers = Functions.sprinklerTypes
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

-- Pet Control Section
Tab:AddParagraph("Pet Exploit", "Auto Middle Pets, Select Pet to Exclude.")

-- Get initial pets
local initialPets = Functions.refreshPets()

petCountLabel = Tab:AddLabel("Pets Found: 0 | Selected: 0 | Excluded: 0")

-- Update pet count initially and periodically
updatePetCount()

task.spawn(function()
    while true do
        updatePetCount()
        task.wait(1)
    end
end)

-- Pet Exclusion Dropdown
petDropdown = Tab:AddDropdown({
    Name = "Select Pets to Exclude",
    Default = {}, 
    Options = {"None"},
    Callback = function(selectedValues)
        -- Clear all previous exclusions
        for petId, _ in pairs(Functions.excludedPets) do
            Functions.removeESPMarker(petId)
        end
        Functions.excludedPets = {}
        
        -- Handle the selected values
        if selectedValues and #selectedValues > 0 then
            local hasNone = false
            for _, value in pairs(selectedValues) do
                if value == "None" then
                    hasNone = true
                    break
                end
            end
            
            if not hasNone then
                for _, petName in pairs(selectedValues) do
                    local selectedPet = Functions.currentPetsList[petName]
                    if selectedPet then
                        Functions.excludedPets[selectedPet.id] = true
                        Functions.createESPMarker(selectedPet)
                    end
                end
            end
        end
        
        updatePetCount()
        
        -- Show notification about exclusions
        local excludedCount = 0
        for _ in pairs(Functions.excludedPets) do
            excludedCount = excludedCount + 1
        end
        
        if excludedCount > 0 then
            OrionLib:MakeNotification({
                Name = "Pets Excluded",
                Content = "Excluded " .. excludedCount .. " pets from auto middle.",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    end
})

-- Combined Refresh and Auto Select All Button
Tab:AddButton({
    Name = "Refresh & Auto Select All Pets",
    Callback = function()
        local newPets = Functions.refreshPets()
        Functions.selectAllPets()
        updatePetCount()
        
        if petDropdown then
            petDropdown:ClearAll()
        end
        
        OrionLib:MakeNotification({
            Name = "Pets Refreshed & Selected",
            Content = "Found " .. #newPets .. " pets and selected all for auto middle.",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Auto Middle Toggle
Tab:AddToggle({
    Name = "Auto Middle Pets",
    Default = false,
    Callback = function(value)
        autoMiddleEnabled = value
        if value then
            setupZoneAbilityListener()
            startInitialLoop()
        else
            cleanup()
        end
    end
})

-- Shop Tab
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
