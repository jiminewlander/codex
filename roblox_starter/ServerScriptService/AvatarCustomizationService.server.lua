local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvatarConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("AvatarConfig"))

local remotes = ReplicatedStorage:FindFirstChild("ArcadeRemotes") or Instance.new("Folder")
remotes.Name = "ArcadeRemotes"
remotes.Parent = ReplicatedStorage

local requestEvent = remotes:FindFirstChild(AvatarConfig.RequestEventName)
if not requestEvent then
	requestEvent = Instance.new("RemoteEvent")
	requestEvent.Name = AvatarConfig.RequestEventName
	requestEvent.Parent = remotes
end

local resultEvent = remotes:FindFirstChild(AvatarConfig.ResultEventName)
if not resultEvent then
	resultEvent = Instance.new("RemoteEvent")
	resultEvent.Name = AvatarConfig.ResultEventName
	resultEvent.Parent = remotes
end

local playerSelection = {}

local function getOptionsForCategory(category)
	local categoryInfo = AvatarConfig.Categories[category]
	if not categoryInfo then
		return nil
	end

	local avatarItems = ReplicatedStorage:FindFirstChild("AvatarItems")
	if not avatarItems then
		return nil
	end

	local folder = avatarItems:FindFirstChild(categoryInfo.FolderName)
	if not folder then
		return nil
	end

	local options = folder:GetChildren()
	table.sort(options, function(a, b)
		return a.Name < b.Name
	end)
	return options
end

local function nextIndex(userId, category, count)
	local state = playerSelection[userId]
	if not state then
		state = {}
		playerSelection[userId] = state
	end

	local previous = state[category] or 0
	local nextValue = (previous % count) + 1
	state[category] = nextValue
	return nextValue
end

local function removeCategoryAccessories(character, category)
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") and child:GetAttribute("AvatarCategory") == category then
			child:Destroy()
		end
	end
end

local function applyAccessory(character, template, category)
	if not template:IsA("Accessory") then
		return false, "Item is not an Accessory"
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false, "No humanoid found"
	end

	removeCategoryAccessories(character, category)

	local clone = template:Clone()
	clone:SetAttribute("AvatarCategory", category)
	humanoid:AddAccessory(clone)
	return true, nil
end

local function recolorCharacterParts(character, topColor, bottomColor)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			local partName = string.lower(part.Name)
			if string.find(partName, "arm") or string.find(partName, "torso") then
				part.Color = topColor
			elseif string.find(partName, "leg") or string.find(partName, "foot") then
				part.Color = bottomColor
			end
		end
	end
end

local function applyOutfit(character, outfitFolder)
	local topColorValue = outfitFolder:FindFirstChild("TopColor")
	local bottomColorValue = outfitFolder:FindFirstChild("BottomColor")

	if topColorValue and topColorValue:IsA("Color3Value") and bottomColorValue and bottomColorValue:IsA("Color3Value") then
		recolorCharacterParts(character, topColorValue.Value, bottomColorValue.Value)
	end

	local shirtTemplate = outfitFolder:FindFirstChild("ShirtTemplate")
	local pantsTemplate = outfitFolder:FindFirstChild("PantsTemplate")

	if shirtTemplate and shirtTemplate:IsA("StringValue") and shirtTemplate.Value ~= "" then
		local shirt = character:FindFirstChildOfClass("Shirt") or Instance.new("Shirt")
		shirt.ShirtTemplate = shirtTemplate.Value
		shirt.Parent = character
	end

	if pantsTemplate and pantsTemplate:IsA("StringValue") and pantsTemplate.Value ~= "" then
		local pants = character:FindFirstChildOfClass("Pants") or Instance.new("Pants")
		pants.PantsTemplate = pantsTemplate.Value
		pants.Parent = character
	end

	return true, nil
end

local function applyCategory(player, category)
	local character = player.Character
	if not character then
		return
	end

	local options = getOptionsForCategory(category)
	if not options or #options == 0 then
		resultEvent:FireClient(player, {
			Text = "No options found for " .. category,
			Kind = "AvatarWarning",
		})
		return
	end

	local selectedIndex = nextIndex(player.UserId, category, #options)
	local selectedOption = options[selectedIndex]

	local success
	local errorText
	if category == "Outfit" then
		success, errorText = applyOutfit(character, selectedOption)
	else
		success, errorText = applyAccessory(character, selectedOption, category)
	end

	if not success then
		resultEvent:FireClient(player, {
			Text = "Could not apply " .. category .. ": " .. (errorText or "Unknown"),
			Kind = "AvatarWarning",
		})
		return
	end

	resultEvent:FireClient(player, {
		Text = category .. " set to " .. selectedOption.Name,
		Category = category,
		Selection = selectedOption.Name,
		Kind = "AvatarResult",
	})
end

requestEvent.OnServerEvent:Connect(function(player, category)
	if typeof(category) ~= "string" then
		return
	end
	if not AvatarConfig.Categories[category] then
		return
	end
	applyCategory(player, category)
end)

Players.PlayerRemoving:Connect(function(player)
	playerSelection[player.UserId] = nil
end)
