# Neon Arcade Starter (Kid-Friendly Roblox)

This starter kit is built for a 9-year-old friendly game with a fun 1980s neon arcade vibe.

Theme goals covered:
- Neon pink, teal, purple, electric blue, black
- Indoor arcade with symmetric machine layout
- Two claw machines (Pets + Plushies)
- Mirror station avatar customization UI
- Companion pet `Kam` (chocolate lab) that follows the player

## Roblox Studio Explorer Structure

Use this exact structure in Studio:

```text
ReplicatedStorage
  Modules
    ClawMachineConfig (ModuleScript)
    AvatarConfig (ModuleScript)
  Prizes (Folder, auto-created by script)
    Pets (Folder, auto-created by script)
    Plushies (Folder, auto-created by script)
  AvatarItems (Folder, auto-created by script)
    Hair (Folder)
    Outfits (Folder)
    Accessories (Folder)
  Pets (Folder, auto-created by script)
    Kam (Model)
  ArcadeRemotes (Folder, auto-created by script)
    PrizeWon (RemoteEvent)
    AvatarChangeRequest (RemoteEvent)
    AvatarChangeResult (RemoteEvent)

ServerScriptService
  BuildArcadeWorld (Script)
  ArcadeLightAnimator (Script)
  ClawMachineService (Script)
  AvatarCustomizationService (Script)
  KamPetService (Script)

StarterGui
  AvatarCustomizerGui (ScreenGui)
    AvatarCustomizer (LocalScript)

Workspace (auto-created at runtime)
  NeonArcade (Model)
    Machines
      PetClawMachine
      PlushieClawMachine
    GlowTiles
    LightStrips
    MirrorStation
```

## Where Each File Goes

- `roblox_starter/ReplicatedStorage/Modules/ClawMachineConfig.lua`
  - Put in `ReplicatedStorage > Modules` as `ClawMachineConfig`
- `roblox_starter/ReplicatedStorage/Modules/AvatarConfig.lua`
  - Put in `ReplicatedStorage > Modules` as `AvatarConfig`
- `roblox_starter/ServerScriptService/BuildArcadeWorld.server.lua`
  - Put in `ServerScriptService` as `BuildArcadeWorld`
- `roblox_starter/ServerScriptService/ArcadeLightAnimator.server.lua`
  - Put in `ServerScriptService` as `ArcadeLightAnimator`
- `roblox_starter/ServerScriptService/ClawMachineService.server.lua`
  - Put in `ServerScriptService` as `ClawMachineService`
- `roblox_starter/ServerScriptService/AvatarCustomizationService.server.lua`
  - Put in `ServerScriptService` as `AvatarCustomizationService`
- `roblox_starter/ServerScriptService/KamPetService.server.lua`
  - Put in `ServerScriptService` as `KamPetService`
- `roblox_starter/StarterGui/AvatarCustomizerGui/AvatarCustomizer.client.lua`
  - Put in `StarterGui > AvatarCustomizerGui` as a LocalScript named `AvatarCustomizer`

## First Run

1. Create the scripts/modules in Studio using the files above.
2. Press Play.
3. The world builder script auto-creates the arcade room, machines, mirror station, and placeholder assets.
4. Walk to each claw machine and press `E`.
5. Walk to mirror station and press `E` to open customization UI.

## Easy Customization

- Add more prizes:
  - Put more models inside `ReplicatedStorage > Prizes > Pets` or `ReplicatedStorage > Prizes > Plushies`.
- Add more avatar items:
  - Add accessories in `Hair` and `Accessories` folders.
  - Add new outfit folders in `Outfits` with `TopColor` and `BottomColor` values.
- Real animations for Kam:
  - Replace placeholder animation IDs in Kam's `Animations` folder.

## TODO Ideas

- Save inventory and avatar choices with DataStore.
- Add rare jackpot effects and sounds.
- Turn won prizes into equipable follower pets.
- Replace placeholder models with polished assets.
