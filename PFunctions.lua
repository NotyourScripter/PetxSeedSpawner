-- Pet Control Functions Module
-- This module contains all pet-related functionality with backpack detection

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

-- Pet Control Services
local ActivePetService = ReplicatedStorage.GameEvents.ActivePetService
local PetZoneAbility = ReplicatedStorage.GameEvents.PetZoneAbility
local Notification = ReplicatedStorage.GameEvents.Notification

-- Pet Services for equip/unequip
local PetsService = nil
local ActivePetsUIController = nil

-- Initialize Pet Services
local function initializePetServices()
    pcall(function()
        PetsService = ReplicatedStorage.Modules.PetServices.ActivePetsService
    end)
    pcall(function()
        if not PetsService then
            PetsService = ReplicatedStorage.Modules.ActivePetsUIController
        end
    end)
    pcall(function()
        ActivePetsUIController = ReplicatedStorage.Modules.ActivePetsUIController
    end)
end

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

-- Function to extract pet name from backpack item
function PetFunctions.extractPetName(itemName)
    -- Remove player name, weight, and age information
    -- Pattern: "Pet Name [X.XX KG] [Age XX]"
    local cleanName = itemName
    
    -- Remove weight pattern [X.XX KG]
    cleanName = string.gsub(cleanName, "%s*%[%d+%.%d+%s*KG%]", "")
    
    -- Remove age pattern [Age XX]
    cleanName = string.gsub(cleanName, "%s*%[Age%s*%d+%]", "")
    
    -- Trim whitespace
    cleanName = string.match(cleanName, "^%s*(.-)%s*$")
    
    return cleanName
end

-- Function to get pet name from workspace pet model
function PetFunctions.extractPetNameFromModel(petModel)
    -- Try to find pet name from various sources in the model
    local petName = "Pet"
    
    -- Check for StringValue or other name holders
    local function searchForName(parent, depth)
        if depth > 3 then return nil end -- Limit search depth
        
        for _, child in pairs(parent:GetChildren()) do
            -- Look for common name patterns
            if child.Name == "PetName" or child.Name == "Name" or child.Name == "DisplayName" then
                if child:IsA("StringValue") and child.Value ~= "" then
                    return PetFunctions.extractPetName(child.Value)
                elseif child:IsA("TextLabel") and child.Text ~= "" then
                    return PetFunctions.extractPetName(child.Text)
                end
            end
            
            -- Check attributes
            local nameAttr = child:GetAttribute("PetName") or child:GetAttribute("Name") or child:GetAttribute("DisplayName")
            if nameAttr and nameAttr ~= "" then
                return PetFunctions.extractPetName(tostring(nameAttr))
            end
            
            -- Recursively search children
            if child:IsA("Model") or child:IsA("Folder") or child:IsA("Part") then
                local foundName = searchForName(child, depth + 1)
                if foundName then return foundName end
            end
        end
        return nil
    end
    
    -- Search the pet model for name information
    local foundName = searchForName(petModel, 0)
    if foundName and foundName ~= "" then
        petName = foundName
    else
        -- Try to get name from model's own attributes or name
        local modelNameAttr = petModel:GetAttribute("PetName") or petModel:GetAttribute("Name")
        if modelNameAttr and modelNameAttr ~= "" then
            petName = PetFunctions.extractPetName(tostring(modelNameAttr))
        elseif petModel.Name and not PetFunctions.isValidUUID(petModel.Name) then
            -- If model name is not a UUID, it might be the pet name
            petName = PetFunctions.extractPetName(petModel.Name)
        end
    end
    
    return petName
end

-- Function to get pets from backpack
function PetFunctions.getBackpackPets()
    local backpackPets = {}
    local player = Players.LocalPlayer
    
    if not player or not player.Backpack then
        return backpackPets
    end
    
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item:FindFirstChild("PetToolServer") or item:FindFirstChild("PetToolLocal")) then
            local cleanName = PetFunctions.extractPetName(item.Name)
            
            table.insert(backpackPets, {
                id = item:GetDebugId(), -- Use DebugId as unique identifier
                name = cleanName,
                originalName = item.Name,
                tool = item,
                isBackpackPet = true,
                position = Vector3.new(0, 0, 0) -- Backpack pets don't have position
            })
        end
    end
    
    return backpackPets
end

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

-- Function to get all pets (active pets only)
function PetFunctions.getAllPets()
    local pets = {}
    
    local function processPetContainer(container)
        local petMover = container:FindFirstChild("PetMover")
        if petMover and petMover:IsA("BasePart") then
            local petId = PetFunctions.getPetIdFromPetMover(petMover)
            if petId then
                local petName = PetFunctions.extractPetNameFromModel(container)
                table.insert(pets, {
                    id = petId,
                    name = petName,
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
                local petId = PetFunctions.getPetIdFromPetMover(child)
                if petId then
                    local petName = PetFunctions.extractPetNameFromModel(child.Parent)
                    table.insert(pets, {
                        id = petId,
                        name = petName,
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
    
    -- Get active pets from workspace only
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

-- Function to unequip all pets
function PetFunctions.unequipAllPets()
    if not PetsService then
        initializePetServices()
    end
    
    if PetsService then
        pcall(function()
            PetsService:FireServer("UnequipPet")
        end)
    end
end

-- Function to equip all pets
function PetFunctions.equipAllPets()
    if not PetsService then
        initializePetServices()
    end
    
    if PetsService then
        pcall(function()
            PetsService:FireServer("EquipPet")
        end)
    end
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

-- Enhanced refresh pets function with equip/unequip cycle and name detection
function PetFunctions.refreshPets()
    -- Clear current selections
    selectedPets = {}
    allPetsSelected = false
    
    -- Do equip/unequip cycle to refresh pets and ensure they're properly loaded
    print("Refreshing pets with equip/unequip cycle...")
    PetFunctions.unequipAllPets()
    task.wait(0.2) -- Slightly longer delay to ensure unequip completes
    PetFunctions.equipAllPets()
    task.wait(0.8) -- Longer wait for pets to be fully equipped and names to load
    
    -- Find pets folder
    petsFolder = PetFunctions.findPetsFolder()
    
    -- Get updated pets list with names
    local pets = PetFunctions.getAllPets()
    print("Found " .. #pets .. " pets after refresh")
    
    -- Update dropdown with new pet names
    PetFunctions.updateDropdownOptions()
    
    return pets
end

-- Legacy function kept for compatibility (now calls enhanced refresh)
function PetFunctions.refreshPetsWithEquipCycle()
    return PetFunctions.refreshPets()
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

-- Initialize Pet Services
initializePetServices()

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
_G.refreshPetsWithEquipCycle = PetFunctions.refreshPetsWithEquipCycle
_G.isPetExcluded = PetFunctions.isPetExcluded
_G.getExcludedPetCount = PetFunctions.getExcludedPetCount
_G.getExcludedPetIds = PetFunctions.getExcludedPetIds

return PetFunctions
