local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ARCADE_NAME = "NeonArcade"

local Colors = {
	NeonPink = Color3.fromRGB(255, 64, 176),
	Teal = Color3.fromRGB(46, 255, 223),
	Purple = Color3.fromRGB(145, 76, 255),
	ElectricBlue = Color3.fromRGB(38, 166, 255),
	Black = Color3.fromRGB(15, 15, 20),
	SoftWhite = Color3.fromRGB(235, 240, 255),
}

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if folder and folder:IsA("Folder") then
		return folder
	end
	if folder then
		folder:Destroy()
	end

	folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function ensureModel(parent, name)
	local model = parent:FindFirstChild(name)
	if model and model:IsA("Model") then
		return model
	end
	if model then
		model:Destroy()
	end

	model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	return model
end

local function ensurePart(parent, name, size, cframe, color, material)
	local part = parent:FindFirstChild(name)
	if not (part and part:IsA("Part")) then
		if part then
			part:Destroy()
		end
		part = Instance.new("Part")
		part.Name = name
		part.Parent = parent
	end

	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	return part
end

local function ensureTextFace(part, text, textColor)
	local surface = part:FindFirstChild("Display")
	if not (surface and surface:IsA("SurfaceGui")) then
		if surface then
			surface:Destroy()
		end
		surface = Instance.new("SurfaceGui")
		surface.Name = "Display"
		surface.Face = Enum.NormalId.Front
		surface.PixelsPerStud = 35
		surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surface.Parent = part
	end

	local label = surface:FindFirstChild("Label")
	if not (label and label:IsA("TextLabel")) then
		if label then
			label:Destroy()
		end
		label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.Parent = surface
	end

	label.Text = text
	label.TextColor3 = textColor
	label.TextStrokeTransparency = 0.2
end

local function ensurePrompt(parent, name, actionText, objectText, keyCode)
	local prompt = parent:FindFirstChild(name)
	if not (prompt and prompt:IsA("ProximityPrompt")) then
		if prompt then
			prompt:Destroy()
		end
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = name
		prompt.Parent = parent
	end

	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.KeyboardKeyCode = keyCode or Enum.KeyCode.E
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 12
	prompt.HoldDuration = 0.2
	return prompt
end

local function clearChildren(parent)
	for _, child in ipairs(parent:GetChildren()) do
		child:Destroy()
	end
end

local function createPrizeModel(parent, modelName, color, shape, rarity)
	if parent:FindFirstChild(modelName) then
		return
	end

	local model = Instance.new("Model")
	model.Name = modelName
	model:SetAttribute("Rarity", rarity or "Common")
	model.Parent = parent

	local core = Instance.new("Part")
	core.Name = "Core"
	core.Size = Vector3.new(1.8, 1.8, 1.8)
	core.Shape = shape or Enum.PartType.Block
	core.Material = Enum.Material.Neon
	core.Color = color
	core.TopSurface = Enum.SurfaceType.Smooth
	core.BottomSurface = Enum.SurfaceType.Smooth
	core.Parent = model

	model.PrimaryPart = core
end

local function createAccessory(folder, name, color)
	if folder:FindFirstChild(name) then
		return
	end

	local accessory = Instance.new("Accessory")
	accessory.Name = name
	accessory.Parent = folder

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(2, 1, 2)
	handle.Color = color
	handle.Material = Enum.Material.Neon
	handle.CanCollide = false
	handle.TopSurface = Enum.SurfaceType.Smooth
	handle.BottomSurface = Enum.SurfaceType.Smooth
	handle.Parent = accessory

	local attachment = Instance.new("Attachment")
	attachment.Name = "HatAttachment"
	attachment.Parent = handle
end

local function createOutfit(folder, name, topColor, bottomColor)
	if folder:FindFirstChild(name) then
		return
	end

	local outfit = Instance.new("Folder")
	outfit.Name = name
	outfit.Parent = folder

	local top = Instance.new("Color3Value")
	top.Name = "TopColor"
	top.Value = topColor
	top.Parent = outfit

	local bottom = Instance.new("Color3Value")
	bottom.Name = "BottomColor"
	bottom.Value = bottomColor
	bottom.Parent = outfit

	-- Optional classic clothing templates. Leave empty until you add your own IDs.
	local shirtTemplate = Instance.new("StringValue")
	shirtTemplate.Name = "ShirtTemplate"
	shirtTemplate.Value = ""
	shirtTemplate.Parent = outfit

	local pantsTemplate = Instance.new("StringValue")
	pantsTemplate.Name = "PantsTemplate"
	pantsTemplate.Value = ""
	pantsTemplate.Parent = outfit
