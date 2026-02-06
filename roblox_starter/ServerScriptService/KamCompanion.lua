local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ArcadeConfig = require(ReplicatedStorage:WaitForChild("ArcadeConfig"))

local KAM_NAME = "Kam"
local FOLLOW_RANGE = 60
local STOP_DISTANCE = 6
local FOLLOW_SPEED = 12

local friendshipConfig = ArcadeConfig.Kam or {}
local petCooldownSeconds = friendshipConfig.PetCooldownSeconds or 4
local levelThresholds = friendshipConfig.LevelThresholds or { 5, 14, 28, 45 }
local levelCoinRewards = friendshipConfig.LevelCoinRewards or { 15, 30, 55, 90 }
local trickCycle = friendshipConfig.TrickCycle or { "Sit", "Spin", "Fetch" }

local remotes = ReplicatedStorage:WaitForChild("ArcadeRemotes", 10)
local arcadeMessage = remotes and remotes:FindFirstChild("ArcadeMessage")

local playerFriendship = {}
local activeTrick = {
	Type = nil,
	EndsAt = 0,
	Data = {},
}

local function ensureArcadeAndHome()
	local arcade = workspace:FindFirstChild("Arcade")
	if not arcade then
		arcade = Instance.new("Model")
		arcade.Name = "Arcade"
		arcade.Parent = workspace
	end

	local home = arcade:FindFirstChild("KamHome")
	if not home then
		home = Instance.new("Part")
		home.Name = "KamHome"
		home.Size = Vector3.new(6, 1, 6)
		home.Position = Vector3.new(0, 0.5, 24)
		home.Anchored = true
		home.Color = Color3.fromRGB(139, 95, 65)
		home.Material = Enum.Material.WoodPlanks
		home.Parent = arcade
	end

	return arcade, home
end

local function createKamModel(spawnPosition)
	local kam = Instance.new("Model")
	kam.Name = KAM_NAME
	kam.Parent = workspace

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(3, 2, 5)
	body.Color = Color3.fromRGB(101, 67, 33)
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.Position = spawnPosition + Vector3.new(0, 2.2, 0)
	body.Parent = kam

	local chest = Instance.new("Part")
	chest.Name = "Chest"
	chest.Size = Vector3.new(2.4, 1.6, 1.8)
	chest.Color = Color3.fromRGB(176, 130, 94)
	chest.Anchored = true
	chest.Position = body.Position + Vector3.new(0, -0.1, 1.4)
	chest.Parent = kam

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2.2, 2.1, 2.3)
	head.Color = Color3.fromRGB(110, 73, 39)
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.Position = body.Position + Vector3.new(0, 0.3, 3.2)
	head.Parent = kam

	local nose = Instance.new("Part")
	nose.Name = "Nose"
	nose.Size = Vector3.new(0.8, 0.5, 0.5)
	nose.Color = Color3.fromRGB(20, 20, 20)
	nose.Anchored = true
	nose.Position = head.Position + Vector3.new(0, -0.1, 1.2)
	nose.Parent = kam

	local leftEar = Instance.new("Part")
	leftEar.Name = "LeftEar"
	leftEar.Size = Vector3.new(0.5, 1.4, 0.6)
	leftEar.Color = Color3.fromRGB(82, 55, 30)
	leftEar.Anchored = true
	leftEar.Position = head.Position + Vector3.new(-0.75, 1.1, 0.1)
	leftEar.Parent = kam

	local rightEar = Instance.new("Part")
	rightEar.Name = "RightEar"
	rightEar.Size = Vector3.new(0.5, 1.4, 0.6)
	rightEar.Color = Color3.fromRGB(82, 55, 30)
	rightEar.Anchored = true
	rightEar.Position = head.Position + Vector3.new(0.75, 1.1, 0.1)
	rightEar.Parent = kam

	local tail = Instance.new("Part")
	tail.Name = "Tail"
	tail.Size = Vector3.new(0.4, 0.4, 2)
	tail.Color = Color3.fromRGB(87, 58, 31)
	tail.Anchored = true
	tail.Position = body.Position + Vector3.new(0, 0.4, -3)
	tail.Parent = kam

	local label = Instance.new("BillboardGui")
	label.Name = "NameTag"
	label.Size = UDim2.fromOffset(160, 50)
	label.StudsOffset = Vector3.new(0, 4.1, 0)
	label.AlwaysOnTop = true
	label.Parent = body

	local nameText = Instance.new("TextLabel")
	nameText.Name = "NameText"
	nameText.BackgroundTransparency = 1
	nameText.Size = UDim2.fromScale(1, 1)
	nameText.Text = "Kam Lv0"
	nameText.TextColor3 = Color3.fromRGB(255, 236, 214)
	nameText.TextStrokeTransparency = 0.3
	nameText.Font = Enum.Font.FredokaOne
	nameText.TextScaled = true
	nameText.Parent = label

	local petPrompt = Instance.new("ProximityPrompt")
	petPrompt.Name = "PetPrompt"
	petPrompt.ActionText = "Pet Kam"
	petPrompt.ObjectText = "Chocolate Lab"
	petPrompt.KeyboardKeyCode = Enum.KeyCode.E
	petPrompt.HoldDuration = 0.15
	petPrompt.RequiresLineOfSight = false
	petPrompt.MaxActivationDistance = 10
	petPrompt.Parent = body

	local trickPrompt = Instance.new("ProximityPrompt")
	trickPrompt.Name = "TrickPrompt"
	trickPrompt.ActionText = "Ask For Trick"
	trickPrompt.ObjectText = "Kam"
	trickPrompt.KeyboardKeyCode = Enum.KeyCode.R
	trickPrompt.HoldDuration = 0.2
	trickPrompt.RequiresLineOfSight = false
	trickPrompt.MaxActivationDistance = 10
	trickPrompt.Parent = body

	kam.PrimaryPart = body
	return kam, petPrompt, trickPrompt
