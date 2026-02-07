local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PET_NAME = "Kam"
local FOLLOW_SIDE_OFFSET = 3
local FOLLOW_BACK_OFFSET = 5
local FOLLOW_HEIGHT_OFFSET = -2
local FOLLOW_SMOOTHNESS = 0.22
local IDLE_DISTANCE = 8
local TELEPORT_DISTANCE = 45
local IDLE_SIT_DROP = 0.4

local activePets = {}

local function setModelCollision(model, canCollide)
	for _, child in ipairs(model:GetDescendants()) do
		if child:IsA("BasePart") then
			child.CanCollide = canCollide
			child.Anchored = true
		end
	end
end

local function placeKamParts(kamModel, rootCFrame, wagAngle)
	local root = kamModel:FindFirstChild("Root")
	if not (root and root:IsA("BasePart")) then
		return
	end

	local body = kamModel:FindFirstChild("Body")
	local head = kamModel:FindFirstChild("Head")
	local tail = kamModel:FindFirstChild("Tail")
	local leftEar = kamModel:FindFirstChild("LeftEar")
	local rightEar = kamModel:FindFirstChild("RightEar")

	root.CFrame = rootCFrame

	if body and body:IsA("BasePart") then
		body.CFrame = rootCFrame * CFrame.new(0, 0, 0)
	end

	if head and head:IsA("BasePart") then
		head.CFrame = rootCFrame * CFrame.new(0, 0.25, 2)
	end

	if leftEar and leftEar:IsA("BasePart") then
		leftEar.CFrame = rootCFrame * CFrame.new(-0.55, 1.0, 1.8)
	end

	if rightEar and rightEar:IsA("BasePart") then
		rightEar.CFrame = rootCFrame * CFrame.new(0.55, 1.0, 1.8)
	end

	if tail and tail:IsA("BasePart") then
		tail.CFrame = rootCFrame * CFrame.new(0, 0.25, -1.7) * CFrame.Angles(0, wagAngle, 0)
	end
end

local function destroyPetForPlayer(player)
	local pet = activePets[player]
	if pet and pet.Parent then
		pet:Destroy()
	end
	activePets[player] = nil
end

local function startFollowLoop(player, character, kamModel)
	task.spawn(function()
		local wagClock = 0

		while activePets[player] == kamModel and player.Parent do
			if not character.Parent then
				break
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local root = kamModel:FindFirstChild("Root")
			if not (humanoidRootPart and root and root:IsA("BasePart")) then
				break
			end

			local desiredPosition = humanoidRootPart.CFrame * CFrame.new(FOLLOW_SIDE_OFFSET, FOLLOW_HEIGHT_OFFSET, FOLLOW_BACK_OFFSET)
			local lookCFrame = CFrame.lookAt(desiredPosition.Position, humanoidRootPart.Position)

			local distanceFromTarget = (root.Position - desiredPosition.Position).Magnitude
			if distanceFromTarget > TELEPORT_DISTANCE then
				placeKamParts(kamModel, lookCFrame, 0)
			else
				local distanceFromPlayer = (root.Position - humanoidRootPart.Position).Magnitude
				local sitOffset = distanceFromPlayer <= IDLE_DISTANCE and IDLE_SIT_DROP or 0
				local finalTarget = lookCFrame * CFrame.new(0, -sitOffset, 0)
				local nextCFrame = root.CFrame:Lerp(finalTarget, FOLLOW_SMOOTHNESS)

				wagClock += 0.3
				local wagStrength = distanceFromPlayer <= IDLE_DISTANCE and 0.7 or 0.2
				local wagAngle = math.sin(wagClock * 4) * wagStrength
				placeKamParts(kamModel, nextCFrame, wagAngle)
			end

			-- TODO: Replace procedural sit/tail wag with real animation tracks.
			-- 1) Import a rigged dog model.
			-- 2) Put animation IDs in Kam/Animations/Sit and Kam/Animations/TailWag.
			-- 3) Load and play those tracks here instead.

			task.wait(0.1)
		end

		if activePets[player] == kamModel then
			destroyPetForPlayer(player)
		end
	end)
end

local function spawnPetForPlayer(player, character)
	destroyPetForPlayer(player)

	local petsFolder = ReplicatedStorage:WaitForChild("Pets")
	local kamTemplate = petsFolder:WaitForChild(PET_NAME)

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	local kamModel = kamTemplate:Clone()
	kamModel.Name = player.Name .. "_Kam"
	kamModel.Parent = workspace
	activePets[player] = kamModel

	setModelCollision(kamModel, false)
	local spawnCFrame = humanoidRootPart.CFrame * CFrame.new(FOLLOW_SIDE_OFFSET, FOLLOW_HEIGHT_OFFSET, FOLLOW_BACK_OFFSET)
	placeKamParts(kamModel, spawnCFrame, 0)

	startFollowLoop(player, character, kamModel)
end

local function onCharacterAdded(player, character)
	character:WaitForChild("HumanoidRootPart", 10)
	task.wait(0.4)
	spawnPetForPlayer(player, character)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	destroyPetForPlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end
