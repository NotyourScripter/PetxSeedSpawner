-- GG-Functions.lua
-- Complete Functions for Grow A Garden Script Loader

local Functions = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

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

-- Pet Control Variables
local selectedPets = {}
local excludedPets = {}
local excludedPetESPs = {}
local allPetsSelected = false
local petsFolder = nil
local currentPetsList = {}

-- Auto-buy states
local autoBuyZenEnabled = false
local autoBuyMerchantEnabled = false
local zenBuyConnection = nil
local merchantBuyConnection = nil

-- Remote Events
local BuyEventShopStock = ReplicatedStorage.GameEvents.BuyEventShopStock
local BuyTravelingMerchantShopStock = ReplicatedStorage.GameEvents.BuyTravelingMerchantShopStock
local DeleteObject = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DeleteObject")
local RemoveItem = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Remove_Item")
local ActivePetService = ReplicatedStorage.GameEvents.ActivePetService
local PetZoneAbility = ReplicatedStorage.GameEvents.PetZoneAbility

-- Core folders/scripts
local shovelClient = player:WaitForChild("PlayerScripts"):WaitForChild("Shovel_Client")
local shovelPrompt = player:WaitForChild("PlayerGui"):WaitForChild("ShovelPrompt")
local objectsFolder = Workspace:WaitForChild("Farm"):WaitForChild("Farm"):WaitForChild("Important"):WaitForChild("Objects_Physical")

-- Auto-buy functions with proper connection management
function Functions.toggleAutoBuyZen(enabled)
    autoBuyZenEnabled = enabled
    
    if enabled then
        if zenBuyConnection then zenBuyConnection:Disconnect() end
        zenBuyConnection = RunService.Heartbeat:Connect(function()
            if autoBuyZenEnabled then
                Functions.buyAllZenItems()
                task.wait(1) -- Prevent spam
            end
        end)
    else
        if zenBuyConnection then
            zenBuyConnection:Disconnect()
            zenBuyConnection = nil
        end
    end
end

function Functions.toggleAutoBuyMerchant(enabled)
    autoBuyMerchantEnabled = enabled
    
    if enabled then
        if merchantBuyConnection then merchantBuyConnection:Disconnect() end
        merchantBuyConnection = RunService.Heartbeat:Connect(function()
            if autoBuyMerchantEnabled then
                Functions.buyAllMerchantItems()
                task.wait(1) -- Prevent spam
            end
        end)
    else
        if merchantBuyConnection then
            merchantBuyConnection:Disconnect()
            merchantBuyConnection = nil
        end
    end
end

-- Function to buy all zen items
function Functions.buyAllZenItems()
    for _, item in pairs(zenItems) do
        pcall(function()
            BuyEventShopStock:FireServer(item)
        end)
    end
end

-- Function to buy all merchant items
function Functions.buyAllMerchantItems()
    for _, item in pairs(merchantItems) do
        pcall(function()
            BuyTravelingMerchantShopStock:FireServer(item)
        end)
    end
end

-- Equip Shovel function
function Functions.autoEquipShovel()
    local backpack = player:FindFirstChild("Backpack")
    local shovel = backpack and backpack:FindFirstChild(shovelName)
    if shovel then
        shovel.Parent = player.Character
    end
end

local function getSprinklerTypes()
    return sprinklerTypes
end

local function addSprinklerToSelection(sprinklerName)
    -- Check if sprinkler is already in the array
    for i, sprinkler in ipairs(selectedSprinklers) do
        if sprinkler == sprinklerName then
            return -- Already exists, don't add duplicate
        end
    end
    -- Add to array
    table.insert(selectedSprinklers, sprinklerName)
    print("Added to selection:", sprinklerName)
    print("Current selection array:", selectedSprinklers)
end

