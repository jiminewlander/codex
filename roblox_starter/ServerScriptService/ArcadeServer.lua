local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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

local function ensureRemote(className, name)
	local remote = remotes:FindFirstChild(name)
	if remote and remote.ClassName == className then
		return remote
	end

	if remote then
		remote:Destroy()
	end

	remote = Instance.new(className)
	remote.Name = name
	remote.Parent = remotes
	return remote
end

local arcadeMessage = ensureRemote("RemoteEvent", "ArcadeMessage")
local openAvatarBooth = ensureRemote("RemoteEvent", "OpenAvatarBooth")
local applyAvatarPreset = ensureRemote("RemoteFunction", "ApplyAvatarPreset")
local adminCommand = ensureRemote("RemoteFunction", "AdminCommand")
local arcadePolishEvent = ensureRemote("RemoteEvent", "ArcadePolishEvent")

local machineState = {}
local machineEmitters = {}
local pulsingLights = {}

local function copyRewards(rewards)
	local output = {}
	for _, reward in ipairs(rewards) do
		table.insert(output, {
			Name = reward.Name,
			Rarity = reward.Rarity,
			Weight = reward.Weight,
		})
	end

	return output
end

local function resetMachineState()
	for machineType, config in pairs(ArcadeConfig.Machines) do
		machineState[machineType] = {
			Cost = config.Cost,
			Rewards = copyRewards(config.Rewards),
		}
	end
end

resetMachineState()

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

local function ensureTextSurface(part, text, color)
	local surface = part:FindFirstChild("Display")
	if not surface then
		surface = Instance.new("SurfaceGui")
		surface.Name = "Display"
		surface.Face = Enum.NormalId.Front
		surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surface.PixelsPerStud = 30
		surface.Parent = part
	end

	local label = surface:FindFirstChild("Label")
	if not label then
		label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		label.Parent = surface
	end

	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.2
end

