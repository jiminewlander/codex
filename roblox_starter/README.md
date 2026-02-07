# Neon Arcade Starter - Phase 2 (Extra Cute + Mirror AI)

This Phase 2 starter kit is designed for a kid-friendly Roblox arcade with:
- 1980s neon arcade room
- Two animated claw machines (Pets + Plushies)
- Extra Cute bright UI theme
- Snow White style "Mirror Mirror" AI helper
- Companion dog Kam (chocolate lab) follower

## Explorer Structure

```text
ReplicatedStorage
  Modules
    ClawMachineConfig (ModuleScript)
    AvatarConfig (ModuleScript)
    MirrorAIConfig (ModuleScript)
  Prizes (Folder, auto-created)
    Pets (Folder, auto-created)
    Plushies (Folder, auto-created)
  AvatarItems (Folder, auto-created)
    Hair (Folder)
    Outfits (Folder)
    Accessories (Folder)
  Pets (Folder, auto-created)
    Kam (Model)
  ArcadeRemotes (Folder, auto-created)
    PrizeWon (RemoteEvent)
    AvatarChangeRequest (RemoteEvent)
    AvatarChangeResult (RemoteEvent)
    MirrorAskRequest (RemoteEvent)
    MirrorAskResponse (RemoteEvent)

ServerScriptService
  BuildArcadeWorld (Script)
  ArcadeLightAnimator (Script)
  ClawMachineService (Script)
  AvatarCustomizationService (Script)
  MirrorAIService (Script)
  KamPetService (Script)

StarterGui
  AvatarCustomizerGui (ScreenGui)
    AvatarCustomizer (LocalScript)

Workspace (auto-created at runtime)
  NeonArcade (Model)
    Machines
      PetClawMachine
      PlushieClawMachine
      (each has a ClawRig for animation)
    GlowTiles
    LightStrips
    MirrorStation
```

## File Placement

- `/Users/newlandj/Documents/New project/roblox_starter/ReplicatedStorage/Modules/ClawMachineConfig.lua`
  - `ReplicatedStorage > Modules > ClawMachineConfig`
- `/Users/newlandj/Documents/New project/roblox_starter/ReplicatedStorage/Modules/AvatarConfig.lua`
  - `ReplicatedStorage > Modules > AvatarConfig`
- `/Users/newlandj/Documents/New project/roblox_starter/ReplicatedStorage/Modules/MirrorAIConfig.lua`
  - `ReplicatedStorage > Modules > MirrorAIConfig`
- `/Users/newlandj/Documents/New project/roblox_starter/ServerScriptService/BuildArcadeWorld.server.lua`
  - `ServerScriptService > BuildArcadeWorld`
- `/Users/newlandj/Documents/New project/roblox_starter/ServerScriptService/ArcadeLightAnimator.server.lua`
  - `ServerScriptService > ArcadeLightAnimator`
- `/Users/newlandj/Documents/New project/roblox_starter/ServerScriptService/ClawMachineService.server.lua`
  - `ServerScriptService > ClawMachineService`
- `/Users/newlandj/Documents/New project/roblox_starter/ServerScriptService/AvatarCustomizationService.server.lua`
  - `ServerScriptService > AvatarCustomizationService`
- `/Users/newlandj/Documents/New project/roblox_starter/ServerScriptService/MirrorAIService.server.lua`
  - `ServerScriptService > MirrorAIService`
- `/Users/newlandj/Documents/New project/roblox_starter/ServerScriptService/KamPetService.server.lua`
  - `ServerScriptService > KamPetService`
- `/Users/newlandj/Documents/New project/roblox_starter/StarterGui/AvatarCustomizerGui/AvatarCustomizer.client.lua`
  - `StarterGui > AvatarCustomizerGui > AvatarCustomizer`

## In-Game Controls

- Claw machines: walk to machine and press `E`
- Mirror customization panel: walk to mirror and press `E`
- Mirror AI chat panel: walk to mirror and press `Q`

## Phase 2 Upgrades

1. Working claw machines
- Claw now moves across the machine, drops down, lifts, and returns.
- Machine can miss sometimes (kid-friendly success rate in config).
- Weighted random prize selection supported with prize attributes.

2. Extra Cute UI
- Bright candy color palette.
- Rounded controls, gradient cards, cute prompt toasts.
- Separate Mirror AI chat panel plus avatar style panel.

3. Mirror Mirror AI
- Storybook mirror personality.
- Quick question buttons and custom typed questions.
- Gives confidence lines, style suggestions, and claw tips.

## How To Add More Prizes

1. Add more models to:
- `ReplicatedStorage > Prizes > Pets`
- `ReplicatedStorage > Prizes > Plushies`

2. Optional attributes on each prize model:
- `Rarity` (String): `Common`, `Rare`, `Epic`, `Legendary`
- `Weight` (Number): higher number means more common

## Future TODO

- Save prize inventory with DataStore.
- Add real SFX/music IDs.
- Replace procedural claw with skinned mesh animation.
- Add voice lines for mirror AI.
