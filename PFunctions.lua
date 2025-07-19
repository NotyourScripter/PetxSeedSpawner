-- Enhanced Pet Functions Module with Fast Unequip/Re-equip
-- This module contains all pet-related functionality with improved name detection and fast refresh

local PetFunctions = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Pet Radius Control Configuration
local RADIUS = 0.5
local LOOP_DELAY = 1
local INITIAL_LOOP_TIME = 5
local ZONE_ABILITY_DELAY = 3
local ZONE_ABILITY_LOOP_TIME = 3
local AUTO_LOOP_INTERVAL = 240 -- 4 minutes in seconds

-- Fast refresh configuration
local FAST_UNEQUIP_DELAY = 0.01 -- Minimal delay between unequips
local FAST_EQUIP_DELAY = 0.01   -- Minimal delay between equips
local BATCH_SIZE = 10           -- Process pets in batches for better performance

-- Pet Control Services
local ActivePetService = ReplicatedStorage.GameEvents.ActivePetService
local PetsService = ReplicatedStorage.GameEvents.PetsService -- Service for equip/unequip
local PetZoneAbility = ReplicatedStorage.GameEvents.PetZoneAbility
local Notification = ReplicatedStorage.GameEvents.Notification

-- Pet Control Variables
local petsFolder = nil
local selectedPets = {}
local excludedPets = {}
local excludedPetESPs = {}
local allPetsSelected = false
local autoMiddleEnabled = false
local autoMiddleConnection = nil
local zoneAbilityConnection = nil
local notificationConnection = nil
local loopTimer = nil
local delayTimer = nil
local isLooping = false
local petCountLabel = nil
local petDropdown = nil
local currentPetsList = {}
local lastZoneAbilityTime = 0 -- Track last zone ability time
local isRefreshing = false -- Prevent multiple simultaneous refreshes

-- Cache for pet names to avoid repeated lookups
local petNameCache = {}
local isRefreshingNames = false

