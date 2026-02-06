local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ArcadeConfig = require(ReplicatedStorage:WaitForChild("ArcadeConfig"))
local remotes = ReplicatedStorage:WaitForChild("ArcadeRemotes")
local arcadeMessage = remotes:WaitForChild("ArcadeMessage")
local openAvatarBooth = remotes:WaitForChild("OpenAvatarBooth")
local applyAvatarPreset = remotes:WaitForChild("ApplyAvatarPreset")
local adminCommand = remotes:WaitForChild("AdminCommand")
local arcadePolishEvent = remotes:WaitForChild("ArcadePolishEvent")

local rarityColors = {
	Common = Color3.fromRGB(220, 220, 220),
	Rare = Color3.fromRGB(102, 204, 255),
	Epic = Color3.fromRGB(255, 110, 255),
	Legendary = Color3.fromRGB(255, 220, 110),
}

local gui = Instance.new("ScreenGui")
gui.Name = "ArcadeHud"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.Size = UDim2.fromScale(0.6, 0.075)
toast.Position = UDim2.fromScale(0.2, 0.04)
toast.BackgroundColor3 = Color3.fromRGB(12, 12, 30)
toast.BackgroundTransparency = 0.2
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.TextStrokeTransparency = 0.5
toast.TextScaled = true
toast.Font = Enum.Font.FredokaOne
toast.Visible = false
toast.Parent = gui

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 10)
toastCorner.Parent = toast

local rareWinFlash = Instance.new("Frame")
rareWinFlash.Size = UDim2.fromScale(1, 1)
rareWinFlash.Position = UDim2.fromScale(0, 0)
rareWinFlash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rareWinFlash.BackgroundTransparency = 1
rareWinFlash.Visible = false
rareWinFlash.ZIndex = 99
rareWinFlash.Parent = gui

local inventoryFrame = Instance.new("Frame")
inventoryFrame.Name = "InventoryFrame"
inventoryFrame.Size = UDim2.fromScale(0.27, 0.42)
inventoryFrame.Position = UDim2.fromScale(0.02, 0.03)
inventoryFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 40)
inventoryFrame.BackgroundTransparency = 0.15
inventoryFrame.Parent = gui

local inventoryCorner = Instance.new("UICorner")
inventoryCorner.CornerRadius = UDim.new(0, 10)
inventoryCorner.Parent = inventoryFrame

local inventoryTitle = Instance.new("TextLabel")
inventoryTitle.Size = UDim2.fromScale(1, 0.14)
inventoryTitle.BackgroundTransparency = 1
inventoryTitle.Text = "Arcade Inventory"
inventoryTitle.TextColor3 = Color3.fromRGB(255, 199, 103)
inventoryTitle.TextScaled = true
inventoryTitle.Font = Enum.Font.FredokaOne
inventoryTitle.Parent = inventoryFrame

local inventoryText = Instance.new("TextLabel")
inventoryText.Size = UDim2.fromScale(0.94, 0.84)
inventoryText.Position = UDim2.fromScale(0.03, 0.14)
inventoryText.BackgroundTransparency = 1
inventoryText.TextXAlignment = Enum.TextXAlignment.Left
inventoryText.TextYAlignment = Enum.TextYAlignment.Top
inventoryText.TextWrapped = true
inventoryText.TextScaled = false
inventoryText.TextSize = 17
inventoryText.Font = Enum.Font.GothamSemibold
inventoryText.TextColor3 = Color3.fromRGB(232, 235, 255)
inventoryText.Text = ""
inventoryText.Parent = inventoryFrame

local avatarFrame = Instance.new("Frame")
avatarFrame.Name = "AvatarFrame"
avatarFrame.Size = UDim2.fromScale(0.36, 0.42)
avatarFrame.Position = UDim2.fromScale(0.32, 0.28)
avatarFrame.BackgroundColor3 = Color3.fromRGB(26, 10, 45)
avatarFrame.BackgroundTransparency = 0.1
avatarFrame.Visible = false
avatarFrame.Parent = gui

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 12)
avatarCorner.Parent = avatarFrame

