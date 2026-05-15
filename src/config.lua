local Config = {}

Config.window = { width = 960, height = 540 }
Config.gravity = 1500
Config.levelTimer = 300

-- Programmable controls: change these tables to remap controls.
Config.controls = {
    keyboard = {
        left = {"a"},
        right = {"d"},
        up = {"w"},
        jump = {","},
        melee = {"."},
        ranged = {"/"},
        start = {"return"},
        select = {"return"}
    },
    gamepad = {
        jump = {"a"},
        melee = {"b"},
        start = {"start"},
        select = {"a"},
        rangedAxis = "triggerright"
    }
}

return Config
