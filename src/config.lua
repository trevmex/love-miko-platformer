local Config = {}

Config.window = { width = 960, height = 540 }
Config.display = { fullscreen = false }
Config.gravity = 1500
Config.levelTimer = 300

Config.controlActions = {
    {action="left", label="Move Left"},
    {action="right", label="Move Right"},
    {action="up", label="Up / Reserved"},
    {action="jump", label="Jump"},
    {action="melee", label="Gohei Melee"},
    {action="ranged", label="Ofuda Ranged"},
    {action="restart", label="Restart"}
}

Config.defaultControls = {
    keyboard = {
        left = {"a"},
        right = {"d"},
        up = {"w"},
        jump = {","},
        melee = {"."},
        ranged = {"/"},
        start = {"return"},
        select = {"return"},
        restart = {"r", "return"}
    },
    gamepad = {
        jump = {"a"},
        melee = {"b"},
        start = {"start"},
        select = {"a"},
        restart = {"start", "a"},
        rangedAxis = "triggerright"
    }
}

local function copyControls(src)
    local dst = { keyboard = {}, gamepad = {} }
    for action, keys in pairs(src.keyboard) do
        dst.keyboard[action] = {}
        for i, key in ipairs(keys) do dst.keyboard[action][i] = key end
    end
    for action, value in pairs(src.gamepad) do
        if type(value) == "table" then
            dst.gamepad[action] = {}
            for i, button in ipairs(value) do dst.gamepad[action][i] = button end
        else
            dst.gamepad[action] = value
        end
    end
    return dst
end

-- Programmable controls: remap these tables directly or use Config.setKeyboardBinding.
Config.controls = copyControls(Config.defaultControls)

function Config.setKeyboardBinding(action, key)
    assert(Config.controls.keyboard[action], "unknown keyboard action: " .. tostring(action))
    Config.controls.keyboard[action] = {key}
    return true
end

function Config.resetControls()
    Config.controls = copyControls(Config.defaultControls)
end

return Config
