local ArcadeConfig = {}

ArcadeConfig.StartingCoins = 150

ArcadeConfig.Admin = {
	-- Add your Roblox UserId(s) here for in-game admin controls.
	AllowedUserIds = {},
	AllowAllInStudio = true,
}

ArcadeConfig.Machines = {
	Pets = {
		Cost = 25,
		Rewards = {
			{ Name = "Neon Kitty", Rarity = "Common", Weight = 42 },
			{ Name = "Rhythm Bunny", Rarity = "Common", Weight = 28 },
			{ Name = "Glow Fox", Rarity = "Rare", Weight = 18 },
			{ Name = "Beat Dragon", Rarity = "Epic", Weight = 9 },
			{ Name = "Star Tiger", Rarity = "Legendary", Weight = 3 },
		},
	},
	Plushies = {
		Cost = 20,
		Rewards = {
			{ Name = "Pixel Heart Plush", Rarity = "Common", Weight = 40 },
			{ Name = "Arcade Bear Plush", Rarity = "Common", Weight = 30 },
			{ Name = "Neon Mic Plush", Rarity = "Rare", Weight = 17 },
			{ Name = "Retro Boombox Plush", Rarity = "Epic", Weight = 10 },
			{ Name = "Galaxy Crown Plush", Rarity = "Legendary", Weight = 3 },
		},
	},
}

ArcadeConfig.Kam = {
	PetCooldownSeconds = 4,
	LevelThresholds = { 5, 14, 28, 45 },
	LevelCoinRewards = { 15, 30, 55, 90 },
	TrickCycle = { "Sit", "Spin", "Fetch" },
}

ArcadeConfig.Polish = {
	AmbientSoundId = "rbxasset://sounds/electronicpingshort.wav",
	AmbientVolume = 0.08,
	AmbientPlaybackSpeed = 0.65,
	RareWinConfettiBursts = {
		Epic = 35,
		Legendary = 65,
	},
}

-- Replace IDs with catalog assets you want to use.
ArcadeConfig.AvatarPresets = {
	{
		Key = "NeonIdol",
		DisplayName = "Neon Idol",
		ShirtId = 0,
		PantsId = 0,
		HatAccessoryIds = {},
		FaceAccessoryIds = {},
		RunSpeed = 18,
		JumpPower = 55,
	},
	{
		Key = "ArcadeHunter",
		DisplayName = "Arcade Hunter",
		ShirtId = 0,
		PantsId = 0,
		HatAccessoryIds = {},
		FaceAccessoryIds = {},
		RunSpeed = 19,
		JumpPower = 60,
	},
	{
		Key = "KPopHero",
		DisplayName = "K-Pop Hero",
		ShirtId = 0,
		PantsId = 0,
		HatAccessoryIds = {},
		FaceAccessoryIds = {},
		RunSpeed = 20,
		JumpPower = 62,
	},
}

return ArcadeConfig
