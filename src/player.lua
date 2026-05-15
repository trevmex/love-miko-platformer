local Config = require("src.config")
local Input = require("src.input")
local Util = require("src.util")

local Player = {}
Player.__index = Player

function Player.new(x, y)
    return setmetatable({
        x=x, y=y, w=34, h=58, vx=0, vy=0, dir=1, onGround=false,
        speed=260, jump=-610, hp=3, invuln=0, idleTime=0,
        meleeCooldown=0, rangedCooldown=0, alive=true
    }, Player)
end

function Player:update(dt, world)
    self.idleTime = self.idleTime + dt
    self.invuln = math.max(0, self.invuln - dt)
    self.meleeCooldown = math.max(0, self.meleeCooldown - dt)
    self.rangedCooldown = math.max(0, self.rangedCooldown - dt)

    local move = 0
    if Input.isDown("left") then move = move - 1 end
    if Input.isDown("right") then move = move + 1 end
    -- gamepad left stick
    if love and love.joystick then
        for _, joy in ipairs(love.joystick.getJoysticks()) do
            if joy:isGamepad() then
                local ax = joy:getGamepadAxis("leftx")
                if math.abs(ax) > 0.25 then move = ax end
            end
        end
    end
    self.vx = move * self.speed
    if move ~= 0 then self.dir = Util.sign(move) end

    if Input.wasPressed("jump") and self.onGround then
        self.vy = self.jump
        self.onGround = false
        world.audio:play("jump")
    end

    if Input.wasPressed("melee") and self.meleeCooldown <= 0 then
        self.meleeCooldown = 0.34
        world:spawnMelee(self)
        world.audio:play("attack")
    end
    if (Input.wasPressed("ranged") or Input.isDown("ranged")) and self.rangedCooldown <= 0 then
        self.rangedCooldown = 0.55
        world:spawnOfuda(self)
        world.audio:play("paper")
    end

    self.vy = self.vy + Config.gravity * dt
    world:moveActor(self, dt)
    if self.y > Config.window.height + 160 then self:hurt() end
end

function Player:hurt()
    if self.invuln > 0 then return false end
    self.hp = self.hp - 1
    self.invuln = 1.2
    if self.hp <= 0 then self.alive = false end
    return true
end

function Player:draw()
    local bounce = math.sin(self.idleTime * 8) * 3
    local aura = 0.55 + math.sin(self.idleTime * 5) * 0.12
    local x, y = self.x, self.y + bounce
    if self.invuln > 0 and math.floor(self.invuln * 12) % 2 == 0 then return end
    love.graphics.setColor(0.02, 0.04, 0.09, 0.35)
    love.graphics.ellipse("fill", x + self.w/2, y + self.h + 3, 22, 5)
    love.graphics.setColor(0.1, 0.95, 1, aura)
    love.graphics.circle("line", x + self.w/2, y + 14, 28)
    love.graphics.setColor(1, 0.1, 0.85, 0.22)
    love.graphics.circle("line", x + self.w/2, y + 14, 33)
    love.graphics.setColor(0.08, 0.02, 0.15)
    love.graphics.rectangle("fill", x+5, y+6, 24, 29, 3, 3)
    love.graphics.setColor(1, 0.98, 0.9)
    love.graphics.rectangle("fill", x+8, y+8, 18, 26, 3, 3) -- white kosode
    love.graphics.setColor(0.7, 0.98, 1)
    love.graphics.rectangle("fill", x+9, y+12, 16, 3)
    love.graphics.setColor(0.9, 0.05, 0.15)
    love.graphics.polygon("fill", x+4,y+30, x+30,y+30, x+26,y+56, x+8,y+56) -- red hakama
    love.graphics.setColor(0.18, 0.03, 0.12)
    love.graphics.line(x+17,y+32, x+17,y+55)
    love.graphics.setColor(0.03, 0.025, 0.06)
    love.graphics.circle("fill", x+17, y+8, 13) -- hair
    love.graphics.rectangle("fill", x+8, y+9, 18, 8)
    love.graphics.setColor(0.1, 0.95, 1)
    love.graphics.rectangle("fill", x+12, y+5, 3, 2)
    love.graphics.rectangle("fill", x+20, y+5, 3, 2)
    love.graphics.setColor(1, 0.1, 0.2)
    love.graphics.polygon("fill", x+4, y-7, x+13, y+5, x-2, y+4)
    love.graphics.polygon("fill", x+30, y-7, x+21, y+5, x+36, y+4)
    love.graphics.setColor(1, 0.1, 0.85)
    love.graphics.rectangle("fill", x+15, y-3, 4, 5)
    love.graphics.setColor(1, 0.95, 0.2)
    love.graphics.rectangle("fill", x + (self.dir > 0 and 28 or -18), y+23, 24, 4) -- gohei wand
    love.graphics.setColor(1, 0.98, 0.88)
    love.graphics.rectangle("fill", x + (self.dir > 0 and 48 or -22), y+17, 6, 13)
    love.graphics.rectangle("fill", x + (self.dir > 0 and 55 or -29), y+19, 6, 11)
    love.graphics.setColor(1, 1, 1)
end

return Player
