	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local TweenService = game:GetService("TweenService")
	local backpack = player:WaitForChild("Backpack")
	local playerGui = player:WaitForChild("PlayerGui")
	local Players = game:GetService("Players")

	local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

	local Window = Rayfield:CreateWindow({
		Name = "GAGSL Hub",
		LoadingTitle = "Grow A Garden Script Loader Hub",
		LoadingSubtitle = "SUB TO -> YUraxYZ",
		ConfigurationSaving = {
			Enabled = false
		},
		Discord = {
			Enabled = false
		},
		KeySystem = false
	})

	local Window = Rayfield:CreateWindow({
		Name = "GAGSL Hub",
		LoadingTitle = "Loading...",
		LoadingSubtitle = "Script Tools Loaded",
		ConfigurationSaving = {
			Enabled = false
		}
	})

	local ToolsTab = Window:CreateTab("⚙️ Main", 0)

	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")
	local UserInputService = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local TeleportService = game:GetService("TeleportService")
	local PlaceId = game.PlaceId
	local JobId = game.JobId

	-- Detect version (v1525-style)
	local versionText = "Unknown"
	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("TextLabel") then
			local text = obj.Text
			if typeof(text) == "string" and text:lower():match("^v%d+$") then
				versionText = text
				break
			end
		end
	end

	-- Server Section
	ToolsTab:CreateParagraph({
		Title = "🌐 SERVER SECTION",
		Content = "Version: " .. versionText
	})

	ToolsTab:CreateInput({
		Name = "Input JobID",
		PlaceholderText = "Paste JobID here...",
		RemoveTextAfterFocusLost = false,
		Callback = function(jobId)
			if jobId and #jobId > 0 then
				local privateId = game.PrivateServerId
				if privateId and privateId ~= "" then
					TeleportService:TeleportToPrivateServer(PlaceId, privateId, {player})
				else
					TeleportService:TeleportToPlaceInstance(PlaceId, jobId, player)
				end
			else
				warn("❌ Invalid JobID")
			end
		end,
	})

	ToolsTab:CreateButton({
		Name = "Copy Current JobID",
		Callback = function()
			setclipboard(JobId)
			print("✅ JobID copied to clipboard:", JobId)
		end,
	})

	ToolsTab:CreateButton({
		Name = "Rejoin Server",
		Callback = function()
			local privateId = game.PrivateServerId
			if privateId and privateId ~= "" then
				TeleportService:TeleportToPrivateServer(PlaceId, privateId, {player})
			else
				TeleportService:TeleportToPlaceInstance(PlaceId, JobId, player)
			end
		end,
	})

	ToolsTab:CreateButton({
	Name = "Server Hop",
	Callback = function()
		local HttpService = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")
		local Players = game:GetService("Players")
		local player = Players.LocalPlayer
		local PlaceId = game.PlaceId
		local JobId = game.JobId

		-- Notify: Finding Server
		local statusNotify = Rayfield:Notify({
			Title = "🔍 Finding Server...",
			Content = "Searching for a suitable server.",
			Duration = 5,
		})

		-- Step 1: Get last page cursor
		local function getLastCursor()
			local cursor = ""
			local lastCursor = ""
			local attempts = 0

			repeat
				local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
				local success, result = pcall(function()
					return HttpService:JSONDecode(game:HttpGet(url))
				end)

				if success and result then
					cursor = result.nextPageCursor or ""
					if cursor and cursor ~= "" then
						lastCursor = cursor
					end
				else
					break
				end

				attempts += 1
				task.wait(0.1)
			until cursor == "" or attempts >= 10

			return lastCursor
		end

		-- Step 2: Load servers
		local function getServers(cursor)
			local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
			local success, result = pcall(function()
				return HttpService:JSONDecode(game:HttpGet(url))
			end)

			local servers = {}
			if success and result and result.data then
				for _, server in ipairs(result.data) do
					if server.id ~= JobId and server.playing > 0 and server.playing < server.maxPlayers then
						table.insert(servers, server)
					end
				end
			end
			return servers
		end

		local lastCursor = getLastCursor()
		local servers = getServers(lastCursor)

		if #servers == 0 then
			Rayfield:Notify({
				Title = "❌ No Servers Found",
				Content = "All servers are full or unavailable.",
				Duration = 4
			})
			return
		end

		-- Pick random server
		local picked = servers[math.random(1, #servers)]

		-- Step 3: Notify found server
		Rayfield:Notify({
			Title = "✅ Server Found",
			Content = "Found server with " .. picked.playing .. " players. Joining in 3s...",
			Duration = 3,
		})

		-- Wait and teleport
		task.wait(3)
		TeleportService:TeleportToPlaceInstance(PlaceId, picked.id, player)
	end,
})


	-- Character Section
	ToolsTab:CreateParagraph({
		Title = "🧍 CHARACTER SECTION",
		Content = "Customize speed, jump, and more!"
	})

	ToolsTab:CreateInput({
		Name = "Walk Speed",
		PlaceholderText = "Default is 16",
		RemoveTextAfterFocusLost = false,
		Callback = function(val)
			local speed = tonumber(val)
			if speed then
				humanoid.WalkSpeed = speed
			end
		end,
	})

	ToolsTab:CreateInput({
		Name = "Jump Power",
		PlaceholderText = "Default is 50",
		RemoveTextAfterFocusLost = false,
		Callback = function(val)
			local power = tonumber(val)
			if power then
				humanoid.JumpPower = power
			end
		end,
	})

	-- Fly
	local flying = false
	local flyConn
	ToolsTab:CreateToggle({
		Name = "Fly",
		CurrentValue = false,
		Callback = function(state)
			flying = state
			if state then
				local hrp = char:WaitForChild("HumanoidRootPart")
				local bg = Instance.new("BodyGyro", hrp)
				local bv = Instance.new("BodyVelocity", hrp)

				bg.P = 9e4
				bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
				bg.CFrame = hrp.CFrame

				bv.Velocity = Vector3.new(0, 0, 0)
				bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

				flyConn = game:GetService("RunService").Heartbeat:Connect(function()
					local moveDir = humanoid.MoveDirection
					bv.Velocity = moveDir * 60
					bg.CFrame = hrp.CFrame
				end)
			else
				if flyConn then flyConn:Disconnect() end
				for _, v in ipairs(char:FindFirstChild("HumanoidRootPart"):GetChildren()) do
					if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
				end
			end
		end,
	})

	-- Anti-AFK
	ToolsTab:CreateToggle({
		Name = "Anti-AFK",
		CurrentValue = false,
		Callback = function(state)
			if state then
				local vu = game:GetService("VirtualUser")
				player.Idled:Connect(function()
					vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
					wait(1)
					vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				end)
			end
		end,
	})

	-- Auto Reconnect
	ToolsTab:CreateToggle({
		Name = "Auto Reconnect",
		CurrentValue = false,
		Callback = function(state)
			if state then
				game:GetService("CoreGui").RobloxPromptGui.DescendantAdded:Connect(function(descendant)
					if descendant.Name == "ErrorMessage" then
						wait(2)
						TeleportService:Teleport(PlaceId, player)
					end
				end)
			end
		end,
	})

	-- Infinite Jump
	ToolsTab:CreateToggle({
		Name = "Infinite Jump",
		CurrentValue = false,
		Callback = function(state)
			if state then
				UserInputService.JumpRequest:Connect(function()
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end
		end,
	})

	-- No Clip
	local noclipEnabled = false
	local noclipConn
	ToolsTab:CreateToggle({
		Name = "No Clip",
		CurrentValue = false,
		Callback = function(state)
			noclipEnabled = state
			local function Noclip()
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") and v.CanCollide == true then
						v.CanCollide = false
					end
				end
			end

			if state then
				noclipConn = game:GetService("RunService").Stepped:Connect(Noclip)
			else
				if noclipConn then noclipConn:Disconnect() end
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = true
					end
				end
			end
		end,
	})

	ToolsTab:CreateParagraph({
		Title = "OTHER OPTION",
		Content = "Destroy GUI"
	})

	ToolsTab:CreateButton({
		Name = "🗑️ Destroy GUI",
		Callback = function()
			local jumping = false
			local connection

			Rayfield:Notify({
				Title = "Confirm Destruction",
				Content = "Press Jump (Spacebar) to confirm GUI removal.",
				Duration = 999, -- lasts until action is taken
				Actions = {
					Cancel = {
						Name = "Cancel",
						Callback = function()
							if connection then connection:Disconnect() end
							print("❎ GUI destruction canceled.")
						end,
					}
				},
			})

			-- Listen for jump
			connection = game:GetService("UserInputService").JumpRequest:Connect(function()
				-- Disconnect listener
				if connection then connection:Disconnect() end

				-- Disconnect connections
				if flyConn then flyConn:Disconnect() end
				if noclipConn then noclipConn:Disconnect() end

				-- Destroy GUI
				for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
					if v.Name:lower():find("rayfield") then
						v:Destroy()
					end
				end

				print("✅ GUI destroyed via jump confirmation.")
			end)
		end,
	})




	local ScriptTab = Window:CreateTab("📜 Script Hub", 0)

	ScriptTab:CreateParagraph({
		Title = "📜 Script Hub",
		Content = "First Easy Access Scripts Without Finding them!"
	})

	ScriptTab:CreateButton({
		Name = "NoLag (KEY NEEDED)",
		Callback = function()loadstring(game:HttpGet("https://pastefy.app/vtPTiwXW/raw"))()
			
		end,
	})

	ScriptTab:CreateButton({
		Name = "SpeedHubX (Best for Shovelling Sprinkler)",
		Callback = function()
			loadstring(game:HttpGet("https://pastefy.app/WoOK6eg3/raw"))()
		end,
	})

	ScriptTab:CreateButton({
		Name = "NatHub Freemium (KEY NEEDED)",
		Callback = function()
			loadstring(game:HttpGet("https://pastefy.app/tRfi3OBz/raw"))()
		end,
	})		

	ScriptTab:CreateButton({
		Name = "LimitHub Freemium (KEY NEEDED)",
		Callback = function()
			
loadstring(game:HttpGet("https://pastefy.app/mS6aJLfY/raw"))()
		end,
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

	SocialTab:CreateButton({
		Name = "Yura Community Discord",
		Callback = function()
			setclipboard("https://discord.gg/gpR7YQjnFt")
			print("✅ Discord invite copied to clipboard!")
		end,
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
