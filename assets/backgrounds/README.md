# Background Assets

Place background art for **Neon Miko: Oni Gate** here.

Current prototype backgrounds are drawn procedurally in `src/world.lua`. Add PNG backgrounds here when replacing or augmenting those generated visuals.

## Suggested structure

```text
assets/backgrounds/
  README.md
  style-guide.md          # Optional expanded background art notes
  level1/
    sky.png
    distant_city.png
    shrine_hills.png
    foreground_fog.png
```

## Naming

Use lowercase names with underscores:

- `level1_sky.png`
- `level1_city_far.png`
- `level1_torii_mid.png`
- `level1_fog_foreground.png`

For parallax layers, suffix by depth:

- `_far` for slow distant layers
- `_mid` for middle layers
- `_near` for fast foreground layers

## Art direction

- Match the sprite guide in `assets/sprites/SPRITES.md`.
- Keep backgrounds darker and lower contrast than gameplay sprites.
- Use cyan/magenta neon accents sparingly so the player and enemies remain readable.
- Avoid placing bright red/white shapes directly behind the miko's main path.
- Background decorations should not look collidable unless also represented as level geometry.

## Technical notes

- Prefer wide horizontal layers for parallax side scrolling.
- Use transparent PNGs for foreground/midground overlays.
- Keep seams tileable if a layer repeats.
- Preserve procedural fallback backgrounds until replacement assets are loaded successfully.