local function ensurePulseLight(parent, name, color, brightness, range)
	local light = parent:FindFirstChild(name)
	if not light then
		light = Instance.new("PointLight")
		light.Name = name
		light.Parent = parent
	end

	light.Color = color
	light.Brightness = brightness
	light.Range = range
	table.insert(pulsingLights, light)
	return light
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

	local backWall = arcade:FindFirstChild("BackWall")
	if not backWall then
		backWall = ensurePart(arcade, "BackWall", Vector3.new(90, 26, 2), Vector3.new(0, 13, -25), Color3.fromRGB(20, 13, 43))
		backWall.Material = Enum.Material.SmoothPlastic
	end

	local mainSign = arcade:FindFirstChild("MainSign")
	if not mainSign then
		mainSign = ensurePart(arcade, "MainSign", Vector3.new(32, 7, 1), Vector3.new(0, 18, -23.7), Color3.fromRGB(72, 255, 212))
		mainSign.Material = Enum.Material.Neon
	end
	ensureTextSurface(mainSign, "KPOP DEMON HUNTER ARCADE", Color3.fromRGB(255, 246, 197))
	ensurePulseLight(mainSign, "SignLight", Color3.fromRGB(255, 220, 140), 2.8, 35)

	local function ensureMachine(modelName, machineType, position, color, marqueeText)
		local model = arcade:FindFirstChild(modelName)
		if not model then
			model = Instance.new("Model")
			model.Name = modelName
			model.Parent = arcade
		end

		local cabinet = ensurePart(model, "Cabinet", Vector3.new(9, 12, 7), position, color)
		cabinet.Material = Enum.Material.SmoothPlastic
		local marquee = ensurePart(model, "Marquee", Vector3.new(8, 1.4, 0.6), position + Vector3.new(0, 4.8, 3.75), Color3.fromRGB(255, 239, 144))
		marquee.Material = Enum.Material.Neon
		ensureTextSurface(marquee, marqueeText, Color3.fromRGB(34, 14, 65))

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

		ensurePulseLight(cabinet, "CabinetLight", color, 2.3, 24)
		ensurePulseLight(marquee, "MarqueeLight", Color3.fromRGB(255, 249, 182), 1.9, 14)

		local confettiAttachment = cabinet:FindFirstChild("ConfettiAttachment")
		if not confettiAttachment then
			confettiAttachment = Instance.new("Attachment")
			confettiAttachment.Name = "ConfettiAttachment"
			confettiAttachment.Position = Vector3.new(0, 5, 0)
			confettiAttachment.Parent = cabinet
		end

		local confetti = confettiAttachment:FindFirstChild("RareWinConfetti")
		if not confetti then
			confetti = Instance.new("ParticleEmitter")
			confetti.Name = "RareWinConfetti"
			confetti.Enabled = false
			confetti.Lifetime = NumberRange.new(1.5, 2.2)
			confetti.Speed = NumberRange.new(10, 17)
			confetti.RotSpeed = NumberRange.new(-180, 180)
			confetti.SpreadAngle = Vector2.new(65, 65)
			confetti.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.45),
				NumberSequenceKeypoint.new(1, 0.1),
			})
			confetti.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 252, 163)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110, 248, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 134, 238)),
			})
			confetti.Parent = confettiAttachment
		end

		machineEmitters[machineType] = confetti
		return prompt
	end

	local petsPrompt = ensureMachine("ClawMachinePets", "Pets", Vector3.new(-14, 6, -4), Color3.fromRGB(75, 240, 255), "PET CLAW")
	local plushiesPrompt = ensureMachine("ClawMachinePlushies", "Plushies", Vector3.new(14, 6, -4), Color3.fromRGB(255, 117, 191), "PLUSHIE CLAW")

	local avatarBooth = arcade:FindFirstChild("AvatarBooth")
	if not avatarBooth then
		avatarBooth = ensurePart(arcade, "AvatarBooth", Vector3.new(8, 10, 8), Vector3.new(0, 5, 12), Color3.fromRGB(130, 87, 255))
	end
	avatarBooth.Material = Enum.Material.Neon
	ensurePulseLight(avatarBooth, "AvatarLight", Color3.fromRGB(255, 194, 255), 2.1, 20)

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

	local adminPillar = arcade:FindFirstChild("AdminPillar")
	if not adminPillar then
		adminPillar = ensurePart(arcade, "AdminPillar", Vector3.new(4, 8, 4), Vector3.new(-32, 4, 18), Color3.fromRGB(39, 44, 73))
		adminPillar.Material = Enum.Material.Metal
	end
	ensureTextSurface(adminPillar, "ADMIN", Color3.fromRGB(255, 255, 255))

	local ambient = floor:FindFirstChild("ArcadeAmbient")
	if not ambient then
		ambient = Instance.new("Sound")
		ambient.Name = "ArcadeAmbient"
		ambient.Looped = true
		ambient.RollOffMaxDistance = 150
		ambient.Parent = floor
	end
	ambient.SoundId = ArcadeConfig.Polish.AmbientSoundId or ""
	ambient.Volume = ArcadeConfig.Polish.AmbientVolume or 0.07
	ambient.PlaybackSpeed = ArcadeConfig.Polish.AmbientPlaybackSpeed or 0.65
	if ambient.SoundId ~= "" and not ambient.IsPlaying then
		ambient:Play()
	end

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

local function emitRareWin(machineType, rarity, winner)
	local burstByRarity = ArcadeConfig.Polish.RareWinConfettiBursts or {}
	local burstCount = burstByRarity[rarity] or 0
	local emitter = machineEmitters[machineType]
	if emitter and burstCount > 0 then
		emitter:Emit(burstCount)
	end

	arcadePolishEvent:FireAllClients({
		Kind = "RareWin",
		Rarity = rarity,
		MachineType = machineType,
		Winner = winner and winner.Name or "",
	})
end

local function spinMachine(player, machineType)
	local machineConfig = machineState[machineType]
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

	if reward.Rarity == "Epic" or reward.Rarity == "Legendary" then
		emitRareWin(machineType, reward.Rarity, player)
	end
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

local function isAdmin(player)
	if ArcadeConfig.Admin and ArcadeConfig.Admin.AllowAllInStudio and RunService:IsStudio() then
		return true
	end

	local allowed = ArcadeConfig.Admin and ArcadeConfig.Admin.AllowedUserIds or {}
	for _, userId in ipairs(allowed) do
		if player.UserId == userId then
			return true
		end
	end

	return false