local avatarTitle = Instance.new("TextLabel")
avatarTitle.Size = UDim2.fromScale(0.8, 0.16)
avatarTitle.Position = UDim2.fromScale(0.1, 0.02)
avatarTitle.BackgroundTransparency = 1
avatarTitle.Text = "Style Station"
avatarTitle.Font = Enum.Font.FredokaOne
avatarTitle.TextScaled = true
avatarTitle.TextColor3 = Color3.fromRGB(255, 184, 254)
avatarTitle.Parent = avatarFrame

local avatarSubtitle = Instance.new("TextLabel")
avatarSubtitle.Size = UDim2.fromScale(0.9, 0.12)
avatarSubtitle.Position = UDim2.fromScale(0.05, 0.15)
avatarSubtitle.BackgroundTransparency = 1
avatarSubtitle.Text = "Choose your K-pop arcade look:"
avatarSubtitle.Font = Enum.Font.GothamBold
avatarSubtitle.TextScaled = true
avatarSubtitle.TextColor3 = Color3.fromRGB(228, 238, 255)
avatarSubtitle.Parent = avatarFrame

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.fromScale(0.92, 0.56)
buttonContainer.Position = UDim2.fromScale(0.04, 0.28)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = avatarFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = buttonContainer

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromScale(0.34, 0.14)
closeButton.Position = UDim2.fromScale(0.33, 0.84)
closeButton.Text = "Close"
closeButton.Font = Enum.Font.FredokaOne
closeButton.TextScaled = true
closeButton.TextColor3 = Color3.fromRGB(255, 235, 235)
closeButton.BackgroundColor3 = Color3.fromRGB(90, 44, 132)
closeButton.Parent = avatarFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local adminToggle = Instance.new("TextButton")
adminToggle.Name = "AdminToggle"
adminToggle.Size = UDim2.fromScale(0.1, 0.052)
adminToggle.Position = UDim2.fromScale(0.88, 0.03)
adminToggle.Text = "ADMIN"
adminToggle.Font = Enum.Font.FredokaOne
adminToggle.TextScaled = true
adminToggle.TextColor3 = Color3.fromRGB(255, 240, 240)
adminToggle.BackgroundColor3 = Color3.fromRGB(94, 29, 38)
adminToggle.Visible = false
adminToggle.Parent = gui

local adminToggleCorner = Instance.new("UICorner")
adminToggleCorner.CornerRadius = UDim.new(0, 8)
adminToggleCorner.Parent = adminToggle

local adminFrame = Instance.new("Frame")
adminFrame.Name = "AdminFrame"
adminFrame.Size = UDim2.fromScale(0.28, 0.48)
adminFrame.Position = UDim2.fromScale(0.7, 0.11)
adminFrame.BackgroundColor3 = Color3.fromRGB(28, 14, 24)
adminFrame.BackgroundTransparency = 0.08
adminFrame.Visible = false
adminFrame.Parent = gui

local adminCorner = Instance.new("UICorner")
adminCorner.CornerRadius = UDim.new(0, 10)
adminCorner.Parent = adminFrame

local adminTitle = Instance.new("TextLabel")
adminTitle.Size = UDim2.fromScale(1, 0.12)
adminTitle.BackgroundTransparency = 1
adminTitle.Text = "Arcade Admin"
adminTitle.TextScaled = true
adminTitle.Font = Enum.Font.FredokaOne
adminTitle.TextColor3 = Color3.fromRGB(255, 184, 184)
adminTitle.Parent = adminFrame

local adminStatus = Instance.new("TextLabel")
adminStatus.Size = UDim2.fromScale(0.94, 0.12)
adminStatus.Position = UDim2.fromScale(0.03, 0.12)
adminStatus.BackgroundTransparency = 1
adminStatus.TextXAlignment = Enum.TextXAlignment.Left
adminStatus.TextScaled = true
adminStatus.Font = Enum.Font.GothamSemibold
adminStatus.TextColor3 = Color3.fromRGB(238, 234, 255)
adminStatus.Text = "Status: loading"
adminStatus.Parent = adminFrame

local adminButtonContainer = Instance.new("Frame")
adminButtonContainer.Size = UDim2.fromScale(0.94, 0.68)
adminButtonContainer.Position = UDim2.fromScale(0.03, 0.24)
adminButtonContainer.BackgroundTransparency = 1
adminButtonContainer.Parent = adminFrame

