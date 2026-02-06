local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArcadeConfig = require(ReplicatedStorage:WaitForChild("ArcadeConfig"))

local REMOTE_FOLDER_NAME = "ArcadeRemotes"
local MACHINE_PROMPT_NAME = "ClawPrompt"
local AVATAR_PROMPT_NAME = "AvatarBoothPrompt"

local remotes = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER_NAME)
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = REMOTE_FOLDER_NAME
	remotes.Parent = ReplicatedStorage
end

local arcadeMessage = remotes:FindFirstChild("ArcadeMessage")
if not arcadeMessage then
	arcadeMessage = Instance.new("RemoteEvent")
	arcadeMessage.Name = "ArcadeMessage"
	arcadeMessage.Parent = remotes
end

local openAvatarBooth = remotes:FindFirstChild("OpenAvatarBooth")
if not openAvatarBooth then
	openAvatarBooth = Instance.new("RemoteEvent")
	openAvatarBooth.Name = "OpenAvatarBooth"
	openAvatarBooth.Parent = remotes
end

local applyAvatarPreset = remotes:FindFirstChild("ApplyAvatarPreset")
if not applyAvatarPreset then
	applyAvatarPreset = Instance.new("RemoteFunction")
	applyAvatarPreset.Name = "ApplyAvatarPreset"
	applyAvatarPreset.Parent = remotes
end

local function ensurePart(parent, name, size, position, color)
	local part = parent:FindFirstChild(name)
	if not part then
		part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Position = position
		part.Anchored = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Color = color
		part.Parent = parent
	end

	return part
end

local function ensureArcadeLayout()
	local arcade = workspace:FindFirstChild("Arcade")
	if not arcade then
		arcade = Instance.new("Model")
		arcade.Name = "Arcade"
		arcade.Parent = workspace
	end

	local floor = arcade:FindFirstChild("Floor")
	if not floor then
		floor = ensurePart(arcade, "Floor", Vector3.new(90, 1, 90), Vector3.new(0, 0, 0), Color3.fromRGB(30, 30, 50))
		local floorTexture = Instance.new("Texture")
		floorTexture.Texture = "rbxassetid://6067461890"
		floorTexture.StudsPerTileU = 10
		floorTexture.StudsPerTileV = 10
		floorTexture.Face = Enum.NormalId.Top
		floorTexture.Transparency = 0.55
		floorTexture.Parent = floor
	end

	local function ensureMachine(modelName, machineType, position, color)
		local model = arcade:FindFirstChild(modelName)
		if not model then
			model = Instance.new("Model")
			model.Name = modelName
			model.Parent = arcade
		end

		local cabinet = ensurePart(model, "Cabinet", Vector3.new(9, 12, 7), position, color)
		local interactionPart = ensurePart(model, "InteractionPart", Vector3.new(8, 2, 4), position + Vector3.new(0, -4, 0), Color3.fromRGB(15, 15, 15))
		interactionPart.Transparency = 0.15

		local prompt = interactionPart:FindFirstChild(MACHINE_PROMPT_NAME)
		if not prompt then
			prompt = Instance.new("ProximityPrompt")
			prompt.Name = MACHINE_PROMPT_NAME
			prompt.Parent = interactionPart
		end

		prompt.ActionText = "Play " .. machineType .. " Claw"
		prompt.ObjectText = modelName
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.HoldDuration = 0.2
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 10

		local existingLight = cabinet:FindFirstChild("CabinetLight")
		if not existingLight then
			local pointLight = Instance.new("PointLight")
			pointLight.Name = "CabinetLight"
			pointLight.Brightness = 2.2
			pointLight.Range = 20
			pointLight.Color = color
			pointLight.Parent = cabinet
		end

		return prompt
	end

	local petsPrompt = ensureMachine("ClawMachinePets", "Pets", Vector3.new(-14, 6, -4), Color3.fromRGB(75, 240, 255))
	local plushiesPrompt = ensureMachine("ClawMachinePlushies", "Plushies", Vector3.new(14, 6, -4), Color3.fromRGB(255, 117, 191))

	local avatarBooth = arcade:FindFirstChild("AvatarBooth")
	if not avatarBooth then
		avatarBooth = ensurePart(arcade, "AvatarBooth", Vector3.new(8, 10, 8), Vector3.new(0, 5, 12), Color3.fromRGB(130, 87, 255))
	end
	avatarBooth.Material = Enum.Material.Neon

	local avatarPrompt = avatarBooth:FindFirstChild(AVATAR_PROMPT_NAME)
	if not avatarPrompt then
		avatarPrompt = Instance.new("ProximityPrompt")
		avatarPrompt.Name = AVATAR_PROMPT_NAME
		avatarPrompt.Parent = avatarBooth
	end

	avatarPrompt.ActionText = "Edit Avatar"
	avatarPrompt.ObjectText = "Style Station"
	avatarPrompt.KeyboardKeyCode = Enum.KeyCode.E
	avatarPrompt.HoldDuration = 0.2
	avatarPrompt.RequiresLineOfSight = false
	avatarPrompt.MaxActivationDistance = 10

	local kamHome = arcade:FindFirstChild("KamHome")
	if not kamHome then
		kamHome = ensurePart(arcade, "KamHome", Vector3.new(6, 1, 6), Vector3.new(0, 0.5, 24), Color3.fromRGB(139, 95, 65))
	end
	kamHome.Material = Enum.Material.WoodPlanks

	return petsPrompt, plushiesPrompt, avatarPrompt
