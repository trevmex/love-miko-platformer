local Config = require("src.config")
local Input = require("src.input")
local World = require("src.world")
local Level1 = require("src.levels.level1")

local Game = { state = "splash", world = nil, t = 0, previousState = "splash", configIndex = 1, waitingForKey = nil }

function Game.load()
    Game.state = "splash"
    Game.world = nil
    Game.t = 0
    Game.font = love.graphics.newFont(18)
    Game.big = love.graphics.newFont(42)
end

function Game.startCharacterSelect()
    Game.state = "select"
end

function Game.startLevel()
    Game.world = World.new(Level1)
    Game.state = "playing"
end

function Game.openConfig()
    Game.previousState = Game.state
    Game.state = "config"
    Game.configIndex = 1
    Game.waitingForKey = nil
end

function Game.closeConfig()
    Game.state = Game.previousState or "splash"
    Game.waitingForKey = nil
end

function Game.configItems()
    local items = {}
    for _, action in ipairs(Config.controlActions) do table.insert(items, {kind="control", action=action.action, label=action.label}) end
    table.insert(items, {kind="fullscreen", label="Display Mode"})
    table.insert(items, {kind="reset", label="Reset Controls"})
    table.insert(items, {kind="back", label="Back"})
    return items
end

function Game.setFullscreen(fullscreen)
    Config.display.fullscreen = fullscreen
    love.window.setMode(Config.window.width, Config.window.height, {resizable=false, vsync=1, fullscreen=fullscreen, fullscreentype="desktop"})
end

function Game.toggleFullscreen()
    Game.setFullscreen(not Config.display.fullscreen)
end

function Game.update(dt)
    Game.t = Game.t + dt
    if Game.state == "playing" and Game.world then Game.world:update(dt) end
    Input.beginFrame()
end

function Game.drawMikoPreview(x, y)
    local bounce = math.sin(Game.t*8)*5
    love.graphics.setColor(0.1,0.9,1,0.35); love.graphics.circle("line", x, y+bounce, 38)
    love.graphics.setColor(1,1,1); love.graphics.rectangle("fill", x-14,y-18+bounce,28,36)
    love.graphics.setColor(0.9,0.05,0.12); love.graphics.rectangle("fill", x-18,y+10+bounce,36,40)
    love.graphics.setColor(0.04,0.03,0.08); love.graphics.circle("fill", x,y-24+bounce,18)
end

function Game.draw()
    love.graphics.setFont(Game.font)
    if Game.state == "playing" and Game.world then Game.world:draw(); return end
    love.graphics.clear(0.015,0.015,0.07)
    love.graphics.setColor(0.1,0.8,1,0.4)
    for i=1,16 do love.graphics.line(0,i*40 + math.sin(Game.t+i)*8,960,i*40 + math.cos(Game.t+i)*8) end
    love.graphics.setColor(1,1,1)
    if Game.state == "splash" then
        love.graphics.setFont(Game.big)
        love.graphics.printf("NEON MIKO",0,150,960,"center")
        love.graphics.setFont(Game.font)
        love.graphics.printf("Oni Gate Prototype",0,210,960,"center")
        love.graphics.printf("Press ENTER or gamepad START",0,300,960,"center")
        love.graphics.printf("Press C for config",0,335,960,"center")
    elseif Game.state == "select" then
        love.graphics.setFont(Game.big); love.graphics.printf("SELECT CHARACTER",0,70,960,"center")
        Game.drawMikoPreview(480,255)
        love.graphics.setFont(Game.font)
        love.graphics.printf("Miko Shrine Priestess",0,340,960,"center")
        love.graphics.printf("Weapons: Gohei prayer stick + Ofuda prayer paper",0,370,960,"center")
        love.graphics.printf("Press ENTER or gamepad A",0,425,960,"center")
        love.graphics.printf("Press C for config",0,455,960,"center")
    elseif Game.state == "config" then
        Game.drawConfig()
    end
end

