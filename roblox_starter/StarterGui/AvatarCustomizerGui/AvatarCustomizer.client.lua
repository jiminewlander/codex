local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local AvatarConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("AvatarConfig"))
local MirrorAIConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MirrorAIConfig"))

local remotes = ReplicatedStorage:WaitForChild("ArcadeRemotes")
local avatarRequestEvent = remotes:WaitForChild(AvatarConfig.RequestEventName)
local avatarResultEvent = remotes:WaitForChild(AvatarConfig.ResultEventName)
local prizeWonEvent = remotes:WaitForChild("PrizeWon")
local mirrorRequestEvent = remotes:WaitForChild(MirrorAIConfig.RequestEventName)
local mirrorResponseEvent = remotes:WaitForChild(MirrorAIConfig.ResponseEventName)

local screenGui = script.Parent
if not screenGui:IsA("ScreenGui") then
	return
end

screenGui.Name = "AvatarCustomizerGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local palette = {
	Pink = Color3.fromRGB(255, 149, 214),
	SoftPink = Color3.fromRGB(255, 216, 238),
	Teal = Color3.fromRGB(120, 244, 255),
	Blue = Color3.fromRGB(125, 187, 255),
	Lilac = Color3.fromRGB(200, 166, 255),
	Cream = Color3.fromRGB(255, 248, 224),
	CandyPurple = Color3.fromRGB(143, 98, 255),
	Ink = Color3.fromRGB(38, 28, 71),
}

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local function addStroke(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Parent = instance
	return stroke
end

local function addGradient(instance, colorA, colorB)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(colorA, colorB)
	gradient.Rotation = 25
	gradient.Parent = instance
	return gradient
end

local function colorToHex(color)
	return string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
end

local backdrop = Instance.new("Frame")
backdrop.Name = "CandyBackdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundTransparency = 1
backdrop.Parent = screenGui

for i = 1, 8 do
	local bubble = Instance.new("Frame")
	bubble.Name = "Bubble" .. tostring(i)
	bubble.Size = UDim2.fromOffset(18 + (i * 6), 18 + (i * 6))
	bubble.Position = UDim2.new((i % 4) * 0.24 + 0.03, 0, ((i + 1) % 4) * 0.2 + 0.05, 0)
	bubble.BackgroundColor3 = (i % 2 == 0) and palette.SoftPink or palette.Teal
	bubble.BackgroundTransparency = 0.78
	bubble.ZIndex = 0
	bubble.Parent = backdrop
	addCorner(bubble, 999)
end

local rootFrame = Instance.new("Frame")
rootFrame.Name = "AvatarFrame"
rootFrame.Size = UDim2.fromScale(0.36, 0.5)
rootFrame.Position = UDim2.fromScale(0.32, 0.25)
rootFrame.BackgroundColor3 = palette.Cream
rootFrame.BackgroundTransparency = 0.05
rootFrame.Visible = false
rootFrame.Parent = screenGui
addCorner(rootFrame, 16)
addStroke(rootFrame, palette.Pink, 2)
addGradient(rootFrame, palette.Cream, palette.SoftPink)

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.15)
title.BackgroundTransparency = 1
title.Text = "Extra Cute Mirror Station"
title.Font = Enum.Font.FredokaOne
title.TextScaled = true
title.TextColor3 = palette.CandyPurple
title.Parent = rootFrame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromScale(0.94, 0.1)
subtitle.Position = UDim2.fromScale(0.03, 0.14)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Tap buttons to cycle styles"
subtitle.Font = Enum.Font.GothamBold
subtitle.TextScaled = true
subtitle.TextColor3 = palette.Ink
subtitle.Parent = rootFrame

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.fromScale(0.9, 0.42)
buttonContainer.Position = UDim2.fromScale(0.05, 0.26)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = rootFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = buttonContainer

local categoryColors = {
	palette.Pink,
	palette.Teal,
	palette.Lilac,
}

