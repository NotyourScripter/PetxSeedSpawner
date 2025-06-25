-- Load OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Load Spawner
local Spawner = loadstring(game:HttpGet("https://codeberg.org/DarkBackup/script/raw/branch/main/loadstring"))()

-- Create Window
local Window = OrionLib:MakeWindow({
    Name = "🌱 Spawner GUI | By Yura",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "Spawner Loaded!"
})

-- Pet Tab
local PetTab = Window:MakeTab({
    Name = "🐾 Pets",
    Icon = "rbxassetid://7734053494",
    PremiumOnly = false
})

PetTab:AddTextbox({
    Name = "Pet Name",
    Default = "Raccoon",
    TextDisappear = false,
    Callback = function(v)
        _G.PetName = v
    end
})

PetTab:AddTextbox({
    Name = "KG",
    Default = "1",
    TextDisappear = false,
    Callback = function(v)
        _G.PetKG = tonumber(v)
    end
})

PetTab:AddTextbox({
    Name = "Age",
    Default = "2",
    TextDisappear = false,
    Callback = function(v)
        _G.PetAge = tonumber(v)
    end
})

PetTab:AddButton({
    Name = "Spawn Pet",
    Callback = function()
        if _G.PetName and _G.PetKG and _G.PetAge then
            Spawner.SpawnPet(_G.PetName, _G.PetKG, _G.PetAge)
        else
            warn("Missing Pet Info")
        end
    end
})

-- Seed Tab
local SeedTab = Window:MakeTab({
    Name = "🌾 Seeds",
    Icon = "rbxassetid://7733960981",
    PremiumOnly = false
})

SeedTab:AddTextbox({
    Name = "Seed Name",
    Default = "Candy Blossom",
    TextDisappear = false,
    Callback = function(v)
        _G.SeedName = v
    end
})

SeedTab:AddButton({
    Name = "Spawn Seed",
    Callback = function()
        if _G.SeedName then
            Spawner.SpawnSeed(_G.SeedName)
        end
    end
})

-- Egg Tab
local EggTab = Window:MakeTab({
    Name = "🥚 Eggs",
    Icon = "rbxassetid://7733964644",
    PremiumOnly = false
})

EggTab:AddTextbox({
    Name = "Egg Name",
    Default = "Night Egg",
    TextDisappear = false,
    Callback = function(v)
        _G.EggName = v
    end
})

EggTab:AddButton({
    Name = "Spawn Egg",
    Callback = function()
        if _G.EggName then
            Spawner.SpawnEgg(_G.EggName)
        end
    end
})

-- Spin Tab
local SpinTab = Window:MakeTab({
    Name = "🎡 Spin",
    Icon = "rbxassetid://7733975874",
    PremiumOnly = false
})

SpinTab:AddTextbox({
    Name = "Spin Plant",
    Default = "Sunflower",
    TextDisappear = false,
    Callback = function(v)
        _G.SpinPlant = v
    end
})

SpinTab:AddButton({
    Name = "Spin",
    Callback = function()
        if _G.SpinPlant then
            Spawner.Spin(_G.SpinPlant)
        end
    end
})

-- Misc Tab
local MiscTab = Window:MakeTab({
    Name = "⚙️ Misc",
    Icon = "rbxassetid://7734053494",
    PremiumOnly = false
})

MiscTab:AddButton({
    Name = "Load Default UI",
    Callback = function()
        Spawner.Load()
    end
})

-- Init
OrionLib:Init()
