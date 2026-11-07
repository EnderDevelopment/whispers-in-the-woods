# Roblox Horror Script: Whispers in the Woods

Whispers in the Woods is a Roblox script and Luau horror-game starter where players search a foggy forest for eight papers attached to trees while a monster pursues and damages them. Players must collect every paper, reach the sealed gate at the far end of the forest, and activate it to escape and win.

## Install

1. Open your Roblox experience in Roblox Studio.
2. Create a Script named `ForestGame` inside `ServerScriptService`.
3. Copy the contents of `ServerScriptService/ForestGame.server.lua` into the new Script.
4. Create a LocalScript named `ForestHorror` inside `StarterPlayer > StarterPlayerScripts`.
5. Copy the contents of `StarterPlayer/StarterPlayerScripts/ForestHorror.client.lua` into the new LocalScript.
6. Press Play to test the game.

The server script automatically generates the forest floor, trail, trees, papers, monster, spawn point, and exit gate. No additional models, packages, or assets are required.

## Use

1. Spawn at the beginning of the forest.
2. Explore the generated forest and locate the eight notes attached to trees.
3. Approach a note and use its ProximityPrompt to collect it.
4. Avoid the monster, which follows the nearest living player and attacks at close range.
5. After all eight papers are collected, travel to the gate at the far end of the forest.
6. Use the gate’s ProximityPrompt to leave the forest and complete the game.
7. If the monster defeats a player, the player can respawn and continue contributing to the shared paper collection objective.

To adjust the experience, edit `PAPER_COUNT`, `MAP_SIZE`, or the monster movement speed in `ForestGame.server.lua`.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/4c0986b8-2f15-42e9-9e3e-43333882d7e8?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=4c0986b8-2f15-42e9-9e3e-43333882d7e8
