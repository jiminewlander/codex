local AvatarConfig = {}

AvatarConfig.RequestEventName = "AvatarChangeRequest"
AvatarConfig.ResultEventName = "AvatarChangeResult"

AvatarConfig.Order = {
	"Hair",
	"Outfit",
	"Accessories",
}

AvatarConfig.Categories = {
	Hair = {
		FolderName = "Hair",
		ButtonText = "Change Hair",
	},
	Outfit = {
		FolderName = "Outfits",
		ButtonText = "Change Outfit",
	},
	Accessories = {
		FolderName = "Accessories",
		ButtonText = "Change Accessories",
	},
}

return AvatarConfig
