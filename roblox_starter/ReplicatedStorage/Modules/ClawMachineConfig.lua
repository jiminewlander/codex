local ClawMachineConfig = {}

-- Add more machines here later if you want.
ClawMachineConfig.Machines = {
	PetClawMachine = {
		DisplayName = "Pets Claw",
		PrizeFolder = "Pets",
		CooldownSeconds = 2.5,
		FollowWinnerForSeconds = 12,
	},
	PlushieClawMachine = {
		DisplayName = "Plushies Claw",
		PrizeFolder = "Plushies",
		CooldownSeconds = 2.5,
		FollowWinnerForSeconds = 0,
	},
}

function ClawMachineConfig.GetMachine(machineName)
	return ClawMachineConfig.Machines[machineName]
end

return ClawMachineConfig
