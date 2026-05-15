local Input = require("src.input")
local World = require("src.world")
local Level1 = require("src.levels.level1")

local Game = { state = "splash", world = nil, t = 0 }

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
    elseif Game.state == "select" then
        love.graphics.setFont(Game.big); love.graphics.printf("SELECT CHARACTER",0,70,960,"center")
        Game.drawMikoPreview(480,255)
        love.graphics.setFont(Game.font)
        love.graphics.printf("Miko Shrine Priestess",0,340,960,"center")
        love.graphics.printf("Weapons: Gohei prayer stick + Ofuda prayer paper",0,370,960,"center")
        love.graphics.printf("Press ENTER or gamepad A",0,425,960,"center")
    end
end

function Game.keypressed(key)
    Input.keypressed(key)
    if key == "escape" then love.event.quit() end
    if Game.state == "splash" and Input.wasPressed("start") then Game.startCharacterSelect() end
    if Game.state == "select" and (Input.wasPressed("select") or Input.wasPressed("start")) then Game.startLevel() end
end

function Game.gamepadpressed(joystick, button)
    Input.gamepadpressed(joystick, button)
    if Game.state == "splash" and Input.wasPressed("start") then Game.startCharacterSelect() end
    if Game.state == "select" and (Input.wasPressed("select") or Input.wasPressed("start")) then Game.startLevel() end
end

function Game.gamepadaxis(joystick, axis, value)
    Input.gamepadaxis(joystick, axis, value)
end

return Game
