-- Fast Pet Detection and Registration System
local FastPetSystem = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Pet Services
local PetsService = ReplicatedStorage.GameEvents.PetsService
local RefreshActivePetsUI = ReplicatedStorage.GameEvents.RefreshActivePetsUI

-- Fast detection configuration
local DETECTION_TIMEOUT = 0.5 -- Maximum time to wait for detection
local EQUIP_DELAY = 0.05 -- Minimal delay between operations
local NAME_DETECTION_ATTEMPTS = 3 -- How many times to try getting name

-- Pet cache for ultra-fast access
local petCache = {}
local uuidToNameMap = {}

-- Function to detect UUID format
function FastPetSystem.isValidUUID(str)
    if not str or type(str) ~= "string" then return false end
    str = string.gsub(str, "[{}]", "")
    return string.match(str, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

-- Function to format UUID properly
function FastPetSystem.formatUUID(uuid)
    if string.match(uuid, "^{%x+%-%x+%-%x+%-%x+%-%x+}$") then
        return uuid
    end
    uuid = string.gsub(uuid, "[{}]", "")
    return "{" .. uuid .. "}"
end

-- Ultra-fast UUID detection from multiple sources
function FastPetSystem.detectUUIDsFromWorkspace()
    local uuids = {}
    local startTime = tick()
    
    -- Pre-scan backpack for immediate pet data (fastest method)
    FastPetSystem.scanBackpackForPetNames()
    
    -- Check common pet locations simultaneously
    local locations = {
        Workspace:FindFirstChild("PetsPhysical"),
        Workspace:FindFirstChild("Active Pets"),
        Workspace:FindFirstChild("Pets"),
        Workspace:FindFirstChild("ActivePets")
    }
    
    for _, location in pairs(locations) do
        if location then
            -- Fast traversal with early exit
            local function quickScan(parent, depth)
                if depth > 3 or tick() - startTime > DETECTION_TIMEOUT then return end
                
                for _, child in pairs(parent:GetChildren()) do
                    -- Check if this is a UUID
                    if FastPetSystem.isValidUUID(child.Name) then
                        uuids[child.Name] = true
                    end
                    
                    -- Check attributes for UUIDs
                    for attrName, attrValue in pairs(child:GetAttributes()) do
                        if (attrName:lower():find("pet") or attrName:lower():find("id")) and 
                           FastPetSystem.isValidUUID(tostring(attrValue)) then
                            uuids[tostring(attrValue)] = true
                        end
                    end
                    
                    -- Quick recursive check
                    if child:IsA("Model") or child:IsA("Folder") then
                        quickScan(child, depth + 1)
                    end
                end
            end
            
            quickScan(location, 0)
        end
    end
    
    -- Also check player backpack and character for pet tools
    local player = Players.LocalPlayer
    if player then
        -- Check backpack
        if player.Backpack then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
                    local petId = tool:GetAttribute("PetId") or 
                                 tool:GetAttribute("UUID") or 
                                 tool:GetAttribute("Id")
                    
                    if petId and FastPetSystem.isValidUUID(tostring(petId)) then
                        uuids[tostring(petId)] = true
                    end
                end
            end
        end
        
        -- Check character
        if player.Character then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
                    local petId = tool:GetAttribute("PetId") or 
                                 tool:GetAttribute("UUID") or 
                                 tool:GetAttribute("Id")
                    
                    if petId and FastPetSystem.isValidUUID(tostring(petId)) then
                        uuids[tostring(petId)] = true
                    end
                end
            end
        end
    end
    
    return uuids
end

-- Function to clean pet name (remove KG and Age)
function FastPetSystem.cleanPetName(petName)
    if not petName then return nil end
    
    local cleanName = petName
    
    -- Remove weight pattern [X.XX KG] or [X KG]
    cleanName = string.gsub(cleanName, "%s*%[%d+%.?%d*%s*KG%]", "")
    
    -- Remove age pattern [Age XX]
    cleanName = string.gsub(cleanName, "%s*%[Age%s*%d+%]", "")
    
    -- Remove any other bracketed info like [Shiny], [Golden], etc. if needed
    -- cleanName = string.gsub(cleanName, "%s*%[.-%]", "")
    
    -- Trim whitespace
    cleanName = string.match(cleanName, "^%s*(.-)%s*$") or cleanName
    
    return cleanName
end

-- Ultra-fast pet name detection from multiple sources
function FastPetSystem.extractPetNameFast(uuid)
    local player = Players.LocalPlayer
    if not player then return nil end
    
    -- Method 1: Check backpack first (fastest and most reliable)
    if player.Backpack then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
                -- Check if this tool corresponds to our UUID
                local toolId = tool:GetAttribute("PetId") or 
                              tool:GetAttribute("UUID") or 
                              tool:GetAttribute("Id")
                
                if toolId == uuid or FastPetSystem.formatUUID(tostring(toolId)) == FastPetSystem.formatUUID(uuid) then
                    return FastPetSystem.cleanPetName(tool.Name)
                end
                
                -- If no direct ID match, use the tool name (most common case)
                -- Since backpack pets are currently owned, we can use them as reference
                local cleanName = FastPetSystem.cleanPetName(tool.Name)
                if cleanName and cleanName ~= "" then
                    -- Store this mapping for future use
                    uuidToNameMap[FastPetSystem.formatUUID(uuid)] = cleanName
                    return cleanName
                end
            end
        end
    end
    
    -- Method 2: Check character for equipped pet tools
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
                local toolId = tool:GetAttribute("PetId") or 
                              tool:GetAttribute("UUID") or 
                              tool:GetAttribute("Id")
                
                if toolId == uuid or FastPetSystem.formatUUID(tostring(toolId)) == FastPetSystem.formatUUID(uuid) then
                    return FastPetSystem.cleanPetName(tool.Name)
                end
            end
        end
    end
    
    -- Method 3: Fast UI traversal (fallback)
    if player.PlayerGui then
        local uiNames = {
            "ActivePetsControllerUI",
            "ActivePetsUI", 
            "PetsUI",
            "PetInventoryUI",
            "InventoryUI"
        }
        
        for _, uiName in pairs(uiNames) do
            local ui = player.PlayerGui:FindFirstChild(uiName)
            if ui then
                local function findPetName(parent, depth)
                    if depth > 3 then return nil end
                    
                    for _, child in pairs(parent:GetChildren()) do
                        -- Look for UUID match
                        if child.Name == uuid or 
                           (child:GetAttribute("PetId") == uuid) or
                           (child:GetAttribute("UUID") == uuid) then
                            
                            local nameLabel = child:FindFirstChild("PetName") or 
                                            child:FindFirstChild("Name") or
                                            child:FindFirstChild("TextLabel")
                            
                            if nameLabel and nameLabel:IsA("TextLabel") then
                                return FastPetSystem.cleanPetName(nameLabel.Text)
                            end
                        end
                        
                        if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                            local found = findPetName(child, depth + 1)
                            if found then return found end
                        end
                    end
                    return nil
                end
                
                local petName = findPetName(ui, 0)
                if petName then return petName end
            end
        end
    end
    
    return nil
end

-- Smart backpack scanning for pet names
function FastPetSystem.scanBackpackForPetNames()
    local player = Players.LocalPlayer
    if not player or not player.Backpack then return {} end
    
    local petNames = {}
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool:FindFirstChild("PetToolLocal") or tool:FindFirstChild("PetToolServer")) then
            local cleanName = FastPetSystem.cleanPetName(tool.Name)
            if cleanName and cleanName ~= "" then
                -- Try to get the pet ID
                local petId = tool:GetAttribute("PetId") or 
                             tool:GetAttribute("UUID") or 
                             tool:GetAttribute("Id") or
                             tool:GetDebugId()
                
                if petId then
                    petNames[FastPetSystem.formatUUID(tostring(petId))] = cleanName
                else
                    -- Store by tool name as backup
                    petNames[tool.Name] = cleanName
                end
            end
        end
    end
    
    -- Update our name cache
    for uuid, name in pairs(petNames) do
        if FastPetSystem.isValidUUID(uuid) then
            uuidToNameMap[uuid] = name
        end
    end
    
    return petNames
