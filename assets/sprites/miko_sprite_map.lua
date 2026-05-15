return {
    image = "assets/sprites/miko_sprite_map.png",
    frameWidth = 48,
    frameHeight = 64,
    columns = 6,
    rows = 5,
    origin = {x = 24, y = 56},
    collision = {x = 7, y = 6, w = 34, h = 58},
    notes = "Neon miko sprite map with subtle idle bob, ribbon sway, aura pulse, run, jump, melee, ofuda, hurt, and victory frames.",
    animations = {
        idle = {
            fps = 8,
            frames = {
                {x=0, y=0}, {x=48, y=0}, {x=96, y=0}, {x=144, y=0}
            }
        },
        run = {
            fps = 12,
            frames = {
                {x=0, y=64}, {x=48, y=64}, {x=96, y=64}, {x=144, y=64}, {x=192, y=64}, {x=240, y=64}
            }
        },
        jump = {
            fps = 8,
            frames = {
                {x=0, y=128}, {x=48, y=128}, {x=96, y=128}
            }
        },
        hurt = {
            fps = 6,
            frames = {
                {x=144, y=128}
            }
        },
        victory = {
            fps = 6,
            frames = {
                {x=192, y=128}
            }
        },
        melee = {
            fps = 14,
            frames = {
                {x=0, y=192}, {x=48, y=192}, {x=96, y=192}, {x=144, y=192}
            }
        },
        ofuda = {
            fps = 12,
            frames = {
                {x=0, y=256}, {x=48, y=256}, {x=96, y=256}
            }
        }
    }
}