end

local function getCoinsValue(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end
	return leaderstats:FindFirstChild("Coins")
end

local function ensureCompanionValues(player)
	local companions = player:FindFirstChild("Companions")
	if not companions then
		companions = Instance.new("Folder")
		companions.Name = "Companions"
		companions.Parent = player
	end

	local friendshipValue = companions:FindFirstChild("KamFriendship")
	if not friendshipValue then
		friendshipValue = Instance.new("IntValue")
		friendshipValue.Name = "KamFriendship"
		friendshipValue.Value = 0
		friendshipValue.Parent = companions
	end

	local levelValue = companions:FindFirstChild("KamLevel")
	if not levelValue then
		levelValue = Instance.new("IntValue")
		levelValue.Name = "KamLevel"
		levelValue.Value = 0
		levelValue.Parent = companions
	end

	return friendshipValue, levelValue
end

local function getFriendshipLevel(points)
	local level = 0
	for index, threshold in ipairs(levelThresholds) do
		if points >= threshold then
			level = index
		end
	end
	return level
end

local function getNearestPlayerPosition(origin)
	local nearestDistance = FOLLOW_RANGE
	local nearestPosition = nil

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if root and humanoid and humanoid.Health > 0 then
				local distance = (root.Position - origin).Magnitude
				if distance < nearestDistance then
					nearestDistance = distance
					nearestPosition = root.Position
				end
			end
		end
	end

	return nearestPosition
end

local _, homePart = ensureArcadeAndHome()
local kamModel = workspace:FindFirstChild(KAM_NAME)
local petPrompt
local trickPrompt

if not kamModel or not kamModel:IsA("Model") or not kamModel.PrimaryPart then
	if kamModel then
		kamModel:Destroy()
	end
	kamModel, petPrompt, trickPrompt = createKamModel(homePart.Position + Vector3.new(0, 0, 2))
else
	petPrompt = kamModel.PrimaryPart:FindFirstChild("PetPrompt")
	trickPrompt = kamModel.PrimaryPart:FindFirstChild("TrickPrompt")
end

local primary = kamModel.PrimaryPart
local nameTagText = primary:FindFirstChild("NameTag") and primary.NameTag:FindFirstChild("NameText")

local offsets = {}
for _, child in ipairs(kamModel:GetChildren()) do
	if child:IsA("BasePart") then
		offsets[child] = primary.CFrame:ToObjectSpace(child.CFrame)
	end
end

local barkLines = {
	"*happy bark*",
	"Kam wags tail!",
	"Kam found a plushie scent.",
	"Kam says: boof!",
}

local trickLines = {
	Sit = "Kam sits nicely.",
	Spin = "Kam spins in style!",
	Fetch = "Kam chases a toy!",
}

local function updateKamDisplay()
	local highestLevel = 0
	for _, stats in pairs(playerFriendship) do
		if stats.Level > highestLevel then
			highestLevel = stats.Level
		end
	end

	if nameTagText then
		nameTagText.Text = string.format("Kam Lv%d", highestLevel)
	end
end

local function ensurePlayerStats(player)
	local stats = playerFriendship[player]
	if not stats then
		stats = {
			Points = 0,
			Level = 0,
			LastPetAt = 0,
			NextTrickIndex = 1,
		}
		playerFriendship[player] = stats
	end

	local friendshipValue, levelValue = ensureCompanionValues(player)
	stats.Points = friendshipValue.Value
	stats.Level = levelValue.Value

	return stats, friendshipValue, levelValue
end

local function sendMessage(player, text, kind)
	if arcadeMessage then
		arcadeMessage:FireClient(player, {
			Kind = kind or "KamUpdate",
			Text = text,
		})
	end
end

local function awardKamLevelRewards(player, oldLevel, newLevel)
	local coins = getCoinsValue(player)
	local totalReward = 0

	for level = oldLevel + 1, newLevel do
		totalReward += levelCoinRewards[level] or 0
	end

	if coins and totalReward > 0 then
		coins.Value += totalReward
	end

	if totalReward > 0 then
		sendMessage(player, string.format("Kam leveled up to Lv%d. Bonus +%d coins!", newLevel, totalReward), "KamLevelUp")
	end
end

local function triggerTrick(player, trickName)
	local now = os.clock()
	if activeTrick.Type and now < activeTrick.EndsAt then
		sendMessage(player, "Kam is still doing a trick.", "Error")
		return
	end

	if trickName == "Sit" then
		activeTrick = {
			Type = "Sit",
			EndsAt = now + 2.2,
			Data = {},
		}
	elseif trickName == "Spin" then
		activeTrick = {
			Type = "Spin",
			EndsAt = now + 2.0,
			Data = {},
		}
	elseif trickName == "Fetch" then
		local targetPosition
		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				targetPosition = root.Position + root.CFrame.LookVector * 10
			end
		end
		targetPosition = targetPosition or (primary.Position + Vector3.new(6, 0, 0))

		activeTrick = {
			Type = "Fetch",
			EndsAt = now + 4.4,
			Data = {
				TargetPosition = targetPosition,
				ReturnPosition = homePart.Position + Vector3.new(0, 2.2, 0),
				Returning = false,
			},
		}
	end

	local line = trickLines[trickName] or "Kam does a trick!"
	pcall(function()
		Chat:Chat(primary, line, Enum.ChatColor.Blue)
	end)
	sendMessage(player, "Kam used trick: " .. trickName, "KamTrick")
end

if petPrompt then
	petPrompt.Triggered:Connect(function(player)
		local now = os.clock()
		local stats, friendshipValue, levelValue = ensurePlayerStats(player)
		local elapsed = now - stats.LastPetAt
		if elapsed < petCooldownSeconds then
			local secondsLeft = math.ceil(petCooldownSeconds - elapsed)
			sendMessage(player, "Kam needs a moment before more pets (" .. secondsLeft .. "s).", "Error")
			return
		end

		stats.LastPetAt = now
		stats.Points += 1
		friendshipValue.Value = stats.Points

		local oldLevel = stats.Level
		local newLevel = getFriendshipLevel(stats.Points)
		stats.Level = newLevel
		levelValue.Value = newLevel

		if newLevel > oldLevel then
			awardKamLevelRewards(player, oldLevel, newLevel)
		else
			sendMessage(player, string.format("Kam friendship: %d points.", stats.Points), "KamUpdate")
		end

		local line = barkLines[math.random(1, #barkLines)]
		pcall(function()
			Chat:Chat(primary, line, Enum.ChatColor.Blue)
		end)
		updateKamDisplay()
	end)
end

if trickPrompt then
	trickPrompt.Triggered:Connect(function(player)
		local stats = ensurePlayerStats(player)
		local unlockedCount = math.clamp(stats.Level, 1, #trickCycle)
		local trickIndex = math.clamp(stats.NextTrickIndex, 1, unlockedCount)
		local trickName = trickCycle[trickIndex]

		stats.NextTrickIndex += 1
		if stats.NextTrickIndex > unlockedCount then
			stats.NextTrickIndex = 1
		end

		triggerTrick(player, trickName)
	end)
end

Players.PlayerAdded:Connect(function(player)
	ensurePlayerStats(player)
	updateKamDisplay()
end)

Players.PlayerRemoving:Connect(function(player)
	playerFriendship[player] = nil
	updateKamDisplay()
end)

for _, player in ipairs(Players:GetPlayers()) do
	ensurePlayerStats(player)
end
updateKamDisplay()

local wagTimer = 0
RunService.Heartbeat:Connect(function(deltaTime)
	if not kamModel or not primary then
		return
	end

	local currentPos = primary.Position
	local target = nil
	local now = os.clock()

	if activeTrick.Type == "Fetch" and now < activeTrick.EndsAt then
		local fetchData = activeTrick.Data
		if fetchData.Returning then
			target = fetchData.ReturnPosition
		else
			target = fetchData.TargetPosition
			if (Vector3.new(target.X, 0, target.Z) - Vector3.new(currentPos.X, 0, currentPos.Z)).Magnitude < 2.5 then
				fetchData.Returning = true
			end
		end
	end

	if not target then
		target = getNearestPlayerPosition(currentPos)
	end
	if not target then
		target = homePart.Position + Vector3.new(0, 2.2, 0)
	end

	local flatDirection = Vector3.new(target.X - currentPos.X, 0, target.Z - currentPos.Z)
	local distance = flatDirection.Magnitude
	local desiredPos = currentPos

	if distance > STOP_DISTANCE and (activeTrick.Type ~= "Sit" or now >= activeTrick.EndsAt) then
		local step = math.min(distance, FOLLOW_SPEED * deltaTime)
		desiredPos += flatDirection.Unit * step
	end

	wagTimer += deltaTime
	local tailWagAngle = math.sin(wagTimer * 10) * math.rad(22)
	local lookVector = flatDirection.Magnitude > 0.02 and flatDirection.Unit or primary.CFrame.LookVector

	if activeTrick.Type == "Spin" and now < activeTrick.EndsAt then
		local spinAngle = (now * 12) % (math.pi * 2)
		lookVector = Vector3.new(math.sin(spinAngle), 0, math.cos(spinAngle))
	end

	local targetCFrame = CFrame.lookAt(desiredPos, desiredPos + lookVector)
	local sitDepth = 0
	if activeTrick.Type == "Sit" and now < activeTrick.EndsAt then
		sitDepth = -1.0
	elseif activeTrick.Type and now >= activeTrick.EndsAt then
		activeTrick = {
			Type = nil,
			EndsAt = 0,
			Data = {},
		}
	end

	for part, offset in pairs(offsets) do
		if part and part.Parent == kamModel then
			local transformedOffset = offset
			if part.Name == "Tail" then
				transformedOffset *= CFrame.Angles(0, tailWagAngle, 0)
			end
			if sitDepth ~= 0 then
				transformedOffset *= CFrame.new(0, sitDepth, 0)
			end
			part.CFrame = targetCFrame * transformedOffset
		end
	end
end)
