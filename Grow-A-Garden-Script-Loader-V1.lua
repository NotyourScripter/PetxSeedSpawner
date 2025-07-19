repeat task.wait() until game:IsLoaded()

-- OrionLib Loader (updated)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/YuraScripts/GrowAFilipinoy/refs/heads/main/TEST.lua"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local BuyEventShopStock = ReplicatedStorage.GameEvents.BuyEventShopStock

-- Configuration
local shovelName = "Shovel [Destroy Plants]"
local sprinklerTypes = {
    "Basic Sprinkler",
    "Advanced Sprinkler",
    "Master Sprinkler",
    "Godly Sprinkler",
    "Honey Sprinkler",
    "Chocolate Sprinkler"
}
local selectedSprinklers = {}

local zenItems = {
    "Zen Seed Pack",
    "Zen Egg",
    "Hot Spring",
    "Zen Flare",
    "Zen Crate",
    "Soft Sunshine",
    "Koi",
    "Zen Gnome Crate",
    "Spiked Mango",
    "Pet Shard Tranquil",
    "Zen Sand"
}

-- Items to auto-buy
local merchantItems = {
    "Star Caller",
    "Night Staff",
    "Bee Egg",
    "Honey Sprinkler",
    "Flower Seed Pack",
    "Cloudtouched Spray",
    "Mutation Spray Disco",
    "Mutation Spray Verdant",
    "Mutation Spray Windstruck",
    "Mutation Spray Wet"
}

-- Pet Radius Control Configuration
local RADIUS = 0.5
local LOOP_DELAY = 1
local INITIAL_LOOP_TIME = 5
local ZONE_ABILITY_DELAY = 3
local ZONE_ABILITY_LOOP_TIME = 3

-- Core folders/scripts
local shovelClient = player:WaitForChild("PlayerScripts"):WaitForChild("Shovel_Client")
local shovelPrompt = player:WaitForChild("PlayerGui"):WaitForChild("ShovelPrompt")
local objectsFolder = Workspace:WaitForChild("Farm"):WaitForChild("Farm"):WaitForChild("Important"):WaitForChild("Objects_Physical")
local DeleteObject = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DeleteObject")
local RemoveItem = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Remove_Item")

-- Pet Control Services
local ActivePetService = ReplicatedStorage.GameEvents.ActivePetService
local PetZoneAbility = ReplicatedStorage.GameEvents.PetZoneAbility

-- Pet Control Variables
local petsFolder = nil
local selectedPets = {}
local excludedPets = {}
local excludedPetESPs = {}
local allPetsSelected = false
local autoMiddleEnabled = false
local autoMiddleConnection = nil
local zoneAbilityConnection = nil
local loopTimer = nil
local delayTimer = nil
local isLooping = false
local petCountLabel = nil
local petDropdown = nil
local currentPetsList = {}

-- Auto buy state
local autoBuyEnabled = false
local buyConnection

-- Function to buy all zen items
local function buyAllZenItems()
    if not autoBuyEnabled then return end
    
    for _, item in pairs(zenItems) do
        pcall(function()
            BuyEventShopStock:FireServer(item)
        end)
    end
end

local function buyAllMerchantItems()
    if not autoBuyEnabled then return end
    
    for _, item in pairs(merchantItems) do
        pcall(function()
            BuyTravelingMerchantShopStock:FireServer(item)
        end)
    end
end

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

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Remove Farms Function
local function removeFarms()
	local farmFolder = Workspace:FindFirstChild("Farm")
	if not farmFolder then
		OrionLib:MakeNotification({
			Name = "No Farms Found",
			Content = "Farm folder not found in Workspace.",
			Time = 3
		})
		return
	end

	local playerCharacter = player.Character
	local rootPart = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		OrionLib:MakeNotification({
			Name = "Player Not Found",
			Content = "Player character or position not found.",
			Time = 3
		})
		return
	end

	local currentFarm = nil
	local closestDistance = math.huge

	for _, farm in ipairs(farmFolder:GetChildren()) do
		if farm:IsA("Model") or farm:IsA("Folder") then
			local farmRoot = farm:FindFirstChild("HumanoidRootPart") or farm:FindFirstChildWhichIsA("BasePart")
			if farmRoot then
				local distance = (farmRoot.Position - rootPart.Position).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					currentFarm = farm
				end
			end
		end
	end

	for _, farm in ipairs(farmFolder:GetChildren()) do
		if farm ~= currentFarm then
			farm:Destroy()
		end
	end

	OrionLib:MakeNotification({
		Name = "Farms Removed",
		Content = "All other farms have been deleted.",
		Time = 3
	})
end