local function removeSprinklerFromSelection(sprinklerName)
    -- Find and remove from array
    for i, sprinkler in ipairs(selectedSprinklers) do
        if sprinkler == sprinklerName then
            table.remove(selectedSprinklers, i)
            print("Removed from selection:", sprinklerName)
            print("Current selection array:", selectedSprinklers)
            return
        end
    end
end

local function setSelectedSprinklers(sprinklerArray)
    selectedSprinklers = sprinklerArray or {}
    print("Selection array set to:", selectedSprinklers)
end

local function getSelectedSprinklers()
    return selectedSprinklers
end

local function clearSelectedSprinklers()
    selectedSprinklers = {}
    print("Selection array cleared")
end

local function isSprinklerSelected(sprinklerName)
    for _, sprinkler in ipairs(selectedSprinklers) do
        if sprinkler == sprinklerName then
            return true
        end
    end
    return false
end

-- Remove Farms function
function Functions.removeFarms(OrionLib)
    local farmFolder = Workspace:FindFirstChild("Farm")
    if not farmFolder then
        if OrionLib then
            OrionLib:MakeNotification({
                Name = "No Farms Found",
                Content = "Farm folder not found in Workspace.",
                Time = 3
            })
        end
        return
    end

    local playerCharacter = player.Character
    local rootPart = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        if OrionLib then
            OrionLib:MakeNotification({
                Name = "Player Not Found",
                Content = "Player character or position not found.",
                Time = 3
            })
        end
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

    if OrionLib then
        OrionLib:MakeNotification({
            Name = "Farms Removed",
            Content = "All other farms have been deleted.",
            Time = 3
        })
    end
end

