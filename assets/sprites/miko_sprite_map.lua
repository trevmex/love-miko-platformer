return {
    image = "assets/sprites/miko_sprite_map.png",
    frameWidth = 96,
    frameHeight = 128,
    columns = 6,
    rows = 5,
    origin = {x = 48, y = 112},
    collision = {x = 31, y = 24, w = 34, h = 58},
    notes = "High-resolution neon miko sprite map for the 1024x768 presentation. Idle frames include visible bobbing, ribbon sway, sleeve drift, and aura pulse.",
    animations = {
        idle = {
            fps = 8,
            frames = {
                {x=0, y=0}, {x=96, y=0}, {x=192, y=0}, {x=288, y=0}
            }
        },
        run = {
            fps = 12,
            frames = {
                {x=0, y=128}, {x=96, y=128}, {x=192, y=128}, {x=288, y=128}, {x=384, y=128}, {x=480, y=128}
            }
        },
        jump = {
            fps = 8,
            frames = {
                {x=0, y=256}, {x=96, y=256}, {x=192, y=256}
            }
        },
        hurt = {
            fps = 6,
            frames = {
                {x=288, y=256}
            }
        },
        victory = {
            fps = 6,
            frames = {
                {x=384, y=256}
            }
        },
        melee = {
            fps = 14,
            frames = {
                {x=0, y=384}, {x=96, y=384}, {x=192, y=384}, {x=288, y=384}
            }
        },
        ofuda = {
            fps = 12,
            frames = {
                {x=0, y=512}, {x=96, y=512}, {x=192, y=512}
            }
        }
    }
}