local adminLayout = Instance.new("UIListLayout")
adminLayout.Padding = UDim.new(0, 7)
adminLayout.Parent = adminButtonContainer

local function makeAdminButton(text, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 34)
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(248, 239, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.Parent = adminButtonContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button
	return button
end

local btnGrantCoins = makeAdminButton("+100 Coins", Color3.fromRGB(46, 93, 58))
local btnRemoveCoins = makeAdminButton("-100 Coins", Color3.fromRGB(94, 63, 36))
local btnResetInventory = makeAdminButton("Reset My Inventory", Color3.fromRGB(99, 43, 55))
local btnPetsCostDown = makeAdminButton("Pets Cost -5", Color3.fromRGB(29, 88, 99))
local btnPetsCostUp = makeAdminButton("Pets Cost +5", Color3.fromRGB(29, 88, 99))
local btnPlushCostDown = makeAdminButton("Plushies Cost -5", Color3.fromRGB(86, 53, 115))
local btnPlushCostUp = makeAdminButton("Plushies Cost +5", Color3.fromRGB(86, 53, 115))
local btnLegendaryBoost = makeAdminButton("Legendary Odds Boost", Color3.fromRGB(123, 90, 30))
local btnRestoreDefaults = makeAdminButton("Restore Defaults", Color3.fromRGB(61, 61, 78))

local toastTweenIn = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local toastTweenOut = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local flashTweenIn = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local flashTweenOut = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local rareWinSound = Instance.new("Sound")
rareWinSound.Name = "RareWinSound"
rareWinSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
rareWinSound.Volume = 0.55
rareWinSound.Parent = gui

local activeToastId = 0
local cachedMachineState = nil

local function showToast(text, color)
	activeToastId += 1
	local toastId = activeToastId

	toast.Visible = true
	toast.TextTransparency = 1
	toast.BackgroundTransparency = 0.6
	toast.Text = text
	toast.TextColor3 = color or Color3.fromRGB(255, 255, 255)

	TweenService:Create(toast, toastTweenIn, {
		TextTransparency = 0,
		BackgroundTransparency = 0.2,
	}):Play()

	task.delay(2.8, function()
		if toastId ~= activeToastId then
			return
		end
		local fadeOut = TweenService:Create(toast, toastTweenOut, {
			TextTransparency = 1,
			BackgroundTransparency = 0.7,
		})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		if toastId == activeToastId then
			toast.Visible = false
		end
	end)
end

local function showRareWinFlash(rarity)
	local color = rarityColors[rarity] or Color3.fromRGB(255, 255, 255)
	rareWinFlash.BackgroundColor3 = color
	rareWinFlash.BackgroundTransparency = 1
	rareWinFlash.Visible = true

	TweenService:Create(rareWinFlash, flashTweenIn, {
		BackgroundTransparency = 0.72,
	}):Play()

	task.delay(0.12, function()
		local fadeOut = TweenService:Create(rareWinFlash, flashTweenOut, {
			BackgroundTransparency = 1,
		})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		rareWinFlash.Visible = false
	end)

	rareWinSound.PlaybackSpeed = rarity == "Legendary" and 1.3 or 1.0
	rareWinSound:Play()
end

local function collectFolderItems(folder)
	local lines = {}
	if not folder then
		return "None yet"
	end

	for _, item in ipairs(folder:GetChildren()) do
		if item:IsA("IntValue") and item.Value > 0 then
			table.insert(lines, string.format("- %s x%d", item.Name, item.Value))
		end
	end

	table.sort(lines)
	if #lines == 0 then
		return "None yet"
	end

	return table.concat(lines, "\n")
end

local function updateInventoryPanel()
	local leaderstats = player:FindFirstChild("leaderstats")
	local inventory = player:FindFirstChild("Inventory")
	local companions = player:FindFirstChild("Companions")

	local coinsValue = 0
	local kamLevel = 0
	local kamFriendship = 0
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coinsValue = coins.Value
		end
	end
	if companions then
		local levelValue = companions:FindFirstChild("KamLevel")
		local friendshipValue = companions:FindFirstChild("KamFriendship")
		if levelValue then
			kamLevel = levelValue.Value
		end
		if friendshipValue then
			kamFriendship = friendshipValue.Value
		end
	end

	local petsText = collectFolderItems(inventory and inventory:FindFirstChild("Pets"))
	local plushiesText = collectFolderItems(inventory and inventory:FindFirstChild("Plushies"))

	inventoryText.Text = string.format(
		"Coins: %d\nKam: Lv%d (%d pts)\n\nPets:\n%s\n\nPlushies:\n%s",
		coinsValue,
		kamLevel,
		kamFriendship,
		petsText,
		plushiesText
	)
end

local function connectValueListeners(folder)
	if not folder then
		return
	end

	local function connectValueObject(valueObject)
		if valueObject:IsA("IntValue") then
			valueObject.Changed:Connect(updateInventoryPanel)
		end
	end

	for _, child in ipairs(folder:GetChildren()) do
		connectValueObject(child)
	end

	folder.ChildAdded:Connect(function(child)
		connectValueObject(child)
		updateInventoryPanel()
	end)

	folder.ChildRemoved:Connect(updateInventoryPanel)
end

local function refreshInventoryConnections()
	local leaderstats = player:WaitForChild("leaderstats", 20)
	local inventory = player:WaitForChild("Inventory", 20)
	local companions = player:WaitForChild("Companions", 20)
	if not leaderstats or not inventory then
		return
	end

	local coins = leaderstats:FindFirstChild("Coins")
	if coins then
		coins.Changed:Connect(updateInventoryPanel)
	end

	local pets = inventory:FindFirstChild("Pets")
	local plushies = inventory:FindFirstChild("Plushies")
	connectValueListeners(pets)
	connectValueListeners(plushies)
	connectValueListeners(companions)
	updateInventoryPanel()
end

local function callAdmin(command, payload)
	local ok, success, result = pcall(function()
		return adminCommand:InvokeServer(command, payload)
	end)
	if not ok then
		return false, "Admin call network error."
	end

	if not success then
		return false, tostring(result)
	end

	return true, result
end

local function refreshAdminStatus()
	local success, result = callAdmin("GetStatus", {})
	if not success then
		adminToggle.Visible = false
		adminFrame.Visible = false
		return
	end

	adminToggle.Visible = true
	if type(result) == "table" and type(result.Machines) == "table" then
		cachedMachineState = result.Machines
		local petsCost = result.Machines.Pets and result.Machines.Pets.Cost or 0
		local plushiesCost = result.Machines.Plushies and result.Machines.Plushies.Cost or 0
		adminStatus.Text = string.format("Pets: %d | Plushies: %d", petsCost, plushiesCost)
	else
		adminStatus.Text = "Status: no machine data"
	end
end

local function adjustMachineCost(machineType, delta)
	if not cachedMachineState or not cachedMachineState[machineType] then
		refreshAdminStatus()
	end
	local current = cachedMachineState and cachedMachineState[machineType] and cachedMachineState[machineType].Cost or 25
	local target = math.max(1, current + delta)
	local success, result = callAdmin("SetMachineCost", {
		MachineType = machineType,
		Cost = target,
	})
	if success then
		showToast(result, Color3.fromRGB(190, 255, 214))
		refreshAdminStatus()
	else
		showToast(result, Color3.fromRGB(255, 150, 150))
	end
end

local function boostLegendaryWeights()
	if not cachedMachineState then
		refreshAdminStatus()
	end
	if not cachedMachineState then
		showToast("No machine data available.", Color3.fromRGB(255, 150, 150))
		return
	end

	local failures = 0
	for machineType, machineData in pairs(cachedMachineState) do
		if type(machineData) == "table" and type(machineData.Rewards) == "table" then
			for _, reward in ipairs(machineData.Rewards) do
				if reward.Rarity == "Legendary" then
					local success = callAdmin("SetRewardWeight", {
						MachineType = machineType,
						RewardName = reward.Name,
						Weight = 14,
					})
					if not success then
						failures += 1
					end
				end
			end
		end
	end

	if failures == 0 then
		showToast("Legendary odds boosted.", Color3.fromRGB(255, 225, 130))
	else
		showToast("Some legendary odds failed to update.", Color3.fromRGB(255, 150, 150))
	end

	refreshAdminStatus()
end

btnGrantCoins.MouseButton1Click:Connect(function()
	local success, result = callAdmin("GrantCoins", { Amount = 100 })
	if success then
		showToast(result, Color3.fromRGB(190, 255, 214))
	else
		showToast(result, Color3.fromRGB(255, 150, 150))
	end
end)

btnRemoveCoins.MouseButton1Click:Connect(function()
	local success, result = callAdmin("GrantCoins", { Amount = -100 })
	if success then
		showToast(result, Color3.fromRGB(255, 211, 166))
	else
		showToast(result, Color3.fromRGB(255, 150, 150))
	end
end)

btnResetInventory.MouseButton1Click:Connect(function()
	local success, result = callAdmin("ResetInventory", {})
	if success then
		showToast(result, Color3.fromRGB(255, 211, 190))
		updateInventoryPanel()
	else
		showToast(result, Color3.fromRGB(255, 150, 150))
	end
end)

btnPetsCostDown.MouseButton1Click:Connect(function()
	adjustMachineCost("Pets", -5)
end)

btnPetsCostUp.MouseButton1Click:Connect(function()
	adjustMachineCost("Pets", 5)
end)

btnPlushCostDown.MouseButton1Click:Connect(function()
	adjustMachineCost("Plushies", -5)
end)

btnPlushCostUp.MouseButton1Click:Connect(function()
	adjustMachineCost("Plushies", 5)
end)

btnLegendaryBoost.MouseButton1Click:Connect(function()
	boostLegendaryWeights()
end)

btnRestoreDefaults.MouseButton1Click:Connect(function()
	local success, result = callAdmin("RestoreDefaults", {})
	if success then
		showToast(result, Color3.fromRGB(220, 220, 255))
		refreshAdminStatus()
	else
		showToast(result, Color3.fromRGB(255, 150, 150))
	end
end)

adminToggle.MouseButton1Click:Connect(function()
	adminFrame.Visible = not adminFrame.Visible
	if adminFrame.Visible then
		refreshAdminStatus()
	end
end)

for _, preset in ipairs(ArcadeConfig.AvatarPresets) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 46)
	button.BackgroundColor3 = Color3.fromRGB(72, 31, 122)
	button.TextColor3 = Color3.fromRGB(248, 239, 255)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Text = preset.DisplayName
	button.Parent = buttonContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		local ok, success, message = pcall(function()
			return applyAvatarPreset:InvokeServer(preset.Key)
		end)
		if not ok then
			showToast("Avatar update failed (network error).", Color3.fromRGB(255, 140, 140))
			return
		end

		if success then
			showToast("Look applied: " .. preset.DisplayName, Color3.fromRGB(158, 255, 196))
		else
			showToast("Could not apply: " .. tostring(message), Color3.fromRGB(255, 140, 140))
		end
	end)