end

local function ensureKamTemplate()
	local petsFolder = ensureFolder(ReplicatedStorage, "Pets")
	local existing = petsFolder:FindFirstChild("Kam")
	if existing and existing:IsA("Model") then
		return
	end
	if existing then
		existing:Destroy()
	end

	local kam = Instance.new("Model")
	kam.Name = "Kam"
	kam.Parent = petsFolder

	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(2, 2, 3)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.Parent = kam

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2.2, 1.6, 3.2)
	body.Color = Color3.fromRGB(102, 67, 39)
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.Parent = kam

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.7, 1.5, 1.8)
	head.Color = Color3.fromRGB(115, 78, 47)
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.Parent = kam

	local tail = Instance.new("Part")
	tail.Name = "Tail"
	tail.Size = Vector3.new(0.4, 0.4, 1.4)
	tail.Color = Color3.fromRGB(88, 58, 33)
	tail.Material = Enum.Material.SmoothPlastic
	tail.Anchored = true
	tail.CanCollide = false
	tail.Parent = kam

	local leftEar = Instance.new("Part")
	leftEar.Name = "LeftEar"
	leftEar.Size = Vector3.new(0.35, 0.9, 0.45)
	leftEar.Color = Color3.fromRGB(80, 54, 31)
	leftEar.Material = Enum.Material.SmoothPlastic
	leftEar.Anchored = true
	leftEar.CanCollide = false
	leftEar.Parent = kam

	local rightEar = leftEar:Clone()
	rightEar.Name = "RightEar"
	rightEar.Parent = kam

	kam.PrimaryPart = root
	kam:PivotTo(CFrame.new(0, 3, 0))

	local nameTag = Instance.new("BillboardGui")
	nameTag.Name = "NameTag"
	nameTag.AlwaysOnTop = true
	nameTag.Size = UDim2.fromOffset(140, 40)
	nameTag.StudsOffset = Vector3.new(0, 2.6, 0)
	nameTag.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Label"
	nameLabel.Size = UDim2.fromScale(1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "Kam"
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.fromRGB(255, 236, 210)
	nameLabel.Parent = nameTag

	local animations = Instance.new("Folder")
	animations.Name = "Animations"
	animations.Parent = kam

	local sitAnimation = Instance.new("Animation")
	sitAnimation.Name = "Sit"
	sitAnimation.AnimationId = "rbxassetid://0"
	sitAnimation.Parent = animations

	local tailAnimation = Instance.new("Animation")
	tailAnimation.Name = "TailWag"
	tailAnimation.AnimationId = "rbxassetid://0"
	tailAnimation.Parent = animations
end

local function ensureReplicatedStorageAssets()
	local remotes = ensureFolder(ReplicatedStorage, "ArcadeRemotes")
	if not remotes:FindFirstChild("PrizeWon") then
		local prizeWon = Instance.new("RemoteEvent")
		prizeWon.Name = "PrizeWon"
		prizeWon.Parent = remotes
	end
	if not remotes:FindFirstChild("AvatarChangeRequest") then
		local request = Instance.new("RemoteEvent")
		request.Name = "AvatarChangeRequest"
		request.Parent = remotes
	end
	if not remotes:FindFirstChild("AvatarChangeResult") then
		local result = Instance.new("RemoteEvent")
		result.Name = "AvatarChangeResult"
		result.Parent = remotes
	end

	local prizes = ensureFolder(ReplicatedStorage, "Prizes")
	local petsPrizes = ensureFolder(prizes, "Pets")
	local plushiePrizes = ensureFolder(prizes, "Plushies")

	createPrizeModel(petsPrizes, "Puppy Pal", Colors.Teal, Enum.PartType.Ball, "Common")
	createPrizeModel(petsPrizes, "Kitten Spark", Colors.NeonPink, Enum.PartType.Ball, "Common")
	createPrizeModel(petsPrizes, "Bunny Beat", Colors.ElectricBlue, Enum.PartType.Block, "Rare")
	createPrizeModel(petsPrizes, "Mini Wolf", Colors.Purple, Enum.PartType.Block, "Epic")

	createPrizeModel(plushiePrizes, "Heart Plush", Colors.NeonPink, Enum.PartType.Block, "Common")
	createPrizeModel(plushiePrizes, "Cloud Plush", Colors.Teal, Enum.PartType.Ball, "Common")
	createPrizeModel(plushiePrizes, "Chibi Hero", Colors.Purple, Enum.PartType.Block, "Rare")
	createPrizeModel(plushiePrizes, "Neon Star Plush", Colors.ElectricBlue, Enum.PartType.Ball, "Epic")

	local avatarItems = ensureFolder(ReplicatedStorage, "AvatarItems")
	local hairFolder = ensureFolder(avatarItems, "Hair")
	local outfitsFolder = ensureFolder(avatarItems, "Outfits")
	local accessoriesFolder = ensureFolder(avatarItems, "Accessories")

	createAccessory(hairFolder, "Bubble Ponytail", Colors.NeonPink)
	createAccessory(hairFolder, "Teal Bob", Colors.Teal)
	createAccessory(hairFolder, "Electric Bangs", Colors.ElectricBlue)

	createAccessory(accessoriesFolder, "Star Glasses", Colors.Purple)
	createAccessory(accessoriesFolder, "Music Headphones", Colors.ElectricBlue)
	createAccessory(accessoriesFolder, "Neon Bow", Colors.NeonPink)

	createOutfit(outfitsFolder, "Arcade Idol", Color3.fromRGB(255, 100, 190), Color3.fromRGB(80, 225, 240))
	createOutfit(outfitsFolder, "Demon Hunter Cute", Color3.fromRGB(130, 90, 255), Color3.fromRGB(30, 30, 45))
	createOutfit(outfitsFolder, "Retro Club", Color3.fromRGB(70, 180, 255), Color3.fromRGB(180, 90, 255))

	ensureKamTemplate()
end

local function createPoster(parent, name, cframe, text, textColor)
	local poster = ensurePart(parent, name, Vector3.new(14, 8, 0.6), cframe, Color3.fromRGB(22, 22, 28), Enum.Material.SmoothPlastic)
	poster.CanCollide = false
	ensureTextFace(poster, text, textColor)
end

local function createArcadeCabinet(parent, name, position, accentColor)
	local cabinet = ensureModel(parent, name)
	clearChildren(cabinet)

	local body = ensurePart(cabinet, "Body", Vector3.new(5, 8, 4), CFrame.new(position + Vector3.new(0, 4, 0)), Colors.Black, Enum.Material.Metal)
	local screen = ensurePart(cabinet, "Screen", Vector3.new(4.2, 3.4, 0.3), CFrame.new(position + Vector3.new(0, 4.8, 2.15)), accentColor, Enum.Material.Neon)
	local marquee = ensurePart(cabinet, "Marquee", Vector3.new(4.5, 0.8, 0.4), CFrame.new(position + Vector3.new(0, 7.8, 2.2)), Colors.SoftWhite, Enum.Material.Neon)
	ensureTextFace(marquee, "BEAT", Colors.Black)

	local buttonPanel = ensurePart(cabinet, "ButtonPanel", Vector3.new(4.2, 0.6, 2.2), CFrame.new(position + Vector3.new(0, 2.2, 1.2)), Color3.fromRGB(35, 35, 45), Enum.Material.SmoothPlastic)
	buttonPanel.CanCollide = false

	local light = body:FindFirstChild("CabinetLight")
	if not (light and light:IsA("PointLight")) then
		if light then
			light:Destroy()
		end
		light = Instance.new("PointLight")
		light.Name = "CabinetLight"
		light.Parent = body
	end
	light.Color = accentColor
	light.Brightness = 2.8
	light.Range = 18

	screen.CanCollide = false
end

local function createClawMachine(parent, name, themeText, position, accentColor)
	local machine = ensureModel(parent, name)
	clearChildren(machine)

	local base = ensurePart(machine, "Base", Vector3.new(10, 12, 8), CFrame.new(position + Vector3.new(0, 6, 0)), Colors.Black, Enum.Material.Metal)
	local glass = ensurePart(machine, "GlassFront", Vector3.new(8.5, 6.5, 0.3), CFrame.new(position + Vector3.new(0, 7, 3.9)), Color3.fromRGB(145, 180, 255), Enum.Material.Glass)
	glass.Transparency = 0.25
	glass.CanCollide = false

	local marquee = ensurePart(machine, "Marquee", Vector3.new(9, 1.2, 0.4), CFrame.new(position + Vector3.new(0, 11.4, 3.8)), accentColor, Enum.Material.Neon)
	ensureTextFace(marquee, themeText, Colors.Black)

	local promptPart = ensurePart(machine, "InteractionPart", Vector3.new(6, 2, 2), CFrame.new(position + Vector3.new(0, 2.2, 4.2)), Colors.Black, Enum.Material.SmoothPlastic)
	promptPart.Transparency = 1
	promptPart.CanCollide = false
	ensurePrompt(promptPart, "PlayPrompt", "Play", themeText, Enum.KeyCode.E)

	local prizeSpawn = ensurePart(machine, "PrizeSpawn", Vector3.new(2, 1, 2), CFrame.new(position + Vector3.new(0, 1.4, 4.1)), Colors.Black, Enum.Material.SmoothPlastic)
	prizeSpawn.Transparency = 1
	prizeSpawn.CanCollide = false

	local light = base:FindFirstChild("MachineLight")
	if not (light and light:IsA("PointLight")) then
		if light then
			light:Destroy()
		end
		light = Instance.new("PointLight")
		light.Name = "MachineLight"
		light.Parent = base
	end
	light.Color = accentColor
	light.Brightness = 3.4
	light.Range = 22
end

local function buildArcadeWorld()
	local arcade = workspace:FindFirstChild(ARCADE_NAME)
	if arcade and not arcade:IsA("Model") then
		arcade:Destroy()
		arcade = nil
	end
	if not arcade then
		arcade = Instance.new("Model")
		arcade.Name = ARCADE_NAME
		arcade.Parent = workspace
	end

	local floor = ensurePart(arcade, "Floor", Vector3.new(120, 1, 120), CFrame.new(0, 0, 0), Color3.fromRGB(10, 10, 15), Enum.Material.SmoothPlastic)
	local ceiling = ensurePart(arcade, "Ceiling", Vector3.new(120, 1, 120), CFrame.new(0, 28, 0), Color3.fromRGB(8, 8, 12), Enum.Material.SmoothPlastic)
	ceiling.CanCollide = false

	ensurePart(arcade, "BackWall", Vector3.new(120, 28, 1), CFrame.new(0, 14, -60), Color3.fromRGB(18, 18, 26), Enum.Material.SmoothPlastic)
	ensurePart(arcade, "FrontWall", Vector3.new(120, 28, 1), CFrame.new(0, 14, 60), Color3.fromRGB(18, 18, 26), Enum.Material.SmoothPlastic)
	ensurePart(arcade, "LeftWall", Vector3.new(1, 28, 120), CFrame.new(-60, 14, 0), Color3.fromRGB(18, 18, 26), Enum.Material.SmoothPlastic)
	ensurePart(arcade, "RightWall", Vector3.new(1, 28, 120), CFrame.new(60, 14, 0), Color3.fromRGB(18, 18, 26), Enum.Material.SmoothPlastic)

	local titleSign = ensurePart(arcade, "TitleSign", Vector3.new(42, 5, 1), CFrame.new(0, 22, -59.4), Colors.NeonPink, Enum.Material.Neon)
	ensureTextFace(titleSign, "K-POP DEMON HUNTER ARCADE", Colors.SoftWhite)

	local glowTiles = ensureFolder(arcade, "GlowTiles")
	clearChildren(glowTiles)

	local tileSpacing = 6
	local tileCount = 6
	for x = -tileCount, tileCount do
		for z = -tileCount, tileCount do
			if math.abs(x) >= 2 or math.abs(z) >= 2 then
				local tile = Instance.new("Part")
				tile.Name = string.format("Tile_%d_%d", x, z)
				tile.Size = Vector3.new(4, 0.2, 4)
				tile.Anchored = true
				tile.CanCollide = false
				tile.Material = Enum.Material.Neon
				tile.Color = ((x + z) % 2 == 0) and Colors.Teal or Colors.Purple
				tile.Transparency = 0.25
				tile.CFrame = CFrame.new(x * tileSpacing, 0.65, z * tileSpacing)
				tile.Parent = glowTiles
			end
		end
	end

	local machinesFolder = ensureFolder(arcade, "Machines")
	clearChildren(machinesFolder)
	createClawMachine(machinesFolder, "PetClawMachine", "Pets Claw", Vector3.new(-20, 0, -10), Colors.Teal)
	createClawMachine(machinesFolder, "PlushieClawMachine", "Plushies Claw", Vector3.new(20, 0, -10), Colors.NeonPink)

	local cabinetsFolder = ensureFolder(arcade, "ArcadeCabinets")
	clearChildren(cabinetsFolder)

	for index = 1, 4 do
		local z = -34 + ((index - 1) * 20)
		createArcadeCabinet(cabinetsFolder, "LeftCabinet" .. index, Vector3.new(-45, 0, z), Colors.ElectricBlue)
		createArcadeCabinet(cabinetsFolder, "RightCabinet" .. index, Vector3.new(45, 0, z), Colors.Purple)
	end

	local lightStrips = ensureFolder(arcade, "LightStrips")
	clearChildren(lightStrips)

	for i = -5, 5 do
		local topFront = Instance.new("Part")
		topFront.Name = "FrontStrip" .. tostring(i + 6)
		topFront.Size = Vector3.new(8, 0.4, 0.4)
		topFront.Anchored = true
		topFront.CanCollide = false
		topFront.Material = Enum.Material.Neon
		topFront.Color = Colors.ElectricBlue
		topFront.CFrame = CFrame.new(i * 10, 26, -58)
		topFront.Parent = lightStrips

		local topBack = topFront:Clone()
		topBack.Name = "BackStrip" .. tostring(i + 6)
		topBack.CFrame = CFrame.new(i * 10, 26, 58)
		topBack.Parent = lightStrips
	end

	for i = -4, 4 do
		local sideLeft = Instance.new("Part")
		sideLeft.Name = "LeftStrip" .. tostring(i + 5)
		sideLeft.Size = Vector3.new(0.4, 0.4, 8)
		sideLeft.Anchored = true
		sideLeft.CanCollide = false
		sideLeft.Material = Enum.Material.Neon
		sideLeft.Color = Colors.NeonPink
		sideLeft.CFrame = CFrame.new(-58, 26, i * 12)
		sideLeft.Parent = lightStrips

		local sideRight = sideLeft:Clone()
		sideRight.Name = "RightStrip" .. tostring(i + 5)
		sideRight.CFrame = CFrame.new(58, 26, i * 12)
		sideRight.Parent = lightStrips
	end

	local mirrorStation = ensurePart(arcade, "MirrorStation", Vector3.new(16, 12, 1), CFrame.new(0, 6, 34), Color3.fromRGB(70, 70, 95), Enum.Material.Glass)
	mirrorStation.Transparency = 0.2
	mirrorStation.Reflectance = 0.08
	mirrorStation.CanCollide = false
	ensureTextFace(mirrorStation, "MIRROR STATION", Colors.SoftWhite)

	local mirrorPromptPart = ensurePart(arcade, "MirrorPromptPart", Vector3.new(4, 2, 4), CFrame.new(0, 1, 30), Colors.Black, Enum.Material.SmoothPlastic)
	mirrorPromptPart.Transparency = 1
	mirrorPromptPart.CanCollide = false
	ensurePrompt(mirrorPromptPart, "MirrorPrompt", "Customize", "Mirror Station", Enum.KeyCode.E)

	createPoster(arcade, "PosterLeft", CFrame.new(-28, 12, -59.2), "DEMON HUNTER\nDANCE BATTLE", Colors.NeonPink)
	createPoster(arcade, "PosterCenter", CFrame.new(0, 12, -59.2), "NEON HEART\nARCADE TOUR", Colors.Teal)
	createPoster(arcade, "PosterRight", CFrame.new(28, 12, -59.2), "CHIBI HUNTERS\nLIVE", Colors.Purple)

	local boombox = ensurePart(arcade, "BoomboxProp", Vector3.new(6, 2.5, 2.4), CFrame.new(0, 1.5, -4), Color3.fromRGB(30, 30, 45), Enum.Material.Metal)
	local boomboxLight = boombox:FindFirstChild("BoomboxLight")
	if not (boomboxLight and boomboxLight:IsA("PointLight")) then
		if boomboxLight then
			boomboxLight:Destroy()
		end
		boomboxLight = Instance.new("PointLight")
		boomboxLight.Name = "BoomboxLight"
		boomboxLight.Parent = boombox
	end
	boomboxLight.Color = Colors.NeonPink
	boomboxLight.Brightness = 2.2
	boomboxLight.Range = 14

	local music = floor:FindFirstChild("ArcadeMusic")
	if not (music and music:IsA("Sound")) then
		if music then
			music:Destroy()
		end
		music = Instance.new("Sound")
		music.Name = "ArcadeMusic"
		music.Parent = floor
	end
	music.Looped = true
	music.Volume = 0.35
	music.SoundId = "rbxassetid://0"
	if music.SoundId ~= "rbxassetid://0" and not music.IsPlaying then
		music:Play()
	end
end

ensureReplicatedStorageAssets()
buildArcadeWorld()