-- Function to check if string is UUID format
function PetFunctions.isValidUUID(str)
    if not str or type(str) ~= "string" then return false end
    str = string.gsub(str, "[{}]", "")
    return string.match(str, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

-- Function to find pets folder
function PetFunctions.findPetsFolder()
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

-- Function to get all pet tools from backpack
function PetFunctions.getAllPetToolsFromBackpack()
    local player = Players.LocalPlayer
    if not player or not player.Backpack then return {} end
    
    local petTools = {}
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
            table.insert(petTools, tool)
        end
    end
    
    return petTools
end

-- Function to get all pet names from backpack tools
function PetFunctions.getAllPetNamesFromBackpack()
    local player = Players.LocalPlayer
    if not player or not player.Backpack then return {} end
    
    local petNames = {}
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
            local petName = tool.Name
            if petName and petName ~= "" then
                -- Extract just the pet type (remove weight and age)
                -- Example: "Raccoon [1.49 KG] [Age 1]" -> "Raccoon"
                local cleanName = string.match(petName, "^([^%[]+)")
                if cleanName then
                    cleanName = string.gsub(cleanName, "%s+$", "") -- Remove trailing spaces
                    table.insert(petNames, cleanName)
                end
            end
        end
    end
    
    return petNames
end

-- Function to update pet name cache from backpack
function PetFunctions.updatePetNameCache()
    local player = Players.LocalPlayer
    if not player or not player.Backpack then return end
    
    -- Clear old cache
    petNameCache = {}
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
            local petName = tool.Name
            if petName and petName ~= "" then
                -- Extract just the pet type (remove weight and age)
                -- Example: "Raccoon [1.49 KG] [Age 1]" -> "Raccoon"
                local cleanName = string.match(petName, "^([^%[]+)")
                if cleanName then
                    cleanName = string.gsub(cleanName, "%s+$", "") -- Remove trailing spaces
                    
                    -- Try to find the pet ID associated with this tool
                    local petTool = tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")
                    if petTool then
                        -- Look for pet ID in various possible locations
                        local petId = tool:GetAttribute("PetId") or 
                                     tool:GetAttribute("Id") or 
                                     tool:GetAttribute("UUID") or
                                     petTool:GetAttribute("PetId") or
                                     petTool:GetAttribute("Id") or
                                     petTool:GetAttribute("UUID")
                        
                        if petId then
                            petNameCache[tostring(petId)] = cleanName
                        end
                    end
                end
            end
        end
    end
end

-- Enhanced function to get clean pet name from backpack
function PetFunctions.getPetNameFromBackpack(petIndex)
    local player = Players.LocalPlayer
    if not player or not player.Backpack then return "Pet" end
    
    local petTools = {}
    
    -- Collect all pet tools
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
            table.insert(petTools, tool)
        end
    end
    
    -- Get the pet name by index (since pets are usually in order)
    if petTools[petIndex] then
        local petName = petTools[petIndex].Name
        if petName and petName ~= "" then
            -- Extract just the pet type (remove weight and age)
            -- Example: "Raccoon [1.49 KG] [Age 1]" -> "Raccoon"
            local cleanName = string.match(petName, "^([^%[]+)")
            if cleanName then
                return string.gsub(cleanName, "%s+$", "") -- Remove trailing spaces
            end
        end
    end
    
    return "Pet"
end

-- Function to get pet ID from PetMover
function PetFunctions.getPetIdFromPetMover(petMover)
    if not petMover then return nil end
    
    local petId = petMover:GetAttribute("PetId") or 
                 petMover:GetAttribute("Id") or 
                 petMover:GetAttribute("UUID") or
                 petMover:GetAttribute("petId")
    
    if petId then return petId end
    
    if petMover.Parent and PetFunctions.isValidUUID(petMover.Parent.Name) then
        return petMover.Parent.Name
    end
    
    if PetFunctions.isValidUUID(petMover.Name) then
        return petMover.Name
    end
    
    return petMover:GetFullName()
end

-- Function to create ESP "X" marker
function PetFunctions.createESPMarker(pet)
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
function PetFunctions.removeESPMarker(petId)
    if excludedPetESPs[petId] then
        excludedPetESPs[petId]:Destroy()
        excludedPetESPs[petId] = nil
    end
end

-- Function to get all pets with proper names from backpack
function PetFunctions.getAllPets()
    local pets = {}
    local petIndex = 1 -- Track pet index for backpack matching
    
    local function processPetContainer(container)
        local petMover = container:FindFirstChild("PetMover")
        if petMover and petMover:IsA("BasePart") then
            local petId = PetFunctions.getPetIdFromPetMover(petMover)
            if petId then
                local petName = PetFunctions.getPetNameFromBackpack(petIndex)
                table.insert(pets, {
                    id = petId,
                    name = petName,
                    model = container,
                    mover = petMover,
                    position = petMover.Position,
                    index = petIndex
                })
                petIndex = petIndex + 1
            end
        end
    end
    
    local function findStandalonePetMovers(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Part") and child.Name == "PetMover" then
                local petId = PetFunctions.getPetIdFromPetMover(child)
                if petId then
                    local petName = PetFunctions.getPetNameFromBackpack(petIndex)
                    table.insert(pets, {
                        id = petId,
                        name = petName,
                        model = child.Parent,
                        mover = child,
                        position = child.Position,
                        index = petIndex
                    })
                    petIndex = petIndex + 1
                end
            elseif child:IsA("Model") or child:IsA("Folder") then
                findStandalonePetMovers(child)
            end
        end
    end
    
    if not petsFolder then
        petsFolder = PetFunctions.findPetsFolder()
    end
    
    if petsFolder then
        if petsFolder.Name == "PetsPhysical" then
            local petMoverFolder = petsFolder:FindFirstChild("PetMover")
            if petMoverFolder then
                for _, petContainer in pairs(petMoverFolder:GetChildren()) do
                    if petContainer:IsA("Model") and PetFunctions.isValidUUID(petContainer.Name) then
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
function PetFunctions.getFarmCenterPoint()
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
function PetFunctions.formatPetIdToUUID(petId)
    if string.match(petId, "^{%x+%-%x+%-%x+%-%x+%-%x+}$") then
        return petId
    end
    
    petId = string.gsub(petId, "[{}]", "")
    return "{" .. petId .. "}"
end

-- Function to set pet state
function PetFunctions.setPetState(petId, state)
    local formattedPetId = PetFunctions.formatPetIdToUUID(petId)
    pcall(function()
        ActivePetService:FireServer("SetPetState", formattedPetId, state)
    end)
end

-- Function to unequip pet (fastest method)
function PetFunctions.unequipPet(petTool)
    if not petTool or not petTool.Parent then return false end
    
    local success = pcall(function()
        -- Try multiple methods for maximum compatibility
        if PetsService then
            PetsService:FireServer("UnequipPet", petTool.Name)
        end
        
        -- Also try direct tool removal
        if petTool.Parent == Players.LocalPlayer.Character then
            petTool.Parent = Players.LocalPlayer.Backpack
        end
        
        -- Additional unequip methods
        if petTool:FindFirstChild("Handle") then
            petTool.Handle.CanTouch = false
        end
        
        -- Fire unequip event if it exists
        local unequipEvent = petTool:FindFirstChild("Unequip") or petTool:FindFirstChild("UnequipEvent")
        if unequipEvent and unequipEvent:IsA("RemoteEvent") then
            unequipEvent:FireServer()
        end
    end)
    
    return success
end

-- Function to equip pet (fastest method)
function PetFunctions.equipPet(petTool)
    if not petTool or not petTool.Parent then return false end
    
    local success = pcall(function()
        local player = Players.LocalPlayer
        if not player or not player.Character then return end
        
        -- Try multiple methods for maximum compatibility
        if PetsService then
            PetsService:FireServer("EquipPet", petTool.Name)
        end
        
        -- Also try direct tool equipping
        if petTool.Parent == player.Backpack then
            player.Character.Humanoid:EquipTool(petTool)
        end
        
        -- Additional equip methods
        if petTool:FindFirstChild("Handle") then
            petTool.Handle.CanTouch = true
        end
        
        -- Fire equip event if it exists
        local equipEvent = petTool:FindFirstChild("Equip") or petTool:FindFirstChild("EquipEvent")
        if equipEvent and equipEvent:IsA("RemoteEvent") then
            equipEvent:FireServer()
        end
    end)
    
    return success
end

-- Fast batch unequip function
function PetFunctions.fastUnequipAllPets()
    local petTools = PetFunctions.getAllPetToolsFromBackpack()
    local player = Players.LocalPlayer
    
    if not player or not player.Character then return false end
    
    print("Fast unequipping " .. #petTools .. " pets...")
    
    -- Unequip all pets in batches for better performance
    for i = 1, #petTools, BATCH_SIZE do
        local batch = {}
        for j = i, math.min(i + BATCH_SIZE - 1, #petTools) do
            table.insert(batch, petTools[j])
        end
        
        -- Process batch
        for _, petTool in pairs(batch) do
            spawn(function()
                PetFunctions.unequipPet(petTool)
            end)
        end
        
        -- Small delay between batches
        if i + BATCH_SIZE - 1 < #petTools then
            task.wait(FAST_UNEQUIP_DELAY)
        end
    end
    
    print("Fast unequip completed!")
    return true
end

-- Fast batch equip function
function PetFunctions.fastEquipAllPets()
    task.wait(0.1) -- Brief pause to ensure unequip is complete
    
    local petTools = PetFunctions.getAllPetToolsFromBackpack()
    local player = Players.LocalPlayer
    
    if not player or not player.Character then return false end
    
    print("Fast equipping " .. #petTools .. " pets...")
    
    -- Equip all pets in batches for better performance
    for i = 1, #petTools, BATCH_SIZE do
        local batch = {}
        for j = i, math.min(i + BATCH_SIZE - 1, #petTools) do
            table.insert(batch, petTools[j])
        end
        
        -- Process batch
        for _, petTool in pairs(batch) do
            spawn(function()
                PetFunctions.equipPet(petTool)
            end)
        end
        
        -- Small delay between batches
        if i + BATCH_SIZE - 1 < #petTools then
            task.wait(FAST_EQUIP_DELAY)
        end
    end
    
    print("Fast equip completed!")
    return true
end

-- Enhanced refresh pets function with fast unequip/re-equip
function PetFunctions.refreshPets()
    if isRefreshing then
        print("Refresh already in progress, please wait...")
        return {}
    end
    
    isRefreshing = true
    print("Starting fast pet refresh...")
    
    -- Store current selections
    local previouslySelected = {}
    for petId, _ in pairs(selectedPets) do
        previouslySelected[petId] = true
    end
    local wasAllSelected = allPetsSelected
    
    -- Reset selections temporarily
    selectedPets = {}
    allPetsSelected = false
    
    local success = true
    
    -- Step 1: Fast unequip all pets
    if not PetFunctions.fastUnequipAllPets() then
        print("Warning: Fast unequip may have failed")
        success = false
    end
    
    -- Step 2: Wait a moment for server to process
    task.wait(0.2)
    
    -- Step 3: Fast re-equip all pets
    if not PetFunctions.fastEquipAllPets() then
        print("Warning: Fast equip may have failed")
        success = false
    end
    
    -- Step 4: Wait for pets to fully load
    task.wait(0.3)
    
    -- Step 5: Refresh pets folder and update data
    petsFolder = PetFunctions.findPetsFolder()
    local pets = PetFunctions.getAllPets()
    
    -- Step 6: Update dropdown and restore selections
    PetFunctions.updateDropdownOptions()
    
    -- Restore previous selections if they still exist
    if wasAllSelected then
        PetFunctions.selectAllPets()
    else
        for _, pet in pairs(pets) do
            if previouslySelected[pet.id] then
                selectedPets[pet.id] = true
            end
        end
    end
    
    PetFunctions.updatePetCount()
    
    isRefreshing = false
    
    if success then
        print("Fast pet refresh completed successfully! Found " .. #pets .. " pets.")
    else
        print("Pet refresh completed with warnings. Found " .. #pets .. " pets.")
    end
    
    return pets
end

-- Function to run the auto middle loop
function PetFunctions.runAutoMiddleLoop()
    if not autoMiddleEnabled then return end
    
    local pets = PetFunctions.getAllPets()
    local farmCenterPoint = PetFunctions.getFarmCenterPoint()
    
    if not farmCenterPoint then return end
    
    for _, pet in pairs(pets) do
        -- Skip excluded pets
        if not excludedPets[pet.id] then
            if allPetsSelected or selectedPets[pet.id] then
                local distance = (pet.mover.Position - farmCenterPoint).Magnitude
                if distance > RADIUS then
                    PetFunctions.setPetState(pet.id, "Idle")
                end
            end
        end
    end
end

-- Function to start the heartbeat loop
function PetFunctions.startLoop()
    if autoMiddleConnection then
        autoMiddleConnection:Disconnect()
    end
    
    isLooping = true
    autoMiddleConnection = RunService.Heartbeat:Connect(function()
        if not isLooping then return end
        PetFunctions.runAutoMiddleLoop()
        task.wait(LOOP_DELAY)
    end)
end

-- Function to stop the heartbeat loop
function PetFunctions.stopLoop()
    isLooping = false
    if autoMiddleConnection then
        autoMiddleConnection:Disconnect()
        autoMiddleConnection = nil
    end
end

-- Function to start initial loop
function PetFunctions.startInitialLoop()
    if not autoMiddleEnabled then return end
    
    PetFunctions.startLoop()
    
    if loopTimer then
        task.cancel(loopTimer)
    end
    
    loopTimer = task.spawn(function()
        task.wait(INITIAL_LOOP_TIME)
        if autoMiddleEnabled then
            PetFunctions.stopLoop()
        end
    end)
end

-- Function to handle PetZoneAbility detection
function PetFunctions.onPetZoneAbility()
    if not autoMiddleEnabled then return end
    
    -- Update the last zone ability time
    lastZoneAbilityTime = tick()
    
    if delayTimer then
        task.cancel(delayTimer)
    end
    
    delayTimer = task.spawn(function()
        task.wait(ZONE_ABILITY_DELAY)
        if autoMiddleEnabled then
            PetFunctions.startLoop()
            task.wait(ZONE_ABILITY_LOOP_TIME)
            if autoMiddleEnabled then
                PetFunctions.stopLoop()
            end
        end
    end)
end

-- Function to handle Notification signal detection
function PetFunctions.onNotificationSignal()
    if not autoMiddleEnabled then return end
    
    -- Run the loop when notification signal is detected
    PetFunctions.startLoop()
    task.wait(INITIAL_LOOP_TIME)
    if autoMiddleEnabled then
        PetFunctions.stopLoop()
    end
end

-- Function to setup PetZoneAbility listener
function PetFunctions.setupZoneAbilityListener()
    if zoneAbilityConnection then
        zoneAbilityConnection:Disconnect()
    end
    zoneAbilityConnection = PetZoneAbility.OnClientEvent:Connect(PetFunctions.onPetZoneAbility)
end

-- Function to setup Notification listener
function PetFunctions.setupNotificationListener()
    if notificationConnection then
        notificationConnection:Disconnect()
    end
    notificationConnection = Notification.OnClientEvent:Connect(PetFunctions.onNotificationSignal)
end

-- Function to cleanup all timers and connections
function PetFunctions.cleanup()
    PetFunctions.stopLoop()
    
    if zoneAbilityConnection then
        zoneAbilityConnection:Disconnect()
        zoneAbilityConnection = nil
    end
    
    if notificationConnection then
        notificationConnection:Disconnect()
        notificationConnection = nil
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
function PetFunctions.selectAllPets()
    selectedPets = {}
    allPetsSelected = true
    local pets = PetFunctions.getAllPets()
    for _, pet in pairs(pets) do
        selectedPets[pet.id] = true
    end
end

-- Function to update dropdown options
function PetFunctions.updateDropdownOptions()
    local pets = PetFunctions.getAllPets()
    currentPetsList = {}
    local dropdownOptions = {"None"}
    
    for i, pet in pairs(pets) do
        local shortId = string.sub(tostring(pet.id), 1, 8)
        local displayName = pet.name .. " (" .. shortId .. "...)"
        table.insert(dropdownOptions, displayName)
        currentPetsList[displayName] = pet
    end
    
    -- Update the dropdown options
    if petDropdown and petDropdown.Refresh then
        petDropdown:Refresh(dropdownOptions, true)
    end
end

-- Function to update pet count
function PetFunctions.updatePetCount()
    local pets = PetFunctions.getAllPets()
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

-- Helper functions for external use
function PetFunctions.isPetExcluded(petId)
    return excludedPets[petId] == true
end

function PetFunctions.getExcludedPetCount()
    local count = 0
    for _ in pairs(excludedPets) do
        count = count + 1
    end
    return count
end

function PetFunctions.getExcludedPetIds()
    local ids = {}
    for petId, _ in pairs(excludedPets) do
        table.insert(ids, petId)
    end
    return ids
end

-- Function to manually refresh dropdown with backpack names
function PetFunctions.refreshDropdownFromBackpack()
    print("Refreshing dropdown with backpack pet names...")
    PetFunctions.updateDropdownOptions()
    PetFunctions.updatePetCount()
    print("Dropdown refresh complete!")
end

-- Fast refresh function (alias for refreshPets)
function PetFunctions.fastRefresh()
    return PetFunctions.refreshPets()
end

-- Function to check if refresh is in progress
function PetFunctions.isRefreshInProgress()
    return isRefreshing
end

-- Getters and Setters
function PetFunctions.setAutoMiddleEnabled(enabled)
    autoMiddleEnabled = enabled
    if enabled then
        lastZoneAbilityTime = tick() -- Reset timer when enabling
        PetFunctions.setupNotificationListener()
    else
        if notificationConnection then
            notificationConnection:Disconnect()
            notificationConnection = nil
        end
    end
end

function PetFunctions.getAutoMiddleEnabled()
    return autoMiddleEnabled
end

function PetFunctions.setPetCountLabel(label)
    petCountLabel = label
end

function PetFunctions.setPetDropdown(dropdown)
    petDropdown = dropdown
end

function PetFunctions.getSelectedPets()
    return selectedPets
end

function PetFunctions.getExcludedPets()
    return excludedPets
end

function PetFunctions.getCurrentPetsList()
    return currentPetsList
end

function PetFunctions.setExcludedPets(pets)
    excludedPets = pets
end

-- Initialize the system with auto refresh
task.spawn(function()
    task.wait(1) -- Wait a moment for everything to load
    PetFunctions.refreshPets()
    PetFunctions.updatePetCount()
end)

PetFunctions.updateDropdownOptions()

-- Make functions available globally if needed
_G.updateDropdownOptions = PetFunctions.updateDropdownOptions
_G.refreshPets = PetFunctions.refreshPets
_G.fastRefresh = PetFunctions.fastRefresh -- New fast refresh alias
_G.isPetExcluded = PetFunctions.isPetExcluded
_G.getExcludedPetCount = PetFunctions.getExcludedPetCount
_G.getExcludedPetIds = PetFunctions.getExcludedPetIds
_G.refreshDropdownFromBackpack = PetFunctions.refreshDropdownFromBackpack
_G.isRefreshInProgress = PetFunctions.isRefreshInProgress -- New status function

return PetFunctions
