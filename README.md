# Survival Master Hunt

> Our little guy has one job: **save the fridge at any cost** so they can eat.

Late one night the ghosts and monsters smelled dinner. Wraiths drift through the walls and hopping crawlers thump across the floor — all headed for the same glowing fridge. Our little hunter grabs what ammo fits in their pockets, stands between the monsters and the leftovers, and refuses to move.

## The story

You are the last thing standing between hunger and the haunted kitchen. The fridge (`Furnitures_Fridge`) is more than furniture — it is breakfast, lunch, and dinner. When a ghost steps into its light (`Destroy_Zone`), the little `ALLOW` lamp flips from green to red: contested. Leave them there and the fridge health ticks `100 -> 0`, five seconds at a time, until the door hangs open and the food is gone.

So you kite, you shoot, you jump back, you buy time. `Life`, `Health`, `Ammo`, a `Lens`, some `Books`, a `Cross` from the hidden `BuyMenu` — anything to hold one more wave. Each kill (`+10 score`) is one less mouth at the fridge. Survive all five waves and the hunt never really ends: the final night just keeps coming.

## Features

- Top-down twin-stick survival in **Godot 4.7** (`Game_Scene`: `Map_1` + `Player` + `Fridge` + `Spawn_Zones` + `Hud`)
- Two enemies: **Wraith (`Enemy_Type_1`)** — wanders, then chases on sight, kills by touch; **Crawler (`Enemy_Type_2`)** — hops in arcs, chases on `Range` detection, kills by contact (`Impact_Zone`)
- Fridge-defense objective with contested lamp, damage-over-time bar, and shop menu
- Wave clock that counts **backwards** (`ends in` / `starts in`), 15s no-spawn breaks, endless final wave
- Level-gated spawns (`Wave 1 = 2 zones, Wave 2 = 3, Wave 3+ = 4`), pause / death / main menu flow

## Controls

| Action | Input |
|---|---|
| Move | `W` `A` `S` `D` |
| Aim | Mouse |
| Fire | `Left Mouse` |
| Pause | `Esc` |

## Waves

| Wave | Fight | Break after |
|---|---|---|
| 1 | `01:00`, 2 spawn zones | `00:15` — `Wave 2 starts in...`, spawns paused, field enemies stay |
| 2 | `01:30`, 3 spawn zones | `00:15` |
| 3 | `02:00`, 4 spawn zones | `00:15` |
| 4 | `02:00`, 4 spawn zones | `00:15` |
| Final | `06:00`, 4 spawn zones, then **endless** (`Final Wave - Survive!`) | — |

Contact costs `1 HP` with a `2s` immunity blink (`Global.take_damage`). Start at `3/5 HP`, `9/15 ammo`. Death opens `YOU DIED` over the same pause menu — `Main Menu` returns to title, `Play` starts the hunt again.

## Run it

1. Open in Godot `4.7` (main scene: `Scene/main_menu.tscn`).
2. Press `Play` — `Hud` calls `Global.start_run()`, spawner wakes after ~10s.
3. Hold the fridge. Good luck, little guy.