end

-- Lightning-fast pet processing pipeline
function FastPetSystem.processPetUUID(uuid, callback)
    local formattedUUID = FastPetSystem.formatUUID(uuid)
    local petData = {
        id = formattedUUID,
        name = nil,
        processed = false
    }
    
    -- Step 1: Unequip (0.05s)
    task.spawn(function()
        pcall(function()
            PetsService:FireServer("UnequipPet", formattedUUID)
        end)
        
        task.wait(EQUIP_DELAY)
        
        -- Step 2: Try to get name from cache first, then backpack, then UI
        if uuidToNameMap[formattedUUID] then
            petData.name = uuidToNameMap[formattedUUID]
        else
            -- Step 3: Ultra-fast name detection (prioritize backpack)
            local name = FastPetSystem.extractPetNameFast(uuid)
            if name then
                petData.name = name
                uuidToNameMap[formattedUUID] = name -- Cache it
            else
                -- Fallback: try multiple quick attempts
                for i = 1, NAME_DETECTION_ATTEMPTS do
                    name = FastPetSystem.extractPetNameFast(uuid)
                    if name then
                        petData.name = name
                        uuidToNameMap[formattedUUID] = name
                        break
                    end
                    task.wait(0.02) -- Very short wait
                end
            end
        end
        
        -- Step 4: Re-equip immediately (0.05s)
        pcall(function()
            local player = Players.LocalPlayer
            local defaultCFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = player.Character.HumanoidRootPart.Position
                defaultCFrame = CFrame.new(pos.X, pos.Y, pos.Z)
            end
            
            PetsService:FireServer("EquipPet", formattedUUID, defaultCFrame)
        end)
        
        -- Step 5: Finalize and callback
        petData.name = petData.name or ("Pet_" .. string.sub(uuid, 1, 8))
        petData.processed = true
        petCache[formattedUUID] = petData
        
        if callback then
            callback(petData)
        end
    end)
    
    return petData
