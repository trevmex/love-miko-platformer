# Neon Miko: Oni Gate

A LÖVE/Lua sci-fi 2D platformer prototype starring a miko shrine priestess.

## Run

```bash
love .
```

## Test

```bash
lua tests/test_runner.lua
```

The test runner includes an in-repo line coverage gate and fails unless executable source functions remain at 100% coverage.

## Controls

Keyboard defaults, editable in `src/config.lua`:
- `A/D`: move
- `W`: reserved/up
- `,`: jump
- `.`: short-range gohei prayer-stick attack
- `/`: ranged ofuda prayer-paper attack
- `Enter`: start/select/restart
- `R`: restart after game over
- `C`: open config screen

Gamepad defaults:
- `A`: jump/select/restart after game over
- `B`: melee
- `Right Trigger`: ranged
- `Start`: start/restart after game over
- `Back`: open config screen

## Implemented prototype features

- Splash screen
- Config screen with keyboard remapping and fullscreen/windowed toggle
- Character select screen with only the miko available
- SF2-style idle bounce
- START banner before player control
- Side-scrolling level with no backward camera movement
- Level about SMB 1-1 length (`3584px`)
- Static platforms, pits, moving platforms, and sci-fi shrine decorations
- Goal is a Shinto temple gate; bell rings on entry
- 300 second timer
- Score from killing enemies
- Three oni demons:
  - Blue jumping oni
  - Red fire-spitting oni
  - Yellow floating swoop oni
- Generated neon/vector-style graphics in code
- Generated Japanese-inspired pentatonic background music and SFX in code
- Modular level file: `src/levels/level1.lua`
- Easy asset folders: `assets/sprites`, `assets/sounds`, `assets/music`

## Repo structure

```text
main.lua
src/
  audio.lua
  config.lua
  enemies.lua
  game.lua
  input.lua
  player.lua
  util.lua
  world.lua
  levels/level1.lua
tests/test_runner.lua
assets/
  sprites/
  backgrounds/
  sounds/
  music/
```
