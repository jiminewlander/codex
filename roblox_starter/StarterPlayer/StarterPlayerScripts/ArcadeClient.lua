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

local inventoryFrame = Instance.new("Frame")
inventoryFrame.Name = "InventoryFrame"
inventoryFrame.Size = UDim2.fromScale(0.27, 0.36)
inventoryFrame.Position = UDim2.fromScale(0.02, 0.03)
inventoryFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 40)
inventoryFrame.BackgroundTransparency = 0.15
inventoryFrame.Parent = gui

local inventoryCorner = Instance.new("UICorner")
inventoryCorner.CornerRadius = UDim.new(0, 10)
inventoryCorner.Parent = inventoryFrame

local inventoryTitle = Instance.new("TextLabel")
inventoryTitle.Size = UDim2.fromScale(1, 0.16)
inventoryTitle.BackgroundTransparency = 1
inventoryTitle.Text = "Arcade Inventory"
inventoryTitle.TextColor3 = Color3.fromRGB(255, 199, 103)
inventoryTitle.TextScaled = true
inventoryTitle.Font = Enum.Font.FredokaOne
inventoryTitle.Parent = inventoryFrame

local inventoryText = Instance.new("TextLabel")
inventoryText.Size = UDim2.fromScale(0.94, 0.8)
inventoryText.Position = UDim2.fromScale(0.03, 0.17)
inventoryText.BackgroundTransparency = 1
inventoryText.TextXAlignment = Enum.TextXAlignment.Left
inventoryText.TextYAlignment = Enum.TextYAlignment.Top
inventoryText.TextWrapped = true
inventoryText.TextScaled = false
inventoryText.TextSize = 18
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

local toastTweenIn = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local toastTweenOut = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local activeToastId = 0
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

	local coinsValue = 0
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			coinsValue = coins.Value
		end
	end

	local petsText = collectFolderItems(inventory and inventory:FindFirstChild("Pets"))
	local plushiesText = collectFolderItems(inventory and inventory:FindFirstChild("Plushies"))

	inventoryText.Text = string.format("Coins: %d\n\nPets:\n%s\n\nPlushies:\n%s", coinsValue, petsText, plushiesText)
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
	updateInventoryPanel()
end

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

arcadeMessage.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	if payload.Kind == "SpinResult" then
		local color = rarityColors[payload.Rarity] or Color3.fromRGB(255, 255, 255)
		showToast(payload.Text or "Prize won!", color)
	elseif payload.Kind == "Error" then
		showToast(payload.Text or "Something went wrong.", Color3.fromRGB(255, 130, 130))
	else
		showToast(payload.Text or "Arcade update.", Color3.fromRGB(236, 236, 255))
	end

	updateInventoryPanel()
end)

refreshInventoryConnections()