end

-- Ultra-fast batch processing
function FastPetSystem.batchProcessAllPets(onPetProcessed, onComplete)
    local startTime = tick()
    print("🚀 Starting ultra-fast pet detection...")
    
    -- Step 1: Detect all UUIDs (0.1s max)
    local detectedUUIDs = FastPetSystem.detectUUIDsFromWorkspace()
    local uuidList = {}
    
    for uuid, _ in pairs(detectedUUIDs) do
        table.insert(uuidList, uuid)
    end
    
    if #uuidList == 0 then
        print("❌ No pets detected!")
        if onComplete then onComplete({}) end
        return
    end
    
    print("📦 Detected " .. #uuidList .. " pets in " .. math.floor((tick() - startTime) * 1000) .. "ms")
    
    -- Step 2: Process all pets in parallel
    local processedPets = {}
    local completedCount = 0
    local totalPets = #uuidList
    
    for _, uuid in pairs(uuidList) do
        FastPetSystem.processPetUUID(uuid, function(petData)
            table.insert(processedPets, petData)
            completedCount = completedCount + 1
            
            -- Call individual pet callback
            if onPetProcessed then
                onPetProcessed(petData, completedCount, totalPets)
            end
            
            -- Check if all completed
            if completedCount >= totalPets then
                local totalTime = tick() - startTime
                print("✅ Processed all " .. totalPets .. " pets in " .. math.floor(totalTime * 1000) .. "ms")
                
                if onComplete then
                    onComplete(processedPets)
                end
            end
        end)
    end
end

-- Fast dropdown registration
function FastPetSystem.registerToDropdown(petData, dropdown)
    if not dropdown or not petData then return end
    
    local shortId = string.sub(petData.id, 1, 8)
    local displayName = (petData.name or "Pet") .. " (" .. shortId .. "...)"
    
    -- Fast dropdown update
    if dropdown.AddOption then
        dropdown:AddOption(displayName, petData)
    elseif dropdown.Options then
        table.insert(dropdown.Options, {
            Name = displayName,
            Value = petData
        })
        if dropdown.Refresh then
            dropdown:Refresh()
        end
    end
end

-- Main ultra-fast detection function with backpack preload
function FastPetSystem.ultraFastDetection(dropdown, statusLabel)
    local startTime = tick()
    
    if statusLabel then
        statusLabel:Set("🔍 Pre-loading pet data...")
    end
    
    -- Pre-load backpack data for instant name resolution
    FastPetSystem.smartDetectionPreload()
    
    if statusLabel then
        statusLabel:Set("🔍 Detecting pets...")
    end
    
    FastPetSystem.batchProcessAllPets(
        -- On each pet processed
        function(petData, completed, total)
            if dropdown then
                FastPetSystem.registerToDropdown(petData, dropdown)
            end
            
            if statusLabel then
                statusLabel:Set(string.format("⚡ Processing: %d/%d pets (%s)", completed, total, petData.name or "Unknown"))
            end
        end,
        
        -- On all completed
        function(allPets)
            local totalTime = tick() - startTime
            local timeMs = math.floor(totalTime * 1000)
            
            if statusLabel then
                statusLabel:Set(string.format("✅ Found %d pets in %dms", #allPets, timeMs))
            end
            
            print("🎉 Ultra-fast detection complete!")
            print("⚡ Total time: " .. timeMs .. "ms")
            print("🏆 Average per pet: " .. math.floor(timeMs / math.max(1, #allPets)) .. "ms")
            
            -- Show detected pet names
            local petNames = {}
            for _, pet in pairs(allPets) do
                if pet.name and pet.name ~= "" then
                    table.insert(petNames, pet.name)
                end
            end
            
            if #petNames > 0 then
                print("🐾 Detected pets: " .. table.concat(petNames, ", "))
            end
        end
    )
end

-- Export functions
FastPetSystem.detectUUIDs = FastPetSystem.detectUUIDsFromWorkspace
FastPetSystem.processUUID = FastPetSystem.processPetUUID
FastPetSystem.fastDetect = FastPetSystem.ultraFastDetection
FastPetSystem.refresh = FastPetSystem.quickRefresh
FastPetSystem.preload = FastPetSystem.smartDetectionPreload
FastPetSystem.cleanName = FastPetSystem.cleanPetName

-- Quick refresh function
function FastPetSystem.quickRefresh(dropdown, statusLabel)
    -- Clear cache for fresh detection
    petCache = {}
    
    -- Refresh UI first
    pcall(function()
        firesignal(RefreshActivePetsUI.OnClientEvent)
    end)
    
    -- Small delay then detect
    task.wait(0.1)
    FastPetSystem.ultraFastDetection(dropdown, statusLabel)
end

-- Smart detection with backpack pre-loading
function FastPetSystem.smartDetectionPreload()
    print("🔍 Pre-loading pet data from backpack...")
    
    -- Pre-scan backpack for instant name mapping
    local backpackPets = FastPetSystem.scanBackpackForPetNames()
    local foundCount = 0
    
    for uuid, name in pairs(backpackPets) do
        if FastPetSystem.isValidUUID(uuid) then
            foundCount = foundCount + 1
        end
    end
    
    print("📦 Pre-loaded " .. foundCount .. " pet names from backpack")
    return backpackPets
end

return FastPetSystem