for index, category in ipairs(AvatarConfig.Order) do
	local categoryInfo = AvatarConfig.Categories[category]
	local button = Instance.new("TextButton")
	button.Name = category .. "Button"
	button.Size = UDim2.new(1, 0, 0, 46)
	button.BackgroundColor3 = categoryColors[((index - 1) % #categoryColors) + 1]
	button.TextColor3 = palette.Ink
	button.Font = Enum.Font.GothamBlack
	button.TextScaled = true
	button.Text = categoryInfo.ButtonText
	button.Parent = buttonContainer
	addCorner(button, 12)
	addStroke(button, Color3.fromRGB(255, 255, 255), 1)

	button.Activated:Connect(function()
		avatarRequestEvent:FireServer(category)
	end)
end

local inventoryLabel = Instance.new("TextLabel")
inventoryLabel.Size = UDim2.fromScale(0.9, 0.09)
inventoryLabel.Position = UDim2.fromScale(0.05, 0.7)
inventoryLabel.BackgroundTransparency = 1
inventoryLabel.TextXAlignment = Enum.TextXAlignment.Left
inventoryLabel.Font = Enum.Font.GothamBold
inventoryLabel.TextScaled = true
inventoryLabel.TextColor3 = palette.CandyPurple
inventoryLabel.Text = "Prizes: none yet"
inventoryLabel.Parent = rootFrame

local openMirrorAIButton = Instance.new("TextButton")
openMirrorAIButton.Size = UDim2.fromScale(0.45, 0.1)
openMirrorAIButton.Position = UDim2.fromScale(0.05, 0.81)
openMirrorAIButton.BackgroundColor3 = palette.Teal
openMirrorAIButton.TextColor3 = palette.Ink
openMirrorAIButton.Font = Enum.Font.FredokaOne
openMirrorAIButton.TextScaled = true
openMirrorAIButton.Text = "Ask Mirror AI"
openMirrorAIButton.Parent = rootFrame
addCorner(openMirrorAIButton, 10)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromScale(0.45, 0.1)
closeButton.Position = UDim2.fromScale(0.5, 0.81)
closeButton.BackgroundColor3 = palette.Pink
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.FredokaOne
closeButton.TextScaled = true
closeButton.Text = "Close"
closeButton.Parent = rootFrame
addCorner(closeButton, 10)

local mirrorFrame = Instance.new("Frame")
mirrorFrame.Name = "MirrorAIFrame"
mirrorFrame.Size = UDim2.fromScale(0.44, 0.62)
mirrorFrame.Position = UDim2.fromScale(0.28, 0.18)
mirrorFrame.BackgroundColor3 = palette.Cream
mirrorFrame.BackgroundTransparency = 0.03
mirrorFrame.Visible = false
mirrorFrame.Parent = screenGui
addCorner(mirrorFrame, 18)
addStroke(mirrorFrame, palette.Lilac, 2)
addGradient(mirrorFrame, palette.SoftPink, palette.Cream)

local mirrorTitle = Instance.new("TextLabel")
mirrorTitle.Size = UDim2.fromScale(1, 0.12)
mirrorTitle.BackgroundTransparency = 1
mirrorTitle.Text = "Mirror Mirror AI"
mirrorTitle.TextColor3 = palette.CandyPurple
mirrorTitle.Font = Enum.Font.FredokaOne
mirrorTitle.TextScaled = true
mirrorTitle.Parent = mirrorFrame

local mirrorSub = Instance.new("TextLabel")
mirrorSub.Size = UDim2.fromScale(0.94, 0.09)
mirrorSub.Position = UDim2.fromScale(0.03, 0.11)
mirrorSub.BackgroundTransparency = 1
mirrorSub.Text = "Ask for style tips, confidence, or game hints"
mirrorSub.TextColor3 = palette.Ink
mirrorSub.Font = Enum.Font.GothamBold
mirrorSub.TextScaled = true
mirrorSub.Parent = mirrorFrame

local chatScroll = Instance.new("ScrollingFrame")
chatScroll.Size = UDim2.fromScale(0.92, 0.42)
chatScroll.Position = UDim2.fromScale(0.04, 0.2)
chatScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
chatScroll.BackgroundTransparency = 0.15
chatScroll.BorderSizePixel = 0
chatScroll.ScrollBarThickness = 6
chatScroll.CanvasSize = UDim2.fromOffset(0, 0)
chatScroll.Parent = mirrorFrame
addCorner(chatScroll, 12)

local chatLog = Instance.new("TextLabel")
chatLog.Size = UDim2.new(1, -14, 0, 0)
chatLog.Position = UDim2.fromOffset(7, 7)
chatLog.AutomaticSize = Enum.AutomaticSize.Y
chatLog.BackgroundTransparency = 1
chatLog.TextXAlignment = Enum.TextXAlignment.Left
chatLog.TextYAlignment = Enum.TextYAlignment.Top
chatLog.RichText = true
chatLog.TextWrapped = true
chatLog.Font = Enum.Font.GothamSemibold
chatLog.TextSize = 16
chatLog.TextColor3 = palette.Ink
chatLog.Text = ""
chatLog.Parent = chatScroll

local quickRow = Instance.new("Frame")
quickRow.Size = UDim2.fromScale(0.92, 0.24)
quickRow.Position = UDim2.fromScale(0.04, 0.6)
quickRow.BackgroundTransparency = 1
quickRow.Parent = mirrorFrame

local quickLayout = Instance.new("UIGridLayout")
quickLayout.CellSize = UDim2.fromScale(0.48, 0.28)
quickLayout.CellPadding = UDim2.fromScale(0.04, 0.04)
quickLayout.Parent = quickRow

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.fromScale(0.66, 0.09)
inputBox.Position = UDim2.fromScale(0.04, 0.86)
inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputBox.PlaceholderText = "Type your question for the mirror..."
inputBox.Text = ""
inputBox.TextColor3 = palette.Ink
inputBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 150)
inputBox.Font = Enum.Font.GothamSemibold
inputBox.TextScaled = true
inputBox.ClearTextOnFocus = false
inputBox.Parent = mirrorFrame
addCorner(inputBox, 10)

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.fromScale(0.24, 0.09)
sendButton.Position = UDim2.fromScale(0.72, 0.86)
sendButton.BackgroundColor3 = palette.CandyPurple
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.Font = Enum.Font.FredokaOne
sendButton.TextScaled = true
sendButton.Text = "Send"
sendButton.Parent = mirrorFrame
addCorner(sendButton, 10)

local closeMirrorButton = Instance.new("TextButton")
closeMirrorButton.Size = UDim2.fromScale(0.24, 0.08)
closeMirrorButton.Position = UDim2.fromScale(0.72, 0.03)
closeMirrorButton.BackgroundColor3 = palette.Pink
closeMirrorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeMirrorButton.Font = Enum.Font.FredokaOne
closeMirrorButton.TextScaled = true
closeMirrorButton.Text = "Close"
closeMirrorButton.Parent = mirrorFrame
addCorner(closeMirrorButton, 10)

local toast = Instance.new("TextLabel")
toast.Size = UDim2.fromScale(0.44, 0.075)
toast.Position = UDim2.fromScale(0.28, 0.05)
toast.BackgroundColor3 = palette.CandyPurple
toast.BackgroundTransparency = 0.2
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.TextScaled = true
toast.Font = Enum.Font.FredokaOne
toast.Visible = false
toast.Parent = screenGui
addCorner(toast, 10)

local toastId = 0
local function showToast(text, color)
	toastId += 1
	local currentId = toastId

	toast.Text = text
	toast.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	toast.TextTransparency = 1
	toast.BackgroundTransparency = 0.6
	toast.Visible = true

	TweenService:Create(toast, TweenInfo.new(0.2), {
		TextTransparency = 0,
		BackgroundTransparency = 0.2,
	}):Play()

	task.delay(2.8, function()
		if currentId ~= toastId then
			return
		end
		local fade = TweenService:Create(toast, TweenInfo.new(0.24), {
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

local function openAvatarPanel()
	rootFrame.Visible = true
	mirrorFrame.Visible = false
end

local function openMirrorPanel()
	mirrorFrame.Visible = true
	rootFrame.Visible = false
end

local function closePanels()
	rootFrame.Visible = false
	mirrorFrame.Visible = false
end

local function getPrizeTotal()
	local inventory = player:FindFirstChild("PrizeInventory")
	if not inventory then
		return 0
	end

	local total = 0
	for _, child in ipairs(inventory:GetChildren()) do
		if child:IsA("IntValue") then
			total += child.Value
		end
	end
	return total
end

local function updateInventoryLabel()
	local total = getPrizeTotal()
	if total <= 0 then
		inventoryLabel.Text = "Prizes: none yet"
	else
		inventoryLabel.Text = "Prizes won: " .. tostring(total)
	end
end

local function connectInventory(inventory)
	inventory.ChildAdded:Connect(function(child)
		if child:IsA("IntValue") then
			child.Changed:Connect(updateInventoryLabel)
			updateInventoryLabel()
		end
	end)
	inventory.ChildRemoved:Connect(updateInventoryLabel)

	for _, child in ipairs(inventory:GetChildren()) do
		if child:IsA("IntValue") then
			child.Changed:Connect(updateInventoryLabel)
		end
	end
end

local chatLines = {}
local function pushMirrorLine(speaker, text, color)
	local line = string.format("<font color=\"%s\"><b>%s:</b> %s</font>", colorToHex(color), speaker, text)
	table.insert(chatLines, line)
	if #chatLines > 14 then
		table.remove(chatLines, 1)
	end

	chatLog.Text = table.concat(chatLines, "\n\n")
	chatScroll.CanvasSize = UDim2.fromOffset(0, chatLog.TextBounds.Y + 18)
	chatScroll.CanvasPosition = Vector2.new(0, math.max(chatLog.TextBounds.Y - chatScroll.AbsoluteSize.Y + 28, 0))
end

local function sendMirrorMessage(message)
	local trimmed = string.gsub(message or "", "^%s*(.-)%s*$", "%1")
	if trimmed == "" then
		return
	end

	pushMirrorLine(player.DisplayName or player.Name, trimmed, palette.Blue)
	mirrorRequestEvent:FireServer(trimmed)
end

for _, question in ipairs(MirrorAIConfig.QuickQuestions) do
	local quickButton = Instance.new("TextButton")
	quickButton.BackgroundColor3 = palette.Teal
	quickButton.TextColor3 = palette.Ink
	quickButton.Text = question
	quickButton.TextScaled = true
	quickButton.Font = Enum.Font.GothamBold
	quickButton.Parent = quickRow
	addCorner(quickButton, 8)

	quickButton.Activated:Connect(function()
		sendMirrorMessage(question)
	end)
end

openMirrorAIButton.Activated:Connect(function()
	openMirrorPanel()
	if #chatLines == 0 then
		pushMirrorLine(MirrorAIConfig.MirrorName, MirrorAIConfig.OpeningLine .. " Ask me anything, little star.", palette.CandyPurple)
	end
end)

closeButton.Activated:Connect(closePanels)
closeMirrorButton.Activated:Connect(closePanels)

sendButton.Activated:Connect(function()
	sendMirrorMessage(inputBox.Text)
	inputBox.Text = ""
end)

inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		sendMirrorMessage(inputBox.Text)
		inputBox.Text = ""
	end
end)

avatarResultEvent.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	showToast(payload.Text or "Avatar updated", Color3.fromRGB(119, 232, 170))
end)

mirrorResponseEvent.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	pushMirrorLine(payload.MirrorName or MirrorAIConfig.MirrorName, payload.Reply or "I could not hear that.", palette.CandyPurple)
end)

prizeWonEvent.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	local color = Color3.fromRGB(255, 255, 255)
	if payload.Kind == "Prize" then
		local rarity = payload.Rarity or "Common"
		if rarity == "Rare" then
			color = Color3.fromRGB(120, 222, 255)
		elseif rarity == "Epic" then
			color = Color3.fromRGB(255, 159, 255)
		elseif rarity == "Legendary" then
			color = Color3.fromRGB(255, 230, 121)
		end
	elseif payload.Kind == "Miss" then
		color = Color3.fromRGB(255, 210, 145)
	elseif payload.Kind == "Busy" then
		color = Color3.fromRGB(255, 196, 196)
	end

	showToast(payload.Text or "Claw update", color)
	updateInventoryLabel()
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, triggeredPlayer)
	if triggeredPlayer ~= player then
		return
	end

	if prompt.Name == "MirrorPrompt" then
		openAvatarPanel()
	elseif prompt.Name == "MirrorAIPrompt" then
		openMirrorPanel()
		if #chatLines == 0 then
			pushMirrorLine(MirrorAIConfig.MirrorName, MirrorAIConfig.OpeningLine .. " Who is the cutest hero in the arcade? You are!", palette.CandyPurple)
		end
	end
end)

local inventory = player:FindFirstChild("PrizeInventory")
if inventory then
	connectInventory(inventory)
else
	player.ChildAdded:Connect(function(child)
		if child.Name == "PrizeInventory" and child:IsA("Folder") then
			connectInventory(child)
			updateInventoryLabel()
		end
	end)
end

updateInventoryLabel()
