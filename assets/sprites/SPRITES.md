# Neon Miko Sprite Style Guide

This guide defines the target sprite direction for **Neon Miko: Oni Gate**. Use it when replacing procedural placeholder art with PNG sprites or richer in-code drawing.

## Art direction

- **Theme:** Shinto shrine folklore fused with neon sci-fi arcade energy.
- **Mood:** Bright, readable, heroic, slightly spooky but not horror.
- **Silhouette first:** Every character must be recognizable as a flat dark shape before adding detail.
- **High contrast:** Use dark navy/purple outlines with hot neon accents.
- **Chunky arcade readability:** Favor bold shapes over tiny detail.
- **Respectful shrine motifs:** Use torii, ofuda, gohei, bells, hakama, lanterns, rope, and paper streamers as stylized fantasy elements.

## Technical targets

Recommended base sizes:

| Sprite | Frame size | Notes |
| --- | ---: | --- |
| Player miko | `48x64` | Collision can stay near current `34x58`; art may overhang. |
| Blue oni | `48x48` | Squat jumper silhouette. |
| Red oni | `48x56` | Taller fire-spitter with horns/snouted mouth. |
| Yellow oni | `48x48` | Floating round/imp shape with trailing aura. |
| Ofuda projectile | `16x16` or `24x16` | Paper charm; keep very readable. |
| Fire projectile | `24x16` | Neon flame/comet shape. |
| Platform tiles | `16x16` or `32x16` | Repeatable shrine-tech trims. |
| Decorations | variable | Torii/gates/lanterns can be larger set pieces. |

Sprite sheets should use:

- Transparent background.
- Nearest-neighbor pixel art, no anti-aliased edges unless intentionally painterly.
- Consistent frame grid with no cropped frames.
- Optional 1px guide padding between frames if needed.
- Filename pattern: `name_action.png`, e.g. `miko_run.png`, `oni_blue_jump.png`.

## Palette

Use this as a starting palette, not a strict limit.

### Core darks

- Void navy: `#050510`
- Deep indigo: `#101126`
- Outline purple: `#24123A`
- Shadow blue: `#10243A`

### Neon accents

- Shrine red: `#E6172E`
- Hot magenta: `#FF2ACD`
- Cyan glow: `#1FE8FF`
- Electric blue: `#248BFF`
- Bell gold: `#FFD84A`
- Spirit yellow: `#FFF06A`

### Cloth / paper

- Miko white: `#FFF8E8`
- Warm paper: `#F7E3B2`
- Pale blue highlight: `#BFF7FF`
- Hair black: `#09070D`

## Outlines and glow

- Use a dark 1-2px outline on gameplay sprites.
- Add small neon rim highlights on the light-facing edge.
- Use glow sparingly: cyan/magenta pixels around magic, projectiles, oni eyes, and shrine-tech props.
- Do not make glow larger than the readable sprite silhouette in gameplay frames.

## Player: Miko shrine priestess

### Key visual anchors

- White kosode top.
- Red hakama pants/skirt shape.
- Black hair with red ribbon accents.
- Gohei prayer wand with white zigzag streamers.
- Ofuda paper charms as ranged attack.
- Cyan circular spiritual aura in idle/attack frames.

### Silhouette

- Upright, heroic stance.
- Large bow/ribbon shape on head for instant recognition.
- Gohei extends beyond body during attacks.
- Hair mass should contrast with white top.

### Animation set

Minimum recommended frames:

| Action | Frames | Notes |
| --- | ---: | --- |
| Idle | 4 | SF2-style breathing bounce; sleeves and ribbons shift. |
| Run | 6 | Quick shrine-maiden sprint; hakama flares. |
| Jump up/fall | 2-4 | Tuck knees slightly; ribbon trails upward/downward. |
| Land | 1-2 | Small squash; sleeves settle. |
| Melee/gohei | 4 | Anticipation, slash, active frame, recovery. Include white paper streamer arc. |
| Ofuda throw | 3 | Draw charm, release, follow-through. |
| Hurt | 2 | Flash/invulnerable compatible silhouette. |
| Victory | 4 | Bell/prayer pose optional. |

## Enemies

### Blue oni: jumper

- Squat, broad body with stubby horns.
- Blue/cyan skin, bright eyes, chunky teeth.
- Strong crouch and spring animation.
- Read as physical/contact threat.

Recommended frames: idle 2, crouch 1, jump 2, land 1, hurt 1.

### Red oni: fire-spitter

- Taller and meaner than blue oni.
- Red/magenta body, orange mouth glow, visible horns.
- Mouth or mask shape should telegraph fire attack.
- Add pre-fire inhale frame with bright mouth.

Recommended frames: idle 2, aim/inhale 2, spit 1-2, hurt 1.

### Yellow oni: floating swooper

- Rounder spirit-like body, yellow/gold palette.
- Small horns or mask face; trailing cyan/magenta flame wisps.
- Must feel airborne: no feet required, bobbing animation.
- Swoop frames should stretch slightly in movement direction.

Recommended frames: float 4, swoop 2, hurt 1.

## Projectiles and attacks

### Ofuda

- Warm paper rectangle with red kanji-like mark.
- Cyan or gold edge glow.
- Rotation or flutter can be animated, but keep collision readable.

### Gohei melee arc

- White paper streamers plus cyan crescent trail.
- Active frame should be obvious and wider than the player body.
- Avoid opaque effects that hide enemies.

### Fire shot

- Red/orange core with magenta outline and yellow tip.
- Comet/flame shape pointing in travel direction.
- 2-3 frame loop for flicker.

## Environment sprites

### Platforms

- Base: dark metal/shrine stone hybrid.
- Top edge: cyan neon trim for readability.
- Underside: deep purple shadow.
- Optional repeating motifs: circuit lines, shimenawa rope, small paper shide.

### Torii and temple gate

- Shrine red structures with cyan neon edge accents.
- Large silhouettes should remain simple and iconic.
- Temple goal should feel important: bell gold, glow, extra vertical framing.

### Lanterns and antennas

- Lanterns: red/gold/cyan light cores.
- Antennas: slim sci-fi shapes with blinking neon pixels.
- Decorations should not look like collidable platforms unless they are.

## Readability rules

- Gameplay objects must be readable at `960x540` without zooming.
- Never let background colors match enemy/player outlines too closely.
- Player white/red should be unique enough that enemies do not share the same overall silhouette.
- Projectiles need clear directionality.
- Dangerous objects should use warm colors; friendly/player magic should lean white/cyan/gold.

## Implementation notes

- Keep collisions data-driven and independent of art size.
- If art frames are larger than collision boxes, draw with explicit offsets.
- Add sprite loading through a dedicated module, e.g. `src/assets.lua`, rather than scattering `love.graphics.newImage` calls.
- Preserve procedural fallback art until PNG assets are complete.
- Add tests only for asset metadata or animation tables that can run under plain Lua.
