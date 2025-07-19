-- Enhanced Pet Functions Module (Controller-Managed Active Pets Only)
-- This module contains all pet-related functionality for active pets managed by ActivePetsUIController
-- No startup unequip/re-equip - Only works with currently active pets

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
local FAST_UNEQUIP_DELAY = 0.01
local FAST_EQUIP_DELAY = 0.01
local BATCH_SIZE = 10

-- Pet Control Services
local ActivePetService = ReplicatedStorage.GameEvents.ActivePetService
local PetsService = ReplicatedStorage.GameEvents.PetsService
local PetZoneAbility = ReplicatedStorage.GameEvents.PetZoneAbility
local Notification = ReplicatedStorage.GameEvents.Notification

-- ActivePetsUIController reference
local ActivePetsUIController = ReplicatedStorage.Modules:WaitForChild("ActivePetsUIController")

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
local lastZoneAbilityTime = 0
local isRefreshing = false
local isInitialized = false

-- Cache for pet names and controller data
local petNameCache = {}
local controllerActivePets = {}

-- Function to check if string is UUID format
function PetFunctions.isValidUUID(str)
    if not str or type(str) ~= "string" then return false end
    str = string.gsub(str, "[{}]", "")
    return string.match(str, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

-- Function to get active pets from ActivePetsUIController
function PetFunctions.getActivePetsFromController()
    local success, activePets = pcall(function()
        if ActivePetsUIController then
            local controllerModule = require(ActivePetsUIController)
            
            -- Try various possible function names
            if controllerModule.GetActivePets then
                return controllerModule:GetActivePets()
            elseif controllerModule.getActivePets then
                return controllerModule:getActivePets()
            elseif controllerModule.ActivePets then
                return controllerModule.ActivePets
            elseif controllerModule.activePets then
                return controllerModule.activePets
            elseif controllerModule.GetEquippedPets then
                return controllerModule:GetEquippedPets()
            elseif controllerModule.getEquippedPets then
                return controllerModule:getEquippedPets()
            end
        end
        return {}
    end)
    
    if success and activePets then
        controllerActivePets = activePets
        return activePets
    else
        return controllerActivePets -- Return cached version if available
    end
end

-- Function to check if a pet is managed by ActivePetsUIController
function PetFunctions.isPetManagedByController(petId)
    local activePets = PetFunctions.getActivePetsFromController()
    
    if not activePets or type(activePets) ~= "table" then
        return false
    end
    
    for _, petData in pairs(activePets) do
        if type(petData) == "table" then
            local controllerPetId = petData.Id or petData.id or petData.UUID or petData.uuid
            if controllerPetId and tostring(controllerPetId) == tostring(petId) then
                return true
            end
        end
    end
    
    return false
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

-- Function to get only active controller-managed pet tools from character
function PetFunctions.getControllerManagedPetToolsFromCharacter()
    local player = Players.LocalPlayer
    if not player or not player.Character then return {} end
    
    local petTools = {}
    
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
            local petId = tool:GetAttribute("PetId") or tool:GetAttribute("Id") or tool:GetAttribute("UUID")
            if petId and PetFunctions.isPetManagedByController(petId) then
                table.insert(petTools, tool)
            end
        end
    end
    
    return petTools
end

-- Function to get active pet names from controller only
function PetFunctions.getActivePetNamesFromController()
    local activePets = PetFunctions.getActivePetsFromController()
    local petNames = {}
    
    if activePets and type(activePets) == "table" then
        for _, petData in pairs(activePets) do
            if type(petData) == "table" and petData.Name then
                local cleanName = string.match(petData.Name, "^([^%[]+)")
                if cleanName then
                    cleanName = string.gsub(cleanName, "%s+$", "")
                    table.insert(petNames, cleanName)
                end
            elseif type(petData) == "string" then
                local cleanName = string.match(petData, "^([^%[]+)")
                if cleanName then
                    cleanName = string.gsub(cleanName, "%s+$", "")
                    table.insert(petNames, cleanName)
                end
            end
        end
    end
    
    return petNames
end

-- Function to update pet name cache from active pets only
function PetFunctions.updatePetNameCache()
    petNameCache = {}
    local activePets = PetFunctions.getActivePetsFromController()
    
    if activePets and type(activePets) == "table" then
        for _, petData in pairs(activePets) do
            if type(petData) == "table" then
                local petName = petData.Name or petData.name
                local petId = petData.Id or petData.id or petData.UUID or petData.uuid
                
                if petName and petId then
                    local cleanName = string.match(petName, "^([^%[]+)")
                    if cleanName then
                        cleanName = string.gsub(cleanName, "%s+$", "")
                        petNameCache[tostring(petId)] = cleanName
                    end
                end
            end
        end
    end
end

-- Function to get clean pet name for active pets
function PetFunctions.getActivePetName(petIndex)
    local activeNames = PetFunctions.getActivePetNamesFromController()
    
    if activeNames[petIndex] then
        return activeNames[petIndex]
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

-- Function to get all active pets managed by controller only
function PetFunctions.getAllActivePets()
    local pets = {}
    local petIndex = 1
    local controllerPets = PetFunctions.getActivePetsFromController()
    
    -- Create a lookup table for controller-managed pets
    local controllerPetIds = {}
    if controllerPets and type(controllerPets) == "table" then
        for _, petData in pairs(controllerPets) do
            if type(petData) == "table" then
                local petId = petData.Id or petData.id or petData.UUID or petData.uuid
                if petId then
                    controllerPetIds[tostring(petId)] = true
                end
            end
        end
    end
    
    local function processPetContainer(container)
        local petMover = container:FindFirstChild("PetMover")
        if petMover and petMover:IsA("BasePart") then
            local petId = PetFunctions.getPetIdFromPetMover(petMover)
            if petId and controllerPetIds[tostring(petId)] then
                local petName = PetFunctions.getActivePetName(petIndex)
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
                if petId and controllerPetIds[tostring(petId)] then
                    local petName = PetFunctions.getActivePetName(petIndex)
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

-- Function to unequip pet (controller-managed pets only)
function PetFunctions.unequipControllerManagedPet(petTool)
    if not petTool or not petTool.Parent then return false end
    
    local petId = petTool:GetAttribute("PetId") or petTool:GetAttribute("Id") or petTool:GetAttribute("UUID")
    if not petId or not PetFunctions.isPetManagedByController(petId) then
        return false
    end
    
    local success = pcall(function()
        if PetsService then
            PetsService:FireServer("UnequipPet", petTool.Name)
        end
        
        if petTool.Parent == Players.LocalPlayer.Character then
            petTool.Parent = Players.LocalPlayer.Backpack
        end
        
        if petTool:FindFirstChild("Handle") then
            petTool.Handle.CanTouch = false
        end
        
        local unequipEvent = petTool:FindFirstChild("Unequip") or petTool:FindFirstChild("UnequipEvent")
        if unequipEvent and unequipEvent:IsA("RemoteEvent") then
            unequipEvent:FireServer()
        end
    end)
    
    return success
end

-- Function to equip pet (controller-managed pets only)
function PetFunctions.equipControllerManagedPet(petTool)
    if not petTool or not petTool.Parent then return false end
    
    local petId = petTool:GetAttribute("PetId") or petTool:GetAttribute("Id") or petTool:GetAttribute("UUID")
    if not petId or not PetFunctions.isPetManagedByController(petId) then
        return false
    end
    
    local success = pcall(function()
        local player = Players.LocalPlayer
        if not player or not player.Character then return end
        
        if PetsService then
            PetsService:FireServer("EquipPet", petTool.Name)
        end
        
        if petTool.Parent == player.Backpack then
            player.Character.Humanoid:EquipTool(petTool)
        end
        
        if petTool:FindFirstChild("Handle") then
            petTool.Handle.CanTouch = true
        end
        
        local equipEvent = petTool:FindFirstChild("Equip") or petTool:FindFirstChild("EquipEvent")
        if equipEvent and equipEvent:IsA("RemoteEvent") then
            equipEvent:FireServer()
        end
    end)
    
    return success
end

-- Fast batch unequip function - Only for controller-managed pets
function PetFunctions.fastUnequipControllerPets()
    local petTools = PetFunctions.getControllerManagedPetToolsFromCharacter()
    local player = Players.LocalPlayer
    
    if not player or not player.Character then return false end
    
    -- Unequip all controller-managed pets in batches
    for i = 1, #petTools, BATCH_SIZE do
        local batch = {}
        for j = i, math.min(i + BATCH_SIZE - 1, #petTools) do
            table.insert(batch, petTools[j])
        end
        
        for _, petTool in pairs(batch) do
            spawn(function()
                PetFunctions.unequipControllerManagedPet(petTool)
            end)
        end
        
        if i + BATCH_SIZE - 1 < #petTools then
            task.wait(FAST_UNEQUIP_DELAY)
        end
    end
    
    return true
end

-- Fast batch equip function - Only for controller-managed pets
function PetFunctions.fastEquipControllerPets()
    task.wait(0.1)
    
    local player = Players.LocalPlayer
    if not player or not player.Backpack then return false end
    
    local petTools = {}
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
            local petId = tool:GetAttribute("PetId") or tool:GetAttribute("Id") or tool:GetAttribute("UUID")
            if petId and PetFunctions.isPetManagedByController(petId) then
                table.insert(petTools, tool)
            end
        end
    end
    
    if not player.Character then return false end
    
    -- Equip all controller-managed pets in batches
    for i = 1, #petTools, BATCH_SIZE do
        local batch = {}
        for j = i, math.min(i + BATCH_SIZE - 1, #petTools) do
            table.insert(batch, petTools[j])
        end
        
        for _, petTool in pairs(batch) do
            spawn(function()
                PetFunctions.equipControllerManagedPet(petTool)
            end)
        end
        
        if i + BATCH_SIZE - 1 < #petTools then
            task.wait(FAST_EQUIP_DELAY)
        end
    end
    
    return true
end

-- Initialize function (NO unequip/re-equip on startup)
function PetFunctions.initialize()
    if isInitialized then
        return
    end
    
    -- Find pets folder
    petsFolder = PetFunctions.findPetsFolder()
    
    -- Update pet name cache
    PetFunctions.updatePetNameCache()
    
    -- Get initial pet list (no unequip/re-equip)
    local pets = PetFunctions.getAllActivePets()
    
    -- Update dropdown and count
    PetFunctions.updateDropdownOptions()
    PetFunctions.updatePetCount()
    
    isInitialized = true
end

-- Enhanced refresh pets function with fast unequip/re-equip (Controller-Managed Pets Only)
function PetFunctions.refreshActivePets()
    if isRefreshing then
        return {}
    end
    
    isRefreshing = true
    
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
    
    -- Fast unequip only controller-managed pets
    if not PetFunctions.fastUnequipControllerPets() then
        success = false
    end
    
    task.wait(0.2)
    
    -- Fast re-equip controller-managed pets
    if not PetFunctions.fastEquipControllerPets() then
        success = false
    end
    
    task.wait(0.3)
    
    -- Refresh pets folder and update data
    petsFolder = PetFunctions.findPetsFolder()
    PetFunctions.updatePetNameCache()
    local pets = PetFunctions.getAllActivePets()
    
    -- Update dropdown and restore selections
    PetFunctions.updateDropdownOptions()
    
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
    
    return pets
end

-- Function to run the auto middle loop
function PetFunctions.runAutoMiddleLoop()
    if not autoMiddleEnabled then return end
    
    local pets = PetFunctions.getAllActivePets()
    local farmCenterPoint = PetFunctions.getFarmCenterPoint()
    
    if not farmCenterPoint then return end
    
    for _, pet in pairs(pets) do
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
    
    isInitialized = false
end

-- Function to select all pets
function PetFunctions.selectAllPets()
    selectedPets = {}
    allPetsSelected = true
    local pets = PetFunctions.getAllActivePets()
    for _, pet in pairs(pets) do
        selectedPets[pet.id] = true
    end
end

-- Function to update dropdown options
function PetFunctions.updateDropdownOptions()
    local pets = PetFunctions.getAllActivePets()
    currentPetsList = {}
    local dropdownOptions = {"None"}
    
    for _, pet in pairs(pets) do
        table.insert(dropdownOptions, pet.name)
        table.insert(currentPetsList, pet)
    end
    
    if petDropdown then
        petDropdown:SetOptions(dropdownOptions)
    end
end

-- Function to update pet count
function PetFunctions.updatePetCount()
    if not petCountLabel then return end
    
    local pets = PetFunctions.getAllActivePets()
    local selectedCount = 0
    
    if allPetsSelected then
        selectedCount = #pets
    else
        for _, pet in pairs(pets) do
            if selectedPets[pet.id] then
                selectedCount = selectedCount + 1
            end
        end
    end
    
    petCountLabel.Text = "Selected: " .. selectedCount .. " / " .. #pets .. " pets"
end

-- Expose functions for external use
PetFunctions.getAllPets = PetFunctions.getAllActivePets
PetFunctions.refreshPets = PetFunctions.refreshActivePets

return PetFunctions
