-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Load Spawner
local Spawner = loadstring(game:HttpGet("https://codeberg.org/DarkBackup/script/raw/branch/main/loadstring"))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🌿 Spawner GUI | By Yura",
    LoadingTitle = "Spawner Initializing",
    LoadingSubtitle = "Please wait...",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Pets Tab
local PetTab = Window:CreateTab("🐾 Pets", 7734053494)

local PetName, PetKG, PetAge = "Raccoon", 1, 2

PetTab:CreateInput({
    Name = "Pet Name",
    PlaceholderText = "Raccoon",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        PetName = v
    end
})

PetTab:CreateInput({
    Name = "KG",
    PlaceholderText = "1",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        PetKG = tonumber(v)
    end
})

PetTab:CreateInput({
    Name = "Age",
    PlaceholderText = "2",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        PetAge = tonumber(v)
    end
})

PetTab:CreateButton({
    Name = "Spawn Pet",
    Callback = function()
        if PetName and PetKG and PetAge then
            Spawner.SpawnPet(PetName, PetKG, PetAge)
        else
            warn("Missing pet info")
        end
    end
})

-- Seeds Tab
local SeedTab = Window:CreateTab("🌾 Seeds", 7733960981)

local SeedName = "Candy Blossom"

SeedTab:CreateInput({
    Name = "Seed Name",
    PlaceholderText = "Candy Blossom",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        SeedName = v
    end
})

SeedTab:CreateButton({
    Name = "Spawn Seed",
    Callback = function()
        Spawner.SpawnSeed(SeedName)
    end
})

-- Eggs Tab
local EggTab = Window:CreateTab("🥚 Eggs", 7733964644)

local EggName = "Night Egg"

EggTab:CreateInput({
    Name = "Egg Name",
    PlaceholderText = "Night Egg",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        EggName = v
    end
})

EggTab:CreateButton({
    Name = "Spawn Egg",
    Callback = function()
        Spawner.SpawnEgg(EggName)
    end
})

-- Spin Tab
local SpinTab = Window:CreateTab("🎡 Spin", 7733975874)

local SpinName = "Sunflower"

SpinTab:CreateInput({
    Name = "Plant Name",
    PlaceholderText = "Sunflower",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        SpinName = v
    end
})

SpinTab:CreateButton({
    Name = "Spin Plant",
    Callback = function()
        Spawner.Spin(SpinName)
    end
})

-- Misc Tab
local MiscTab = Window:CreateTab("⚙️ Misc", 7734053494)

MiscTab:CreateButton({
    Name = "Load Default UI",
    Callback = function()
        Spawner.Load()
    end
})
