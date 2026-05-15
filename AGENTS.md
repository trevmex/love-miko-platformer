# AGENTS.md

Guidance for coding agents working on **Neon Miko: Oni Gate**, a LÖVE/Lua 2D platformer prototype.

## Project basics

- Engine/runtime: LÖVE 2D with Lua.
- Entry point: `main.lua` delegates to `src.game`.
- Main modules:
  - `src/game.lua` handles high-level game states and LÖVE callbacks.
  - `src/world.lua` owns level runtime state, camera, collisions, timer, score, drawing, and win/game-over flow.
  - `src/player.lua` owns player movement, combat input, damage, and drawing.
  - `src/enemies.lua` owns enemy behavior and scoring.
  - `src/input.lua` maps keyboard/gamepad input from `src/config.lua`.
  - `src/levels/level1.lua` is data-only level layout.
  - `src/audio.lua` generates music/SFX in code.
- Tests are in `tests/test_runner.lua`.

## Commands

Run the game:

```bash
love .
```

Run tests before finishing gameplay or logic changes:

```bash
lua tests/test_runner.lua
```

## Coding style

- Use plain Lua modules with `local Module = {}` and `return Module`.
- Prefer small, focused modules over putting unrelated logic in one file.
- Keep game data in tables; keep level layout data in `src/levels/`.
- Follow the existing compact style: local helpers, explicit tables, and straightforward imperative update/draw functions.
- Avoid introducing external dependencies unless explicitly requested.
- Keep generated placeholder art/audio in code unless the task specifically adds files under `assets/`.
- Preserve LÖVE callback boundaries: `main.lua` should stay thin and delegate to modules.

## Gameplay and design principles

- Keep the game identity intact: neon sci-fi shrine aesthetic, miko protagonist, oni enemies, torii/temple imagery.
- Favor responsive arcade/platformer feel over simulation complexity.
- Maintain the side-scrolling camera rule: the camera should not move backward and the player should not retreat behind it.
- Keep controls programmable through `src/config.lua`; do not hard-code new bindings in gameplay modules.
- Support keyboard and gamepad paths when adding player-facing controls.
- Preserve the prototype scope unless asked to expand it: simple generated visuals, one clear level flow, readable logic.

## Testing expectations

- Add or update tests in `tests/test_runner.lua` for logic/data changes that can run without LÖVE.
- Keep tests compatible with plain `lua tests/test_runner.lua`; do not require launching LÖVE for test coverage.
- For visual/audio-only changes, manually inspect with `love .` when possible and describe what was checked.
- If you cannot run a command, say why and what should be run next.

## Change safety

- Do not overwrite or reformat unrelated files.
- Treat existing uncommitted changes as user work unless you made them in the current task.
- Stage and commit only files relevant to your change.
- When editing gameplay constants, prefer named values in `src/config.lua` or clear local constants.
- Keep collision rectangles and level coordinates simple and easy to reason about.

## Git hygiene

- Use concise commit messages that describe player-visible or developer-visible impact.
- Before committing, check `git status --short` and ensure unrelated modified files are not staged.
- If asked to push, push the current branch to the configured GitHub remote for `trevmex/love-miko-platformer`.
