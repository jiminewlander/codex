# KPop Demon Hunter Arcade Starter (Roblox Studio)

This starter kit builds a kid-friendly arcade world with:
- Two claw machines (`Pets` and `Plushies`)
- Coins + inventory tracking
- Avatar edit booth with preset outfits
- A cute chocolate lab companion named `Kam`

It is designed to be simple to install in a brand new place.

## 1) Studio Setup

1. Open Roblox Studio and create a new place.
2. In `Explorer`, create these containers if they do not exist:
   - `ReplicatedStorage`
   - `ServerScriptService`
   - `StarterPlayer > StarterPlayerScripts`
3. Copy file contents from this folder into new scripts/modules:
   - `roblox_starter/ReplicatedStorage/ArcadeConfig.lua` -> ModuleScript named `ArcadeConfig` in `ReplicatedStorage`
   - `roblox_starter/ServerScriptService/ArcadeServer.lua` -> Script named `ArcadeServer` in `ServerScriptService`
   - `roblox_starter/ServerScriptService/KamCompanion.lua` -> Script named `KamCompanion` in `ServerScriptService`
   - `roblox_starter/StarterPlayer/StarterPlayerScripts/ArcadeClient.lua` -> LocalScript named `ArcadeClient` in `StarterPlayerScripts`
4. Press `Play` to test.

The server script auto-creates a basic arcade layout if one is missing.

## 2) How To Customize

- Change spin cost and rewards in `ArcadeConfig.lua` under `Machines`.
- Change avatar preset names and clothing IDs in `ArcadeConfig.lua` under `AvatarPresets`.
- Build your own arcade meshes/models later; keep these names so scripts continue working:
  - `Workspace/Arcade/ClawMachinePets`
  - `Workspace/Arcade/ClawMachinePlushies`
  - `Workspace/Arcade/AvatarBooth`
  - `Workspace/Arcade/KamHome`

## 3) Clothing Asset IDs

Set `ShirtId`, `PantsId`, and accessory IDs to your preferred catalog items.

Example format:
- `1234567890` (just the numeric asset id)

If IDs are left as `0`, that field is skipped.

## 4) Parenting Tips

- Keep all payments in in-game `Coins` only.
- Use short session goals (collect prizes, pet Kam, style avatar).
- Add bright signs and simple navigation.
- Playtest with your daughter and tune reward odds together.