end

local function getTargetPlayer(requestingPlayer, payload)
	if type(payload) ~= "table" then
		return requestingPlayer
	end

	local targetUserId = tonumber(payload.TargetUserId)
	if not targetUserId then
		return requestingPlayer
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.UserId == targetUserId then
			return player
		end
	end

	return nil
end

local function serializeMachineState()
	local output = {}
	for machineType, data in pairs(machineState) do
		local serializedRewards = {}
		for _, reward in ipairs(data.Rewards) do
			table.insert(serializedRewards, {
				Name = reward.Name,
				Rarity = reward.Rarity,
				Weight = reward.Weight,
			})
		end

		output[machineType] = {
			Cost = data.Cost,
			Rewards = serializedRewards,
		}
	end

	return output
end

local function runAdminCommand(player, command, payload)
	if not isAdmin(player) then
		return false, "Admin access denied."
	end

	if command == "GetStatus" then
		return true, {
			Machines = serializeMachineState(),
		}
	end

	if command == "GrantCoins" then
		local target = getTargetPlayer(player, payload)
		if not target then
			return false, "Target player not found."
		end

		local amount = math.floor(tonumber(payload and payload.Amount) or 0)
		amount = math.clamp(amount, -5000, 5000)
		if amount == 0 then
			return false, "Amount must be non-zero."
		end

		local coins = getCoinsValue(target)
		if not coins then
			return false, "Target has no coin data."
		end

		coins.Value = math.max(0, coins.Value + amount)
		return true, string.format("Coins updated for %s (%+d).", target.Name, amount)
	end

	if command == "ResetInventory" then
		local target = getTargetPlayer(player, payload)
		if not target then
			return false, "Target player not found."
		end

		local inventory = target:FindFirstChild("Inventory")
		if not inventory then
			return false, "Target has no inventory."
		end

		for _, categoryName in ipairs({ "Pets", "Plushies" }) do
			local category = inventory:FindFirstChild(categoryName)
			if category then
				for _, item in ipairs(category:GetChildren()) do
					item:Destroy()
				end
			end
		end

		return true, "Inventory reset for " .. target.Name .. "."
	end

	if command == "SetMachineCost" then
		local machineType = payload and payload.MachineType
		local cost = math.floor(tonumber(payload and payload.Cost) or -1)
		if type(machineType) ~= "string" or not machineState[machineType] then
			return false, "Invalid machine type."
		end
		if cost < 1 or cost > 500 then
			return false, "Cost must be 1-500."
		end

		machineState[machineType].Cost = cost
		return true, string.format("%s cost set to %d.", machineType, cost)
	end

	if command == "SetRewardWeight" then
		local machineType = payload and payload.MachineType
		local rewardName = payload and payload.RewardName
		local weight = tonumber(payload and payload.Weight)
		if type(machineType) ~= "string" or not machineState[machineType] then
			return false, "Invalid machine type."
		end
		if type(rewardName) ~= "string" then
			return false, "Invalid reward name."
		end
		weight = math.floor(weight or -1)
		if weight < 0 or weight > 200 then
			return false, "Weight must be 0-200."
		end

		for _, reward in ipairs(machineState[machineType].Rewards) do
			if reward.Name == rewardName then
				reward.Weight = weight
				return true, string.format("Updated %s weight to %d.", rewardName, weight)
			end
		end

		return false, "Reward not found."
	end

	if command == "RestoreDefaults" then
		resetMachineState()
		return true, "Machine settings restored to defaults."
	end

	return false, "Unknown admin command."
end

adminCommand.OnServerInvoke = function(player, command, payload)
	local ok, result = runAdminCommand(player, command, payload)
	return ok, result
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

task.spawn(function()
	local phase = 0
	while true do
		phase += 0.08
		local pulse = (math.sin(phase) + 1) * 0.5
		for _, light in ipairs(pulsingLights) do
			if light and light.Parent then
				light.Brightness = 1.1 + pulse * 2.4
			end
		end
		task.wait(0.06)
	end
end)