-- Pet Control Functions
-- Function to check if string is UUID format
local function isValidUUID(str)
    if not str or type(str) ~= "string" then return false end
    str = string.gsub(str, "[{}]", "")
    return string.match(str, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

-- Function to find pets folder
local function findPetsFolder()
    local possiblePaths = {"PetsPhysical", "Active Pets", "Pets", "ActivePets", "PetModels"}
    
    for _, path in pairs(possiblePaths) do
        local folder = Workspace:FindFirstChild(path)
        if folder then return folder end
    end
    
    local player = Players.LocalPlayer
    if player and player.Character then
        for _, path in pairs(possiblePaths) do
            local folder = player.Character:FindFirstChild(path)
            if folder then return folder end
        end
    end
    
    return nil
end

-- Function to get pet ID from PetMover
local function getPetIdFromPetMover(petMover)
    if not petMover then return nil end
    
    local petId = petMover:GetAttribute("PetId") or 
                 petMover:GetAttribute("Id") or 
                 petMover:GetAttribute("UUID") or
                 petMover:GetAttribute("petId")
    
    if petId then return petId end
    
    if petMover.Parent and isValidUUID(petMover.Parent.Name) then
        return petMover.Parent.Name
    end
    
    if isValidUUID(petMover.Name) then
        return petMover.Name
    end
    
    return petMover:GetFullName()
end

-- Function to create ESP "X" marker
local function createESPMarker(pet)
    if excludedPetESPs[pet.id] then
        return -- ESP already exists
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ExcludedPetESP"
    billboard.Adornee = pet.mover
    billboard.Size = UDim2.new(0, 50, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.LightInfluence = 0
    billboard.AlwaysOnTop = true
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "X"
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = frame
    
    billboard.Parent = pet.mover
    excludedPetESPs[pet.id] = billboard
end

-- Function to remove ESP marker
local function removeESPMarker(petId)
    if excludedPetESPs[petId] then
        excludedPetESPs[petId]:Destroy()
        excludedPetESPs[petId] = nil
    end
end

-- Function to get all pets
local function getAllPets()
    local pets = {}
    
    local function processPetContainer(container)
        local petMover = container:FindFirstChild("PetMover")
        if petMover and petMover:IsA("BasePart") then
            local petId = getPetIdFromPetMover(petMover)
            if petId then
                table.insert(pets, {
                    id = petId,
                    name = "Pet",
                    model = container,
                    mover = petMover,
                    position = petMover.Position
                })
            end
        end
    end
    
    local function findStandalonePetMovers(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Part") and child.Name == "PetMover" then
                local petId = getPetIdFromPetMover(child)
                if petId then
                    table.insert(pets, {
                        id = petId,
                        name = "Pet",
                        model = child.Parent,
                        mover = child,
                        position = child.Position
                    })
                end
            elseif child:IsA("Model") or child:IsA("Folder") then
                findStandalonePetMovers(child)
            end
        end
    end
    
    if not petsFolder then
        petsFolder = findPetsFolder()
    end
    
    if petsFolder then
        if petsFolder.Name == "PetsPhysical" then
            local petMoverFolder = petsFolder:FindFirstChild("PetMover")
            if petMoverFolder then
                for _, petContainer in pairs(petMoverFolder:GetChildren()) do
                    if petContainer:IsA("Model") and isValidUUID(petContainer.Name) then
                        processPetContainer(petContainer)
                    end
                end
            end
        else
            for _, child in pairs(petsFolder:GetChildren()) do
                if child:IsA("Model") then
                    processPetContainer(child)
                end
            end
        end
    end
    
    findStandalonePetMovers(Workspace)
    
    return pets
end

-- Function to get farm center point
local function getFarmCenterPoint()
    local player = Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerPosition = player.Character.HumanoidRootPart.Position
    local farmFolder = Workspace:FindFirstChild("Farm")
    
    if farmFolder then
        local closestFarm = nil
        local closestDistance = math.huge
        
        for _, farm in pairs(farmFolder:GetChildren()) do
            local centerPoint = farm:FindFirstChild("Center_Point")
            if centerPoint then
                local distance = (playerPosition - centerPoint.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestFarm = centerPoint.Position
                end
            end
        end
        
        return closestFarm
    end
    
    return playerPosition
end

-- Function to format pet ID to UUID format
local function formatPetIdToUUID(petId)
    if string.match(petId, "^{%x+%-%x+%-%x+%-%x+%-%x+}$") then
        return petId
    end
    
    petId = string.gsub(petId, "[{}]", "")
    return "{" .. petId .. "}"
end

-- Function to set pet state
local function setPetState(petId, state)
    local formattedPetId = formatPetIdToUUID(petId)
    pcall(function()
        ActivePetService:FireServer("SetPetState", formattedPetId, state)
    end)
end

-- Function to run the auto middle loop
local function runAutoMiddleLoop()
    if not autoMiddleEnabled then return end
    
    local pets = getAllPets()
    local farmCenterPoint = getFarmCenterPoint()
    
    if not farmCenterPoint then return end
    
    for _, pet in pairs(pets) do
        -- Skip excluded pets
        if not excludedPets[pet.id] then
            if allPetsSelected or selectedPets[pet.id] then
                local distance = (pet.mover.Position - farmCenterPoint).Magnitude
                if distance > RADIUS then
                    setPetState(pet.id, "Idle")
                end
            end
        end
    end
end

-- Function to start the heartbeat loop
local function startLoop()
    if autoMiddleConnection then
        autoMiddleConnection:Disconnect()
    end
    
    isLooping = true
    autoMiddleConnection = RunService.Heartbeat:Connect(function()
        if not isLooping then return end
        runAutoMiddleLoop()
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
    for petId, esp in pairs(excludedPetESPs) do
        if esp then
            esp:Destroy()
        end
    end
    excludedPetESPs = {}
end

-- Function to select all pets
local function selectAllPets()
    selectedPets = {}
    allPetsSelected = true
    local pets = getAllPets()
    for _, pet in pairs(pets) do
        selectedPets[pet.id] = true
    end
end

-- Function to get all pets (unchanged from original)
local function getAllPets()
    local pets = {}
    
    local function processPetContainer(container)
        local petMover = container:FindFirstChild("PetMover")
        if petMover and petMover:IsA("BasePart") then
            local petId = getPetIdFromPetMover(petMover)
            if petId then
                table.insert(pets, {
                    id = petId,
                    name = "Pet",
                    model = container,
                    mover = petMover,
                    position = petMover.Position
                })
            end
        end
    end
    
    local function findStandalonePetMovers(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Part") and child.Name == "PetMover" then
                local petId = getPetIdFromPetMover(child)
                if petId then
                    table.insert(pets, {
                        id = petId,
                        name = "Pet",
                        model = child.Parent,
                        mover = child,
                        position = child.Position
                    })
                end
            elseif child:IsA("Model") or child:IsA("Folder") then
                findStandalonePetMovers(child)
            end
        end
    end
    
    if not petsFolder then
        petsFolder = findPetsFolder()
    end
    
    if petsFolder then
        if petsFolder.Name == "PetsPhysical" then
            local petMoverFolder = petsFolder:FindFirstChild("PetMover")
            if petMoverFolder then
                for _, petContainer in pairs(petMoverFolder:GetChildren()) do
                    if petContainer:IsA("Model") and isValidUUID(petContainer.Name) then
                        processPetContainer(petContainer)
                    end
                end
            end
        else
            for _, child in pairs(petsFolder:GetChildren()) do
                if child:IsA("Model") then
                    processPetContainer(child)
                end
            end
        end
    end
    
    findStandalonePetMovers(Workspace)
    
    return pets
end

-- Function to update dropdown options (modified from your original)
local function updateDropdownOptions()
    local pets = getAllPets()
    currentPetsList = {}
    local dropdownOptions = {"None", "Clear All Exclusions", "Exclude All Pets"}
    
    for i, pet in pairs(pets) do
        local shortId = string.sub(tostring(pet.id), 1, 8)
        local displayName = "Pet (" .. shortId .. "...)"
        table.insert(dropdownOptions, displayName)
        currentPetsList[displayName] = pet
    end
    
    -- Update the dropdown options
    if petDropdown and petDropdown.Refresh then
        petDropdown:Refresh(dropdownOptions, true)
    end
end

-- Function to refresh pets (modified from your original)
local function refreshPets()
    selectedPets = {}
    allPetsSelected = false
    petsFolder = findPetsFolder and findPetsFolder()
    local pets = getAllPets()
    updateDropdownOptions()
    return pets
end

-- Helper functions for external use
local function isPetExcluded(petId)
    return excludedPets[petId] == true
end

local function getExcludedPetCount()
    local count = 0
    for _ in pairs(excludedPets) do
        count = count + 1
    end
    return count
end

local function getExcludedPetIds()
    local ids = {}
    for petId, _ in pairs(excludedPets) do
        table.insert(ids, petId)
    end
    return ids
end

-- Initialize the system
if getAllPets then
    updateDropdownOptions()
end

-- Make functions available globally if needed
_G.updateDropdownOptions = updateDropdownOptions
_G.refreshPets = refreshPets
_G.isPetExcluded = isPetExcluded
_G.getExcludedPetCount = getExcludedPetCount
_G.getExcludedPetIds = getExcludedPetIds


-- Function to update pet count
local function updatePetCount()
    local pets = getAllPets()
    local selectedCount = 0
    local excludedCount = 0
    
    for petId, _ in pairs(selectedPets) do
        selectedCount = selectedCount + 1
    end
    
    for petId, _ in pairs(excludedPets) do
        excludedCount = excludedCount + 1
    end
    
    if allPetsSelected then
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

-- Pet Control Section
Tab:AddParagraph("Pet Exploit", "Auto Middle Pets, Select Pet to Exclude.")

-- Get initial pets
local initialPets = refreshPets()

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
    Default = {}, -- Start with no exclusions
    Options = {"None"},
    Callback = function(selectedValues)
        -- Clear all previous exclusions
        for petId, _ in pairs(excludedPets) do
            removeESPMarker(petId)
        end
        excludedPets = {}
        
        -- Handle the selected values (array of pet names)
        if selectedValues and #selectedValues > 0 then
            -- Check if "None" is selected or if array is empty
            local hasNone = false
            for _, value in pairs(selectedValues) do
                if value == "None" then
                    hasNone = true
                    break
                end
            end
            
            if not hasNone then
                -- Add all selected pets to exclusions
                for _, petName in pairs(selectedValues) do
                    local selectedPet = currentPetsList[petName]
                    if selectedPet then
                        excludedPets[selectedPet.id] = true
                        createESPMarker(selectedPet)
                    end
                end
            end
        end
        
        updatePetCount()
        
        -- Show notification about exclusions
        local excludedCount = 0
        for _ in pairs(excludedPets) do
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
        -- Refresh pets
        local newPets = refreshPets()
        
        -- Auto select all pets (this will also clear exclusions via the dropdown callback)
        selectAllPets()
        updatePetCount()
        
        -- Clear the exclusion dropdown when selecting all pets
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

local ShopTab = Window:MakeTab({
    Name = "Shop",
    Icon = "rbxassetid://4835310745",
    PremiumOnly = false
})

-- Add Toggle
ShopTab:AddToggle({
    Name = "Auto Buy Zen",
    Default = false,
    Callback = function(Value)
        autoBuyEnabled = Value
        
        if autoBuyEnabled then
            -- Start auto buying
            buyConnection = RunService.Heartbeat:Connect(function()
                buyAllZenItems()
                wait(0.1) -- Small delay to prevent spam
            end)
            
            OrionLib:MakeNotification({
                Name = "Auto Buy Zen",
                Content = "Auto Buy Zen enabled!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        else
            -- Stop auto buying
            if buyConnection then
                buyConnection:Disconnect()
                buyConnection = nil
            end
        end
    end    
})

ShopTab:AddToggle({
    Name = "Auto Buy Traveling Merchants",
    Default = false,
    Callback = function(Value)
        autoBuyEnabled = Value
        
        if autoBuyEnabled then
            -- Start auto buying
            buyConnection = RunService.Heartbeat:Connect(function()
                buyAllMerchantItems()
                wait(0.1) -- Small delay to prevent spam
            end)

            OrionLib:MakeNotification({
                Name = "Auto Buy Zen",
                Content = "Auto Buy Traveling Merchant enabled!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })

        else
            -- Stop auto buying
            if buyConnection then
                buyConnection:Disconnect()
                buyConnection = nil
            end
        end
    end    
})

ShopTab:AddParagraph("AUTO BUY GEARS", "COMING SOON...")
ShopTab:AddParagraph("AUTO BUY SEEDS", "COMING SOON...")

-- Misc Tab
local MiscTab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://6031280882",
	PremiumOnly = false
})

-- Lag Reduction Section
MiscTab:AddParagraph("Performance", "Reduce game lag by removing lag-causing objects.")

-- New Reduce Lag Button
MiscTab:AddButton({
	Name = "Reduce Lag",
	Callback = function()
		repeat
			local lag = game.Workspace:findFirstChild("Lag", true)
			if (lag ~= nil) then
				lag:remove()
			end
			wait()
		until (game.Workspace:findFirstChild("Lag", true) == nil)
		
		OrionLib:MakeNotification({
			Name = "Lag Reduced",
			Content = "All lag objects have been removed.",
			Time = 3
		})
	end
})

-- NEW: Remove Farms Button
MiscTab:AddButton({
	Name = "Remove Farms (Stay close to your farm)",
	Callback = function()
		removeFarms()
	end
})

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

-- Cleanup on script end
Players.PlayerRemoving:Connect(function(player)
    if player == Players.LocalPlayer then
        cleanup()
    end
end)

-- Final notification
OrionLib:MakeNotification({
    Name = "GAGSL Hub Loaded",
    Content = "GAGSL Hub loaded with +999 Pogi Points!",
})
