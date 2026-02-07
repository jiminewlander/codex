local ClawMachineConfig = {}

-- Add more machines here later if you want.
ClawMachineConfig.Machines = {
	PetClawMachine = {
		DisplayName = "Pets Claw",
		PrizeFolder = "Pets",
		CooldownSeconds = 2.5,
		WinChance = 0.88,
		HorizontalMoveSeconds = 0.85,
		DropSeconds = 0.65,
		ReturnSeconds = 0.75,
		FollowWinnerForSeconds = 12,
	},
	PlushieClawMachine = {
		DisplayName = "Plushies Claw",
		PrizeFolder = "Plushies",
		CooldownSeconds = 2.5,
		WinChance = 0.9,
		HorizontalMoveSeconds = 0.8,
		DropSeconds = 0.6,
		ReturnSeconds = 0.75,
		FollowWinnerForSeconds = 0,
	},
}

function ClawMachineConfig.GetMachine(machineName)
	return ClawMachineConfig.Machines[machineName]
end

return ClawMachineConfig