function Game.drawConfig()
    local items = Game.configItems()
    love.graphics.setFont(Game.big); love.graphics.printf("CONFIG",0,48,960,"center")
    love.graphics.setFont(Game.font)
    love.graphics.printf("Up/Down: choose   Enter: edit/toggle   Esc/Backspace: back",0,104,960,"center")
    if Game.waitingForKey then love.graphics.printf("Press a new key for " .. Game.waitingForKey.label .. " (Esc cancels)",0,132,960,"center") end
    local y = 170
    for i, item in ipairs(items) do
        local selected = i == Game.configIndex
        love.graphics.setColor(selected and 1 or 0.75, selected and 1 or 0.75, selected and 0.2 or 0.75)
        local value = ""
        if item.kind == "control" then value = table.concat(Config.controls.keyboard[item.action] or {}, ", ")
        elseif item.kind == "fullscreen" then value = Config.display.fullscreen and "Fullscreen" or "Windowed" end
        love.graphics.printf((selected and "> " or "  ") .. item.label, 240, y, 250, "left")
        love.graphics.printf(value, 500, y, 220, "left")
        y = y + 34
    end
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Keyboard controls are remapped at runtime. Gamepad defaults remain active.",0,500,960,"center")
end

function Game.activateConfigItem()
    local item = Game.configItems()[Game.configIndex]
    if item.kind == "control" then Game.waitingForKey = item
    elseif item.kind == "fullscreen" then Game.toggleFullscreen()
    elseif item.kind == "reset" then Config.resetControls()
    elseif item.kind == "back" then Game.closeConfig() end
end

function Game.configKeypressed(key)
    if Game.waitingForKey then
        if key ~= "escape" then Config.setKeyboardBinding(Game.waitingForKey.action, key) end
        Game.waitingForKey = nil
        return
    end
    local count = #Game.configItems()
    if key == "up" or key == "w" then Game.configIndex = ((Game.configIndex - 2) % count) + 1
    elseif key == "down" or key == "s" then Game.configIndex = (Game.configIndex % count) + 1
    elseif key == "return" or key == "space" then Game.activateConfigItem()
    elseif key == "left" or key == "right" or key == "f" then
        local item = Game.configItems()[Game.configIndex]
        if item.kind == "fullscreen" then Game.toggleFullscreen() end
    elseif key == "escape" or key == "backspace" or key == "c" then Game.closeConfig() end
end

function Game.keypressed(key)
    if Game.state == "config" then Game.configKeypressed(key); return end
    Input.keypressed(key)
    if key == "escape" then love.event.quit() end
    if key == "c" then Game.openConfig(); return end
    if Game.state == "splash" and Input.wasPressed("start") then Game.startCharacterSelect(); return end
    if Game.state == "select" and (Input.wasPressed("select") or Input.wasPressed("start")) then Game.startLevel(); return end
    if Game.state == "playing" and Game.world and Game.world.over and Input.wasPressed("restart") then Game.startLevel() end
end

function Game.configGamepadpressed(button)
    if Game.waitingForKey then return end
    local count = #Game.configItems()
    if button == "dpup" then Game.configIndex = ((Game.configIndex - 2) % count) + 1
    elseif button == "dpdown" then Game.configIndex = (Game.configIndex % count) + 1
    elseif button == "a" then Game.activateConfigItem()
    elseif button == "b" or button == "back" then Game.closeConfig() end
end

function Game.gamepadpressed(joystick, button)
    if Game.state == "config" then Game.configGamepadpressed(button); return end
    Input.gamepadpressed(joystick, button)
    if button == "back" then Game.openConfig(); return end
    if Game.state == "splash" and Input.wasPressed("start") then Game.startCharacterSelect(); return end
    if Game.state == "select" and (Input.wasPressed("select") or Input.wasPressed("start")) then Game.startLevel(); return end
    if Game.state == "playing" and Game.world and Game.world.over and Input.wasPressed("restart") then Game.startLevel() end
end

function Game.gamepadaxis(joystick, axis, value)
    Input.gamepadaxis(joystick, axis, value)
end

return Game