end

closeButton.MouseButton1Click:Connect(function()
	avatarFrame.Visible = false
end)

openAvatarBooth.OnClientEvent:Connect(function()
	avatarFrame.Visible = true
	showToast("Style Station opened.", Color3.fromRGB(255, 201, 255))
end)

arcadePolishEvent.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	if payload.Kind ~= "RareWin" then
		return
	end

	showRareWinFlash(payload.Rarity)
	local winnerText = payload.Winner ~= "" and payload.Winner or "Someone"
	local machineType = payload.MachineType or "Arcade"
	local rarity = payload.Rarity or "Rare"
	showToast(string.format("%s hit a %s at %s!", winnerText, rarity, machineType), rarityColors[rarity] or Color3.fromRGB(255, 255, 255))
end)

arcadeMessage.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	if payload.Kind == "SpinResult" then
		local color = rarityColors[payload.Rarity] or Color3.fromRGB(255, 255, 255)
		showToast(payload.Text or "Prize won!", color)
	elseif payload.Kind == "KamLevelUp" then
		showToast(payload.Text or "Kam leveled up!", Color3.fromRGB(255, 222, 144))
	elseif payload.Kind == "KamTrick" then
		showToast(payload.Text or "Kam did a trick!", Color3.fromRGB(189, 238, 255))
	elseif payload.Kind == "Error" then
		showToast(payload.Text or "Something went wrong.", Color3.fromRGB(255, 130, 130))
	else
		showToast(payload.Text or "Arcade update.", Color3.fromRGB(236, 236, 255))
	end

	updateInventoryPanel()
end)

refreshInventoryConnections()
refreshAdminStatus()
