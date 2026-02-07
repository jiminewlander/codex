local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClawMachineConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ClawMachineConfig"))

local randomizer = Random.new()
local cooldownUntil = {}
local machineBusy = {}

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

local function getPrizeWeight(prize)
	local explicitWeight = prize:GetAttribute("Weight")
	if typeof(explicitWeight) == "number" and explicitWeight > 0 then
		return explicitWeight
	end

	local rarity = prize:GetAttribute("Rarity")
	if rarity == "Legendary" then
		return 0.5
	elseif rarity == "Epic" then
		return 1.2
	elseif rarity == "Rare" then
		return 2.8
	end
	return 5
end

local function chooseRandomPrize(folder)
	local options = {}
	local totalWeight = 0

	for _, child in ipairs(folder:GetChildren()) do
		local weight = getPrizeWeight(child)
		totalWeight += weight
		table.insert(options, {
			Prize = child,
			Weight = weight,
		})
	end

	if #options == 0 then
		return nil
	end

	local roll = randomizer:NextNumber(0, totalWeight)
	local running = 0
	for _, option in ipairs(options) do
		running += option.Weight
		if roll <= running then
			return option.Prize
		end
	end

	return options[#options].Prize
end

local function getClawRig(machineModel)
	local rig = machineModel:FindFirstChild("ClawRig")
	if not rig then
		return nil
	end

	local carriage = rig:FindFirstChild("Carriage")
	local clawString = rig:FindFirstChild("ClawString")
	local clawHead = rig:FindFirstChild("ClawHead")
	local homeMarker = rig:FindFirstChild("HomeMarker")
	local dropZone = rig:FindFirstChild("DropZone")
	if not (carriage and clawString and clawHead and homeMarker and dropZone) then
		return nil
	end

	return {
		Rig = rig,
		Carriage = carriage,
		ClawString = clawString,
		ClawHead = clawHead,
		HomeMarker = homeMarker,
		DropZone = dropZone,
		LeftProng = rig:FindFirstChild("LeftProng"),
		RightProng = rig:FindFirstChild("RightProng"),
		BackProng = rig:FindFirstChild("BackProng"),
	}
end

local function setRigPose(rigParts, carriagePosition, dropAmount)
	dropAmount = math.max(0, dropAmount)
	local stringLength = 1.4 + dropAmount

	rigParts.Carriage.CFrame = CFrame.new(carriagePosition)
	rigParts.ClawString.Size = Vector3.new(0.14, stringLength, 0.14)
	rigParts.ClawString.CFrame = CFrame.new(carriagePosition - Vector3.new(0, (stringLength / 2) + 0.25, 0))

	local clawHeadPosition = carriagePosition - Vector3.new(0, stringLength + 0.35, 0)
	rigParts.ClawHead.CFrame = CFrame.new(clawHeadPosition)

	if rigParts.LeftProng then
		rigParts.LeftProng.CFrame = CFrame.new(clawHeadPosition + Vector3.new(-0.32, -0.42, 0.18))
	end
	if rigParts.RightProng then
		rigParts.RightProng.CFrame = CFrame.new(clawHeadPosition + Vector3.new(0.32, -0.42, 0.18))
	end
	if rigParts.BackProng then
		rigParts.BackProng.CFrame = CFrame.new(clawHeadPosition + Vector3.new(0, -0.42, -0.28))
	end
end

local function animateSegment(durationSeconds, updateFn)
	local startTime = os.clock()
	while true do
		local elapsed = os.clock() - startTime
		local alpha = math.clamp(elapsed / durationSeconds, 0, 1)
		updateFn(alpha)
		if alpha >= 1 then
			break
		end
		RunService.Heartbeat:Wait()
	end
end

local function placeGrabbedPrizeNearClaw(grabbedPrize, clawHead)
	if not grabbedPrize then
		return
	end
	pivotInstance(grabbedPrize, clawHead.CFrame * CFrame.new(0, -0.85, 0))
end

local function runClawAnimation(machineModel, machineData, selectedPrize, didWin)
	local rigParts = getClawRig(machineModel)
	if not rigParts then
		return nil
	end

	local homePosition = rigParts.HomeMarker.Position
	local zone = rigParts.DropZone
	local xOffset = randomizer:NextNumber(-(zone.Size.X / 2) + 0.6, (zone.Size.X / 2) - 0.6)
	local zOffset = randomizer:NextNumber(-(zone.Size.Z / 2) + 0.4, (zone.Size.Z / 2) - 0.4)
	local targetPosition = (zone.CFrame * CFrame.new(xOffset, 0, zOffset)).Position
	local targetTopPosition = Vector3.new(targetPosition.X, homePosition.Y, targetPosition.Z)

	local maxDrop = randomizer:NextNumber(2.6, 3.8)

	local grabbedPrize
	setRigPose(rigParts, homePosition, 0)

	animateSegment(machineData.HorizontalMoveSeconds or 0.8, function(alpha)
		local eased = math.sin(alpha * math.pi * 0.5)
		local current = homePosition:Lerp(targetTopPosition, eased)
		setRigPose(rigParts, current, 0)
		placeGrabbedPrizeNearClaw(grabbedPrize, rigParts.ClawHead)
	end)

	animateSegment(machineData.DropSeconds or 0.6, function(alpha)
		local eased = alpha * alpha
		setRigPose(rigParts, targetTopPosition, maxDrop * eased)
		placeGrabbedPrizeNearClaw(grabbedPrize, rigParts.ClawHead)
	end)

	if didWin and selectedPrize then
		grabbedPrize = selectedPrize:Clone()
		grabbedPrize.Name = selectedPrize.Name .. "_Grabbed"
		grabbedPrize.Parent = workspace
		setAnchoredRecursive(grabbedPrize, true)
		placeGrabbedPrizeNearClaw(grabbedPrize, rigParts.ClawHead)
	end

	animateSegment(machineData.DropSeconds or 0.6, function(alpha)
		local eased = 1 - ((1 - alpha) * (1 - alpha))
		setRigPose(rigParts, targetTopPosition, maxDrop * (1 - eased))
		placeGrabbedPrizeNearClaw(grabbedPrize, rigParts.ClawHead)
	end)

	animateSegment(machineData.ReturnSeconds or 0.75, function(alpha)
		local eased = math.sin(alpha * math.pi * 0.5)
		local current = targetTopPosition:Lerp(homePosition, eased)
		setRigPose(rigParts, current, 0)
		placeGrabbedPrizeNearClaw(grabbedPrize, rigParts.ClawHead)
	end)

	setRigPose(rigParts, homePosition, 0)
	return grabbedPrize
end

local function playMachine(player, machineName, machineModel)
	local machineData = ClawMachineConfig.GetMachine(machineName)
	if not machineData then
		return
	end

	if machineBusy[machineModel] then
		prizeWonEvent:FireClient(player, {
			Text = "This claw machine is busy. Try again in a moment.",
			Kind = "Busy",
		})
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
	cooldownUntil[key] = now + (machineData.CooldownSeconds or 2.5)
	machineBusy[machineModel] = true

	local prizesFolder = ReplicatedStorage:FindFirstChild("Prizes")
	if not prizesFolder then
		machineBusy[machineModel] = nil
		return
	end

	local machinePrizeFolder = prizesFolder:FindFirstChild(machineData.PrizeFolder)
	if not machinePrizeFolder then
		machineBusy[machineModel] = nil
		prizeWonEvent:FireClient(player, {
			Text = "No prizes in " .. machineData.PrizeFolder .. " yet.",
			Kind = "Warning",
		})
		return
	end

	-- To add more prizes later: put more Models in
	-- ReplicatedStorage/Prizes/Pets or ReplicatedStorage/Prizes/Plushies.
	-- Optional: set Attributes on each prize model:
	--   Rarity = "Common"/"Rare"/"Epic"/"Legendary"
	--   Weight = number (higher appears more often)
	local selectedPrize = chooseRandomPrize(machinePrizeFolder)
	if not selectedPrize then
		machineBusy[machineModel] = nil
		prizeWonEvent:FireClient(player, {
			Text = "This machine is empty right now.",
			Kind = "Warning",
		})
		return
	end

	prizeWonEvent:FireClient(player, {
		Text = machineData.DisplayName .. " is moving...",
		Kind = "MachineStart",
	})

	local didWin = randomizer:NextNumber() <= (machineData.WinChance or 1)
	local grabbedVisual
	local animationOk, animationError = pcall(function()
		grabbedVisual = runClawAnimation(machineModel, machineData, selectedPrize, didWin)
	end)
	if not animationOk then
		warn("Claw animation failed: " .. tostring(animationError))
	end

	if didWin then
		addPrizeToInventory(player, selectedPrize.Name)
		startTemporaryFollower(player, selectedPrize, machineData.FollowWinnerForSeconds or 0)

		local spawnPart = machineModel:FindFirstChild("PrizeSpawn")
		if grabbedVisual and spawnPart and spawnPart:IsA("BasePart") then
			pivotInstance(grabbedVisual, spawnPart.CFrame * CFrame.new(0, 1.4, 0))
			Debris:AddItem(grabbedVisual, 8)
		elseif grabbedVisual then
			grabbedVisual:Destroy()
		end

		prizeWonEvent:FireClient(player, {
			Text = "You won: " .. selectedPrize.Name,
			PrizeName = selectedPrize.Name,
			Machine = machineData.DisplayName,
			Rarity = selectedPrize:GetAttribute("Rarity") or "Common",
			Kind = "Prize",
		})
	else
		if grabbedVisual then
			grabbedVisual:Destroy()
		end
		prizeWonEvent:FireClient(player, {
			Text = "So close! The claw slipped. Try again!",
			Machine = machineData.DisplayName,
			Kind = "Miss",
		})
	end

	machineBusy[machineModel] = nil
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
