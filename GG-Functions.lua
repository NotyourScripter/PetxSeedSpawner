-- GAGSL Hub Functions Library
-- This file contains all the core functions for the GAGSL Hub

local Functions = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Variables
local BuyEventShopStock = ReplicatedStorage.GameEvents.BuyEventShopStock
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
    "Zen Seed Pack", "Zen Egg", "Hot Spring", "Zen Flare", "Zen Crate",
    "Soft Sunshine", "Koi", "Zen Gnome Crate", "Spiked Mango", 
    "Pet Shard Tranquil", "Zen Sand"
}

local merchantItems = {
    "Star Caller", "Night Staff", "Bee Egg", "Honey Sprinkler",
    "Flower Seed Pack", "Cloudtouched Spray", "Mutation Spray Disco",
    "Mutation Spray Verdant", "Mutation Spray Windstruck", "Mutation Spray Wet"
}

-- Pet Control Variables
local RADIUS = 0.5
local LOOP_DELAY = 1
local INITIAL_LOOP_TIME = 5
local ZONE_ABILITY_DELAY = 3
local ZONE_ABILITY_LOOP_TIME = 3

local shovelClient = player:WaitForChild("PlayerScripts"):WaitForChild("Shovel_Client")
local objectsFolder = Workspace:WaitForChild("Farm"):WaitForChild("Farm"):WaitForChild("Important"):WaitForChild("Objects_Physical")
local DeleteObject = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DeleteObject")
local RemoveItem = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Remove_Item")

local ActivePetService = ReplicatedStorage.GameEvents.ActivePetService
local PetZoneAbility = ReplicatedStorage.GameEvents.PetZoneAbility

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
local autoBuyEnabled = false
local buyConnection = nil

-- ========== MAIN TAB FUNCTIONS ==========
function Functions.joinJobId(jobId)
    if jobId and jobId ~= "" then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
    end
end

function Functions.copyJobId()
    if setclipboard then
        local jobId = game.JobId
        setclipboard(jobId)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Copied!",
            Text = "Current Job ID copied to clipboard.",
            Duration = 3
        })
    end
end

function Functions.rejoinServer()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end

function Functions.serverHop()
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
        game.StarterGui:SetCore("SendNotification", {
            Title = "Server Found",
            Text = "Found server with " .. tostring(playerCount) .. " players.",
            Duration = 3
        })
        task.wait(3)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, foundServer, player)
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "No Servers",
            Text = "Couldn't find a suitable server.",
            Duration = 3
        })
    end
end

-- ========== FARM TAB FUNCTIONS ==========
function Functions.getSprinklerTypes()
    return sprinklerTypes
end

function Functions.selectSprinklerType(selected)
    selectedSprinklers = {selected}
end

function Functions.autoEquipShovel()
    local backpack = player:FindFirstChild("Backpack")
    local shovel = backpack and backpack:FindFirstChild(shovelName)
    if shovel then
        shovel.Parent = player.Character
    end
end

