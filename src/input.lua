local Config = require("src.config")

local Input = { pressed = {}, axes = { triggerright = 0 } }

local function contains(list, value)
    for _, v in ipairs(list or {}) do if v == value then return true end end
    return false
end

function Input.beginFrame()
    Input.pressed = {}
end

function Input.keypressed(key)
    Input.pressed["key:" .. key] = true
end

function Input.gamepadpressed(_, button)
    Input.pressed["pad:" .. button] = true
end

function Input.gamepadaxis(_, axis, value)
    Input.axes[axis] = value
end

function Input.isDown(action)
    for _, key in ipairs(Config.controls.keyboard[action] or {}) do
        if love and love.keyboard and love.keyboard.isDown(key) then return true end
    end
    if action == "left" or action == "right" or action == "up" then return false end
    for _, btn in ipairs(Config.controls.gamepad[action] or {}) do
        if love and love.joystick then
            for _, joy in ipairs(love.joystick.getJoysticks()) do
                if joy:isGamepadDown(btn) then return true end
            end
        end
    end
    if action == "ranged" and (Input.axes[Config.controls.gamepad.rangedAxis] or 0) > 0.45 then return true end
    return false
end

function Input.wasPressed(action)
    for _, key in ipairs(Config.controls.keyboard[action] or {}) do
        if Input.pressed["key:" .. key] then return true end
    end
    for _, btn in ipairs(Config.controls.gamepad[action] or {}) do
        if Input.pressed["pad:" .. btn] then return true end
    end
    return false
end

function Input.isMapped(action, device, key)
    local map = Config.controls[device] and Config.controls[device][action]
    return contains(map, key)
end

return Input
