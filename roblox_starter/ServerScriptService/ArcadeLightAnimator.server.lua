local ARCADE_NAME = "NeonArcade"

local palette = {
	Color3.fromRGB(255, 64, 176),
	Color3.fromRGB(46, 255, 223),
	Color3.fromRGB(145, 76, 255),
	Color3.fromRGB(38, 166, 255),
}

local arcade = workspace:WaitForChild(ARCADE_NAME)
local lightStrips = arcade:WaitForChild("LightStrips")
local glowTiles = arcade:WaitForChild("GlowTiles")

local step = 0
while true do
	step += 1

	local strips = lightStrips:GetChildren()
	table.sort(strips, function(a, b)
		return a.Name < b.Name
	end)

	for index, strip in ipairs(strips) do
		if strip:IsA("BasePart") then
			local colorIndex = ((index + step - 1) % #palette) + 1
			strip.Color = palette[colorIndex]
		end
	end

	for index, tile in ipairs(glowTiles:GetChildren()) do
		if tile:IsA("BasePart") then
			local colorIndex = ((index + step) % #palette) + 1
			tile.Color = palette[colorIndex]
			tile.Transparency = 0.2 + (((index + step) % 3) * 0.1)
		end
	end

	task.wait(0.2)
end