end

local function getCoinsValue(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	return leaderstats:FindFirstChild("Coins")
end

local function ensurePlayerData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then
		coins = Instance.new("IntValue")
		coins.Name = "Coins"
		coins.Value = ArcadeConfig.StartingCoins
		coins.Parent = leaderstats
	end

	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		inventory = Instance.new("Folder")
		inventory.Name = "Inventory"
		inventory.Parent = player
	end

	if not inventory:FindFirstChild("Pets") then
		local pets = Instance.new("Folder")
		pets.Name = "Pets"
		pets.Parent = inventory
	end

	if not inventory:FindFirstChild("Plushies") then
		local plushies = Instance.new("Folder")
		plushies.Name = "Plushies"
		plushies.Parent = inventory
	end
end

local function weightedRewardRoll(rewards)
	local totalWeight = 0
	for _, reward in ipairs(rewards) do
		totalWeight += reward.Weight
	end

	local roll = Random.new():NextNumber(0, totalWeight)
	local cumulative = 0
	for _, reward in ipairs(rewards) do
		cumulative += reward.Weight
		if roll <= cumulative then
			return reward
		end
	end

	return rewards[#rewards]
end

local function addReward(player, machineType, rewardName)
	local inventory = player:FindFirstChild("Inventory")
	if not inventory then
		return
	end

	local machineFolder = inventory:FindFirstChild(machineType)
	if not machineFolder then
		return
	end

	local rewardValue = machineFolder:FindFirstChild(rewardName)
	if not rewardValue then
		rewardValue = Instance.new("IntValue")
		rewardValue.Name = rewardName
		rewardValue.Value = 0
		rewardValue.Parent = machineFolder
	end

	rewardValue.Value += 1
end

local function spinMachine(player, machineType)
	local machineConfig = ArcadeConfig.Machines[machineType]
	if not machineConfig then
		return
	end

	local coins = getCoinsValue(player)
	if not coins then
		return
	end

	if coins.Value < machineConfig.Cost then
		arcadeMessage:FireClient(player, {
			Kind = "Error",
			Text = "Not enough coins for " .. machineType .. " claw.",
		})
		return
	end

	coins.Value -= machineConfig.Cost
	local reward = weightedRewardRoll(machineConfig.Rewards)
	addReward(player, machineType, reward.Name)

	arcadeMessage:FireClient(player, {
		Kind = "SpinResult",
		Text = string.format("You won %s (%s) from %s!", reward.Name, reward.Rarity, machineType),
		Rarity = reward.Rarity,
		RewardName = reward.Name,
		MachineType = machineType,
	})
end

local function getAvatarPresetByKey(presetKey)
	for _, preset in ipairs(ArcadeConfig.AvatarPresets) do
		if preset.Key == presetKey then
			return preset
		end
	end

	return nil
end

local function applyPresetToPlayer(player, presetKey)
	local preset = getAvatarPresetByKey(presetKey)
	if not preset then
		return false, "Preset not found."
	end

	local character = player.Character
	if not character then
		return false, "Character is not ready."
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false, "Humanoid is missing."
	end

	local ok, err = pcall(function()
		local description = humanoid:GetAppliedDescription()
		if preset.ShirtId and preset.ShirtId > 0 then
			description.Shirt = preset.ShirtId
		end
		if preset.PantsId and preset.PantsId > 0 then
			description.Pants = preset.PantsId
		end
		if preset.HatAccessoryIds and #preset.HatAccessoryIds > 0 then
			description.HatAccessory = table.concat(preset.HatAccessoryIds, ",")
		end
		if preset.FaceAccessoryIds and #preset.FaceAccessoryIds > 0 then
			description.FaceAccessory = table.concat(preset.FaceAccessoryIds, ",")
		end
		humanoid:ApplyDescription(description)

		if preset.RunSpeed then
			humanoid.WalkSpeed = preset.RunSpeed
		end
		if preset.JumpPower then
			humanoid.JumpPower = preset.JumpPower
		end
	end)

	if not ok then
		return false, "Failed to apply preset: " .. tostring(err)
	end

	return true, "Preset applied."
end

applyAvatarPreset.OnServerInvoke = function(player, presetKey)
	return applyPresetToPlayer(player, presetKey)
end

local petsPrompt, plushiesPrompt, avatarPrompt = ensureArcadeLayout()

petsPrompt.Triggered:Connect(function(player)
	spinMachine(player, "Pets")
end)

plushiesPrompt.Triggered:Connect(function(player)
	spinMachine(player, "Plushies")
end)

avatarPrompt.Triggered:Connect(function(player)
	openAvatarBooth:FireClient(player)
end)

Players.PlayerAdded:Connect(function(player)
	ensurePlayerData(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	ensurePlayerData(player)
end
