# Sprite Assets

Prototype graphics are drawn procedurally in Lua for now. Add PNG sprites here and load them from a dedicated asset module when replacing generated placeholder art.

## Current player sprite draft

- `miko_sprite_map.png` — 576x640 RGBA sheet, 96x128 cells, 6 columns x 5 rows.
- `miko_sprite_map.lua` — frame coordinates, animation names, origin, and collision metadata.

The idle row includes subtle body bob, ribbon sway, sleeve movement, and aura pulsing so Miko feels alive even when standing still.