function Functions.deleteSprinklers()
    if #selectedSprinklers == 0 then
        game.StarterGui:SetCore("SendNotification", {
            Title = "No Selection",
            Text = "No sprinkler types selected.",
            Duration = 3
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

    game.StarterGui:SetCore("SendNotification", {
        Title = "Done",
        Text = "Selected sprinklers deleted.",
        Duration = 4
    })
end

function Functions.refreshSprinklers()
    if #selectedSprinklers == 0 then
        game.StarterGui:SetCore("SendNotification", {
            Title = "No Selection",
            Text = "No sprinkler types selected to refresh.",
            Duration = 3
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
    game.StarterGui:SetCore("SendNotification", {
        Title = "Refreshed",
        Text = "Selected sprinklers removed and selection cleared.",
        Duration = 3
    })
end

function Functions.toggleAllSprinklers(value)
    if value then
        selectedSprinklers = sprinklerTypes
        game.StarterGui:SetCore("SendNotification", {
            Title = "All Selected",
            Text = "All sprinkler types selected.",
            Duration = 3
        })
    else
        selectedSprinklers = {}
    end
end

-- ========== PET CONTROL FUNCTIONS ==========
local function isValidUUID(str)
    if not str or type(str) ~= "string" then return false end
    str = string.gsub(str, "[{}]", "")
    return string.match(str, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

local function findPetsFolder()
    local possiblePaths = {"PetsPhysical", "Active Pets", "Pets", "ActivePets", "PetModels"}
    
    for _, path in pairs(possiblePaths) do
        local folder = Workspace:FindFirstChild(path)
        if folder then return folder end
    end
    
    if player and player.Character then
        for _, path in pairs(possiblePaths) do
            local folder = player.Character:FindFirstChild(path)
            if folder then return folder end
        end
    end
    
    return nil
end

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

local function createESPMarker(pet)
    if excludedPetESPs[pet.id] then return end
    
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

local function removeESPMarker(petId)
    if excludedPetESPs[petId] then
        excludedPetESPs[petId]:Destroy()
        excludedPetESPs[petId] = nil
    end
end

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

local function getFarmCenterPoint()
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

local function formatPetIdToUUID(petId)
    if string.match(petId, "^{%x+%-%x+%-%x+%-%x+%-%x+}$") then
        return petId
    end
    
    petId = string.gsub(petId, "[{}]", "")
    return "{" .. petId .. "}"
end

local function setPetState(petId, state)
    local formattedPetId = formatPetIdToUUID(petId)
    pcall(function()
        ActivePetService:FireServer("SetPetState", formattedPetId, state)
    end)
end

local function runAutoMiddleLoop()
    if not autoMiddleEnabled then return end
    
    local pets = getAllPets()
    local farmCenterPoint = getFarmCenterPoint()
    
    if not farmCenterPoint then return end
    
    for _, pet in pairs(pets) do
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

local function stopLoop()
    isLooping = false
    if autoMiddleConnection then
        autoMiddleConnection:Disconnect()
        autoMiddleConnection = nil
    end
end

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

local function setupZoneAbilityListener()
    if zoneAbilityConnection then
        zoneAbilityConnection:Disconnect()
    end
    zoneAbilityConnection = PetZoneAbility.OnClientEvent:Connect(onPetZoneAbility)
end

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
    
    if petDropdown and petDropdown.Refresh then
        petDropdown:Refresh(dropdownOptions, true)
    end
end

function Functions.initializePetSystem()
    petsFolder = findPetsFolder()
    updateDropdownOptions()
    
    task.spawn(function()
        while true do
            updatePetCount()
            task.wait(1)
        end
    end)
end

function Functions.setPetCountLabel(label)
    petCountLabel = label
end

function Functions.setPetDropdown(dropdown)
    petDropdown = dropdown
end

function Functions.handlePetExclusion(selectedValues)
    for petId, _ in pairs(excludedPets) do
        removeESPMarker(petId)
    end
    excludedPets = {}
    
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
                local selectedPet = currentPetsList[petName]
                if selectedPet then
                    excludedPets[selectedPet.id] = true
                    createESPMarker(selectedPet)
                end
            end
        end
    end
    
    updatePetCount()
    
    local excludedCount = 0
    for _ in pairs(excludedPets) do
        excludedCount = excludedCount + 1
    end
    
    if excludedCount > 0 then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Pets Excluded",
            Text = "Excluded " .. excludedCount .. " pets from auto middle.",
            Duration = 2
        })
    end
end

function Functions.refreshAndSelectAllPets()
    local newPets = getAllPets()
    selectedPets = {}
    allPetsSelected = true
    
    for _, pet in pairs(newPets) do
        selectedPets[pet.id] = true
    end
    
    updatePetCount()
    updateDropdownOptions()
    
    if petDropdown then
        petDropdown:ClearAll()
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Pets Refreshed & Selected",
        Text = "Found " .. #newPets .. " pets and selected all for auto middle.",
        Duration = 3
    })
end

function Functions.toggleAutoMiddle(value)
    autoMiddleEnabled = value
    if value then
        setupZoneAbilityListener()
        startInitialLoop()
    else
        Functions.cleanup()
    end
end

-- ========== SHOP FUNCTIONS ==========
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
            game:GetService("ReplicatedStorage").GameEvents.BuyTravelingMerchantShopStock:FireServer(item)
        end)
    end
end

function Functions.toggleAutoBuyZen(value)
    autoBuyEnabled = value
    
    if autoBuyEnabled then
        buyConnection = RunService.Heartbeat:Connect(function()
            buyAllZenItems()
            task.wait(0.1)
        end)
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Buy Zen",
            Text = "Auto Buy Zen enabled!",
            Duration = 2
        })
    else
        if buyConnection then
            buyConnection:Disconnect()
            buyConnection = nil
        end
    end
end

function Functions.toggleAutoBuyMerchant(value)
    autoBuyEnabled = value
    
    if autoBuyEnabled then
        buyConnection = RunService.Heartbeat:Connect(function()
            buyAllMerchantItems()
            task.wait(0.1)
        end)
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Buy Merchant",
            Text = "Auto Buy Traveling Merchant enabled!",
            Duration = 2
        })
    else
        if buyConnection then
            buyConnection:Disconnect()
            buyConnection = nil
        end
    end
end

-- ========== MISC FUNCTIONS ==========
function Functions.reduceLag()
    repeat
        local lag = Workspace:FindFirstChild("Lag", true)
        if lag ~= nil then
            lag:Destroy()
        end
        task.wait()
    until Workspace:FindFirstChild("Lag", true) == nil
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Lag Reduced",
        Text = "All lag objects have been removed.",
        Duration = 3
    })
end

function Functions.removeFarms()
    local farmFolder = Workspace:FindFirstChild("Farm")
    if not farmFolder then
        game.StarterGui:SetCore("SendNotification", {
            Title = "No Farms Found",
            Text = "Farm folder not found in Workspace.",
            Duration = 3
        })
        return
    end

    local playerCharacter = player.Character
    local rootPart = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        game.StarterGui
