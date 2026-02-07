local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local AvatarConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("AvatarConfig"))
local remotes = ReplicatedStorage:WaitForChild("ArcadeRemotes")
local requestEvent = remotes:WaitForChild(AvatarConfig.RequestEventName)
local resultEvent = remotes:WaitForChild(AvatarConfig.ResultEventName)
local prizeWonEvent = remotes:WaitForChild("PrizeWon")

local screenGui = script.Parent
if not screenGui:IsA("ScreenGui") then
	return
end

screenGui.Name = "AvatarCustomizerGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local rootFrame = Instance.new("Frame")
rootFrame.Name = "RootFrame"
rootFrame.Size = UDim2.fromScale(0.32, 0.44)
rootFrame.Position = UDim2.fromScale(0.34, 0.3)
rootFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 32)
rootFrame.BackgroundTransparency = 0.08
rootFrame.Visible = false
rootFrame.Parent = screenGui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 12)
rootCorner.Parent = rootFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.16)
title.BackgroundTransparency = 1
title.Text = "Mirror Station"
title.Font = Enum.Font.FredokaOne
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 132, 196)
title.Parent = rootFrame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromScale(0.94, 0.12)
subtitle.Position = UDim2.fromScale(0.03, 0.14)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Pick a style button to cycle options"
subtitle.Font = Enum.Font.GothamBold
subtitle.TextScaled = true
subtitle.TextColor3 = Color3.fromRGB(189, 244, 255)
subtitle.Parent = rootFrame

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.fromScale(0.9, 0.44)
buttonContainer.Position = UDim2.fromScale(0.05, 0.28)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = rootFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Parent = buttonContainer

for _, category in ipairs(AvatarConfig.Order) do
	local categoryInfo = AvatarConfig.Categories[category]
	local button = Instance.new("TextButton")
	button.Name = category .. "Button"
	button.Size = UDim2.new(1, 0, 0, 42)
	button.BackgroundColor3 = Color3.fromRGB(58, 40, 86)
	button.TextColor3 = Color3.fromRGB(232, 247, 255)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.Text = categoryInfo.ButtonText
	button.Parent = buttonContainer

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button

	button.Activated:Connect(function()
		requestEvent:FireServer(category)
	end)
end

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromScale(0.36, 0.12)
closeButton.Position = UDim2.fromScale(0.32, 0.84)
closeButton.BackgroundColor3 = Color3.fromRGB(82, 44, 120)
closeButton.TextColor3 = Color3.fromRGB(255, 241, 251)
closeButton.Font = Enum.Font.FredokaOne
closeButton.TextScaled = true
closeButton.Text = "Close"
closeButton.Parent = rootFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local inventoryLabel = Instance.new("TextLabel")
inventoryLabel.Size = UDim2.fromScale(0.9, 0.12)
inventoryLabel.Position = UDim2.fromScale(0.05, 0.72)
inventoryLabel.BackgroundTransparency = 1
inventoryLabel.TextXAlignment = Enum.TextXAlignment.Left
inventoryLabel.TextScaled = true
inventoryLabel.Font = Enum.Font.GothamSemibold
inventoryLabel.TextColor3 = Color3.fromRGB(255, 236, 153)
inventoryLabel.Text = "Prizes: none yet"
inventoryLabel.Parent = rootFrame

local toast = Instance.new("TextLabel")
toast.Size = UDim2.fromScale(0.4, 0.07)
toast.Position = UDim2.fromScale(0.3, 0.05)
toast.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
toast.BackgroundTransparency = 0.22
toast.TextColor3 = Color3.fromRGB(242, 247, 255)
toast.TextScaled = true
toast.Font = Enum.Font.FredokaOne
toast.Visible = false
toast.Parent = screenGui

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 8)
toastCorner.Parent = toast

local toastId = 0
local function showToast(text, color)
	toastId += 1
	local currentId = toastId

	toast.Text = text
	toast.TextColor3 = color or Color3.fromRGB(242, 247, 255)
	toast.TextTransparency = 1
	toast.BackgroundTransparency = 0.65
	toast.Visible = true

	TweenService:Create(toast, TweenInfo.new(0.2), {
		TextTransparency = 0,
		BackgroundTransparency = 0.22,
	}):Play()

	task.delay(2.5, function()
		if currentId ~= toastId then
			return
		end
		local fade = TweenService:Create(toast, TweenInfo.new(0.25), {
			TextTransparency = 1,
			BackgroundTransparency = 0.7,
		})
		fade:Play()
		fade.Completed:Wait()
		if currentId == toastId then
			toast.Visible = false
		end
	end)
end

local function updateInventoryLabel()
	local inventory = player:FindFirstChild("PrizeInventory")
	if not inventory then
		inventoryLabel.Text = "Prizes: none yet"
		return
	end

	local total = 0
	for _, child in ipairs(inventory:GetChildren()) do
		if child:IsA("IntValue") then
			total += child.Value
		end
	end

	if total == 0 then
		inventoryLabel.Text = "Prizes: none yet"
	else
		inventoryLabel.Text = "Prizes won: " .. tostring(total)
	end
end

local function hookInventorySignals()
	local inventory = player:FindFirstChild("PrizeInventory")
	if not inventory then
		return
	end

	inventory.ChildAdded:Connect(updateInventoryLabel)
	inventory.ChildRemoved:Connect(updateInventoryLabel)

	for _, child in ipairs(inventory:GetChildren()) do
		if child:IsA("IntValue") then
			child.Changed:Connect(updateInventoryLabel)
		end
	end
end

if player:FindFirstChild("PrizeInventory") then
	hookInventorySignals()
else
	player.ChildAdded:Connect(function(child)
		if child.Name == "PrizeInventory" then
			hookInventorySignals()
			updateInventoryLabel()
		end
	end)
end

updateInventoryLabel()

closeButton.Activated:Connect(function()
	rootFrame.Visible = false
end)

resultEvent.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	showToast(payload.Text or "Avatar updated", Color3.fromRGB(186, 255, 212))
end)

prizeWonEvent.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	local rarity = payload.Rarity or "Common"
	local rarityColor = Color3.fromRGB(240, 245, 255)
	if rarity == "Rare" then
		rarityColor = Color3.fromRGB(133, 214, 255)
	elseif rarity == "Epic" then
		rarityColor = Color3.fromRGB(255, 150, 255)
	elseif rarity == "Legendary" then
		rarityColor = Color3.fromRGB(255, 229, 120)
	end

	showToast(payload.Text or "Prize won!", rarityColor)
	updateInventoryLabel()
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, triggeredPlayer)
	if triggeredPlayer ~= player then
		return
	end

	if prompt.Name == "MirrorPrompt" then
		rootFrame.Visible = true
	end
end)
