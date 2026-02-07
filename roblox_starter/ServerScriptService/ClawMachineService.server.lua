local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClawMachineConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ClawMachineConfig"))

local randomizer = Random.new()
local cooldownUntil = {}

local remotes = ReplicatedStorage:FindFirstChild("ArcadeRemotes") or Instance.new("Folder")
remotes.Name = "ArcadeRemotes"
remotes.Parent = ReplicatedStorage

local prizeWonEvent = remotes:FindFirstChild("PrizeWon")
if not prizeWonEvent then
	prizeWonEvent = Instance.new("RemoteEvent")
	prizeWonEvent.Name = "PrizeWon"
	prizeWonEvent.Parent = remotes
end

local function getOrCreateInventoryFolder(player)
	local folder = player:FindFirstChild("PrizeInventory")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "PrizeInventory"
		folder.Parent = player
	end
	return folder
end

local function setAnchoredRecursive(instance, anchored)
	if instance:IsA("BasePart") then
		instance.Anchored = anchored
		instance.CanCollide = false
	end
	for _, child in ipairs(instance:GetDescendants()) do
		if child:IsA("BasePart") then
			child.Anchored = anchored
			child.CanCollide = false
		end
	end
end

local function pivotInstance(instance, cframe)
	if instance:IsA("Model") then
		if not instance.PrimaryPart then
			instance.PrimaryPart = instance:FindFirstChildWhichIsA("BasePart")
		end
		if instance.PrimaryPart then
			instance:PivotTo(cframe)
		end
	elseif instance:IsA("BasePart") then
		instance.CFrame = cframe
	end
end

local function addPrizeToInventory(player, prizeName)
	local inventory = getOrCreateInventoryFolder(player)
	local entry = inventory:FindFirstChild(prizeName)
	if not entry then
		entry = Instance.new("IntValue")
		entry.Name = prizeName
		entry.Value = 0
		entry.Parent = inventory
	end
	entry.Value += 1
end

local function startTemporaryFollower(player, prizeTemplate, durationSeconds)
	if durationSeconds <= 0 then
		return
	end

	local follower = prizeTemplate:Clone()
	follower.Name = prizeTemplate.Name .. "_Follower"
	follower.Parent = workspace
	setAnchoredRecursive(follower, true)

	local finishAt = os.clock() + durationSeconds

	task.spawn(function()
		while os.clock() < finishAt and follower.Parent do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not root then
				break
			end

			local target = root.CFrame * CFrame.new(2, 1.5, 4)
			pivotInstance(follower, target)
			task.wait(0.1)
		end

		if follower.Parent then
			follower:Destroy()
		end
	end)
end

local function chooseRandomPrize(folder)
	local options = folder:GetChildren()
	if #options == 0 then
		return nil
	end
	return options[randomizer:NextInteger(1, #options)]
end

local function playMachine(player, machineName, machineModel)
	local machineData = ClawMachineConfig.GetMachine(machineName)
	if not machineData then
		return
	end

	local key = tostring(player.UserId) .. "_" .. machineName
	local now = os.clock()
	local readyAt = cooldownUntil[key] or 0
	if now < readyAt then
		local waitTime = math.ceil(readyAt - now)
		prizeWonEvent:FireClient(player, {
			Text = "Machine cooling down... " .. tostring(waitTime) .. "s",
			Kind = "Cooldown",
		})
		return
	end
	cooldownUntil[key] = now + machineData.CooldownSeconds

	local prizesFolder = ReplicatedStorage:FindFirstChild("Prizes")
	if not prizesFolder then
		return
	end
	local machinePrizeFolder = prizesFolder:FindFirstChild(machineData.PrizeFolder)
	if not machinePrizeFolder then
		prizeWonEvent:FireClient(player, {
			Text = "No prizes in " .. machineData.PrizeFolder .. " yet.",
			Kind = "Warning",
		})
		return
	end

	-- To add more prizes later: put more Models into
	-- ReplicatedStorage/Prizes/Pets or ReplicatedStorage/Prizes/Plushies.
	local selectedPrize = chooseRandomPrize(machinePrizeFolder)
	if not selectedPrize then
		prizeWonEvent:FireClient(player, {
			Text = "This machine is empty right now.",
			Kind = "Warning",
		})
		return
	end

	addPrizeToInventory(player, selectedPrize.Name)

	local spawnPart = machineModel:FindFirstChild("PrizeSpawn")
	if spawnPart and spawnPart:IsA("BasePart") then
		local visualPrize = selectedPrize:Clone()
		visualPrize.Name = selectedPrize.Name .. "_Visual"
		visualPrize.Parent = workspace
		setAnchoredRecursive(visualPrize, true)
		pivotInstance(visualPrize, spawnPart.CFrame * CFrame.new(0, 1.5, 0))
		Debris:AddItem(visualPrize, 8)
	end

	startTemporaryFollower(player, selectedPrize, machineData.FollowWinnerForSeconds)

	prizeWonEvent:FireClient(player, {
		Text = "You won: " .. selectedPrize.Name,
		PrizeName = selectedPrize.Name,
		Machine = machineData.DisplayName,
		Rarity = selectedPrize:GetAttribute("Rarity") or "Common",
		Kind = "Prize",
	})
end

Players.PlayerAdded:Connect(function(player)
	getOrCreateInventoryFolder(player)
end)

local arcade = workspace:WaitForChild("NeonArcade")
local machinesFolder = arcade:WaitForChild("Machines")

for machineName, _ in pairs(ClawMachineConfig.Machines) do
	local machineModel = machinesFolder:WaitForChild(machineName)
	local prompt = machineModel:FindFirstChild("PlayPrompt", true)
	if prompt and prompt:IsA("ProximityPrompt") then
		prompt.Triggered:Connect(function(player)
			if player and player:IsA("Player") then
				playMachine(player, machineName, machineModel)
			end
		end)
	end
end
