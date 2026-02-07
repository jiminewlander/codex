local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MirrorAIConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MirrorAIConfig"))

local remotes = ReplicatedStorage:FindFirstChild("ArcadeRemotes") or Instance.new("Folder")
remotes.Name = "ArcadeRemotes"
remotes.Parent = ReplicatedStorage

local requestEvent = remotes:FindFirstChild(MirrorAIConfig.RequestEventName)
if not requestEvent then
	requestEvent = Instance.new("RemoteEvent")
	requestEvent.Name = MirrorAIConfig.RequestEventName
	requestEvent.Parent = remotes
end

local responseEvent = remotes:FindFirstChild(MirrorAIConfig.ResponseEventName)
if not responseEvent then
	responseEvent = Instance.new("RemoteEvent")
	responseEvent.Name = MirrorAIConfig.ResponseEventName
	responseEvent.Parent = remotes
end

local randomizer = Random.new()

local styleAdvice = {
	"Try neon pink hair with the Demon Hunter Cute outfit.",
	"Go teal hair plus Star Glasses for a super idol look.",
	"Pick Retro Club outfit and Music Headphones for arcade power.",
}

local confidenceLines = {
	"You shine brightest when you smile.",
	"You already look amazing, little star.",
	"Your style is unique and awesome just like you.",
}

local calmingLines = {
	"Take one deep breath. You are safe and strong.",
	"Spooky can be fun. You are the hero in this arcade.",
	"Hold still, breathe in, breathe out. You got this.",
}

local clawTips = {
	"Watch the claw first, then press play when it is centered.",
	"Try both machines. Sometimes one feels luckier.",
	"Keep trying. Rare prizes show up after a few rounds.",
}

local function pick(list)
	return list[randomizer:NextInteger(1, #list)]
end

local function containsAny(text, words)
	for _, word in ipairs(words) do
		if string.find(text, word, 1, true) then
			return true
		end
	end
	return false
end

local function makeMirrorReply(playerName, message)
	local text = string.lower(message)
	local stars = string.rep("*", randomizer:NextInteger(2, 5))

	if containsAny(text, { "look", "pretty", "beautiful", "cute", "face" }) then
		return string.format("%s Dear %s, %s %s", MirrorAIConfig.OpeningLine, playerName, pick(confidenceLines), stars)
	end

	if containsAny(text, { "style", "outfit", "hair", "accessory", "wear" }) then
		return string.format("%s I choose this look: %s %s", MirrorAIConfig.OpeningLine, pick(styleAdvice), stars)
	end

	if containsAny(text, { "nervous", "scared", "afraid", "spooky", "monster", "demon" }) then
		return string.format("%s %s %s", MirrorAIConfig.OpeningLine, pick(calmingLines), stars)
	end

	if containsAny(text, { "claw", "prize", "machine", "win" }) then
		return string.format("%s Claw prophecy: %s %s", MirrorAIConfig.OpeningLine, pick(clawTips), stars)
	end

	if containsAny(text, { "kam", "dog", "pet" }) then
		return string.format("%s Kam says hello! Give Kam a little walk and then play the pet claw. %s", MirrorAIConfig.OpeningLine, stars)
	end

	if containsAny(text, { "who are you", "name" }) then
		return string.format("I am %s, your friendly arcade mirror guide. %s", MirrorAIConfig.MirrorName, stars)
	end

	return string.format("%s I see a brave arcade hero. Ask me about style, prizes, or courage. %s", MirrorAIConfig.OpeningLine, stars)
end

requestEvent.OnServerEvent:Connect(function(player, message)
	if typeof(message) ~= "string" then
		return
	end

	local trimmed = string.sub(message, 1, 180)
	if trimmed == "" then
		return
	end

	local reply = makeMirrorReply(player.DisplayName or player.Name, trimmed)
	responseEvent:FireClient(player, {
		Reply = reply,
		MirrorName = MirrorAIConfig.MirrorName,
		Kind = "MirrorReply",
	})
end)