-- Function to check if string is UUID format
function Functions.isValidUUID(str)
    if not str or type(str) ~= "string" then return false end
    str = string.gsub(str, "[{}]", "")
    return string.match(str, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

-- Function to find pets folder
function Functions.findPetsFolder()
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
function Functions.getPetIdFromPetMover(petMover)
    if not petMover then return nil end
    
    local petId = petMover:GetAttribute("PetId") or 
                 petMover:GetAttribute("Id") or 
                 petMover:GetAttribute("UUID") or
                 petMover:GetAttribute("petId")
    
    if petId then return petId end
    
    if petMover.Parent and Functions.isValidUUID(petMover.Parent.Name) then
        return petMover.Parent.Name
    end
    
    if Functions.isValidUUID(petMover.Name) then
        return petMover.Name
    end
    
    return petMover:GetFullName()
end

-- Function to create ESP "X" marker
function Functions.createESPMarker(pet)
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
function Functions.removeESPMarker(petId)
    if excludedPetESPs[petId] then
        excludedPetESPs[petId]:Destroy()
        excludedPetESPs[petId] = nil
    end
end

-- Function to get all pets
function Functions.getAllPets()
    local pets = {}
    
    local function processPetContainer(container)
        local petMover = container:FindFirstChild("PetMover")
        if petMover and petMover:IsA("BasePart") then
            local petId = Functions.getPetIdFromPetMover(petMover)
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
                local petId = Functions.getPetIdFromPetMover(child)
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
        petsFolder = Functions.findPetsFolder()
    end
    
    if petsFolder then
        if petsFolder.Name == "PetsPhysical" then
            local petMoverFolder = petsFolder:FindFirstChild("PetMover")
            if petMoverFolder then
                for _, petContainer in pairs(petMoverFolder:GetChildren()) do
                    if petContainer:IsA("Model") and Functions.isValidUUID(petContainer.Name) then
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
function Functions.getFarmCenterPoint()
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
function Functions.formatPetIdToUUID(petId)
    if string.match(petId, "^{%x+%-%x+%-%x+%-%x+%-%x+}$") then
        return petId
    end
    
    petId = string.gsub(petId, "[{}]", "")
    return "{" .. petId .. "}"
end

-- Function to set pet state
function Functions.setPetState(petId, state)
    local formattedPetId = Functions.formatPetIdToUUID(petId)
    pcall(function()
        ActivePetService:FireServer("SetPetState", formattedPetId, state)
    end)
end

-- Function to run the auto middle loop
function Functions.runAutoMiddleLoop(RADIUS)
    local pets = Functions.getAllPets()
    local farmCenterPoint = Functions.getFarmCenterPoint()
    
    if not farmCenterPoint then return end
    
    for _, pet in pairs(pets) do
        -- Skip excluded pets
        if not excludedPets[pet.id] then
            if allPetsSelected or selectedPets[pet.id] then
                local distance = (pet.mover.Position - farmCenterPoint).Magnitude
                if distance > RADIUS then
                    Functions.setPetState(pet.id, "Idle")
                end
            end
        end
    end
end

-- Function to select all pets
function Functions.selectAllPets()
    selectedPets = {}
    allPetsSelected = true
    local pets = Functions.getAllPets()
    for _, pet in pairs(pets) do
        selectedPets[pet.id] = true
    end
end

-- Function to update dropdown options
function Functions.updateDropdownOptions()
    local pets = Functions.getAllPets()
    currentPetsList = {}
    local dropdownOptions = {"None"}
    
    for i, pet in pairs(pets) do
        local shortId = string.sub(tostring(pet.id), 1, 8)
        local displayName = "Pet (" .. shortId .. "...)"
        table.insert(dropdownOptions, displayName)
        currentPetsList[displayName] = pet
    end
    
    return dropdownOptions
end

-- Function to refresh pets
function Functions.refreshPets()
    selectedPets = {}
    allPetsSelected = false
    petsFolder = Functions.findPetsFolder()
    local pets = Functions.getAllPets()
    return pets
end

-- Helper functions
function Functions.isPetExcluded(petId)
    return excludedPets[petId] == true
end

function Functions.getExcludedPetCount()
    local count = 0
    for _ in pairs(excludedPets) do
        count = count + 1
    end
    return count
end

function Functions.getExcludedPetIds()
    local ids = {}
    for petId, _ in pairs(excludedPets) do
        table.insert(ids, petId)
    end
    return ids
end

-- Function to reduce lag
function Functions.reduceLag()
    repeat
        local lag = game.Workspace:findFirstChild("Lag", true)
        if (lag ~= nil) then
            lag:remove()
        end
        wait()
    until (game.Workspace:findFirstChild("Lag", true) == nil)
end

-- Function to fade in main tab
function Functions.fadeInMainTab()
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

-- Server hopping function
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
        return foundServer, playerCount
    else
        return nil, nil
    end
end

-- Function to copy Discord link
function Functions.copyDiscordLink()
    if setclipboard then
        setclipboard("https://discord.gg/yura") -- Replace with actual Discord link
        if _G.OrionLib then
            _G.OrionLib:MakeNotification({
                Name = "Discord Link Copied",
                Content = "Discord link copied to clipboard!",
                Time = 3
            })
        end
    else
        warn("Clipboard access not available.")
    end
end

-- Cleanup function
function Functions.cleanup()
    -- Cleanup auto-buy connections
    if zenBuyConnection then
        zenBuyConnection:Disconnect()
        zenBuyConnection = nil
    end
    if merchantBuyConnection then
        merchantBuyConnection:Disconnect()
        merchantBuyConnection = nil
    end
    
    -- Clean up ESP markers
    for petId, esp in pairs(excludedPetESPs) do
        if esp then
            esp:Destroy()
        end
    end
    excludedPetESPs = {}
end

-- Export configuration tables and variables
Functions.sprinklerTypes = sprinklerTypes
Functions.zenItems = zenItems
Functions.merchantItems = merchantItems
Functions.selectedPets = selectedPets
Functions.excludedPets = excludedPets
Functions.excludedPetESPs = excludedPetESPs
Functions.allPetsSelected = allPetsSelected
Functions.currentPetsList = currentPetsList

return Functions
