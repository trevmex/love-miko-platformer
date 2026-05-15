local Config = require("src.config")
local Game = require("src.game")

function love.load()
    love.window.setTitle("Neon Miko: Oni Gate")
    love.window.setMode(Config.window.width, Config.window.height, {resizable = false, vsync = 1})
    love.graphics.setDefaultFilter("nearest", "nearest")
    Game.load()
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    Game.draw()
end

function love.keypressed(key)
    Game.keypressed(key)
end

function love.gamepadpressed(joystick, button)
    Game.gamepadpressed(joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
    Game.gamepadaxis(joystick, axis, value)
end
