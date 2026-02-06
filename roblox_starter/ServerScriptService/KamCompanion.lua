local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")

local KAM_NAME = "Kam"
local FOLLOW_RANGE = 60
local STOP_DISTANCE = 6
local FOLLOW_SPEED = 12

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
	label.Size = UDim2.fromOffset(140, 40)
	label.StudsOffset = Vector3.new(0, 3.8, 0)
	label.AlwaysOnTop = true
	label.Parent = body

	local nameText = Instance.new("TextLabel")
	nameText.BackgroundTransparency = 1
	nameText.Size = UDim2.fromScale(1, 1)
	nameText.Text = "Kam"
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

	kam.PrimaryPart = body
	return kam, petPrompt
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

if not kamModel or not kamModel:IsA("Model") or not kamModel.PrimaryPart then
	if kamModel then
		kamModel:Destroy()
	end
	kamModel, petPrompt = createKamModel(homePart.Position + Vector3.new(0, 0, 2))
else
	petPrompt = kamModel.PrimaryPart:FindFirstChild("PetPrompt")
	if not petPrompt then
		petPrompt = Instance.new("ProximityPrompt")
		petPrompt.Name = "PetPrompt"
		petPrompt.ActionText = "Pet Kam"
		petPrompt.ObjectText = "Chocolate Lab"
		petPrompt.KeyboardKeyCode = Enum.KeyCode.E
		petPrompt.HoldDuration = 0.15
		petPrompt.RequiresLineOfSight = false
		petPrompt.MaxActivationDistance = 10
		petPrompt.Parent = kamModel.PrimaryPart
	end
end

local primary = kamModel.PrimaryPart
local offsets = {}
for _, child in ipairs(kamModel:GetChildren()) do
	if child:IsA("BasePart") then
		offsets[child] = primary.CFrame:ToObjectSpace(child.CFrame)
	end
end

local wagTimer = 0
local barkLines = {
	"*happy bark*",
	"Kam wags tail!",
	"Kam found a plushie scent.",
	"Kam says: boof!",
}

if petPrompt then
	petPrompt.Triggered:Connect(function(player)
		local line = barkLines[math.random(1, #barkLines)]
		pcall(function()
			Chat:Chat(primary, line, Enum.ChatColor.Blue)
		end)
	end)
end

RunService.Heartbeat:Connect(function(deltaTime)
	if not kamModel or not primary then
		return
	end

	local currentPos = primary.Position
	local target = getNearestPlayerPosition(currentPos)
	if not target then
		target = homePart.Position + Vector3.new(0, 2.2, 0)
	end

	local flatDirection = Vector3.new(target.X - currentPos.X, 0, target.Z - currentPos.Z)
	local distance = flatDirection.Magnitude
	local desiredPos = currentPos

	if distance > STOP_DISTANCE then
		local step = math.min(distance, FOLLOW_SPEED * deltaTime)
		desiredPos += flatDirection.Unit * step
	end

	wagTimer += deltaTime
	local tailWagAngle = math.sin(wagTimer * 10) * math.rad(22)
	local lookVector = flatDirection.Magnitude > 0.02 and flatDirection.Unit or primary.CFrame.LookVector
	local targetCFrame = CFrame.lookAt(desiredPos, desiredPos + lookVector)

	for part, offset in pairs(offsets) do
		if part and part.Parent == kamModel then
			local transformedOffset = offset
			if part.Name == "Tail" then
				transformedOffset *= CFrame.Angles(0, tailWagAngle, 0)
			end
			part.CFrame = targetCFrame * transformedOffset
		end
	end
end)
