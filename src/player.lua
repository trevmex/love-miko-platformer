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
    if self.y > 700 then self:hurt() end
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
    local x, y = self.x, self.y + bounce
    if self.invuln > 0 and math.floor(self.invuln * 12) % 2 == 0 then return end
    love.graphics.setColor(0.1, 0.95, 1, 0.45)
    love.graphics.circle("line", x + self.w/2, y + 12, 24)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", x+8, y+8, 18, 26) -- white kosode
    love.graphics.setColor(0.9, 0.05, 0.15)
    love.graphics.rectangle("fill", x+5, y+30, 24, 25) -- red hakama
    love.graphics.setColor(0.05, 0.05, 0.08)
    love.graphics.circle("fill", x+17, y+8, 12) -- hair
    love.graphics.setColor(1, 0.1, 0.2)
    love.graphics.polygon("fill", x+5, y-6, x+13, y+5, x+0, y+4)
    love.graphics.polygon("fill", x+29, y-6, x+21, y+5, x+34, y+4)
    love.graphics.setColor(1, 0.95, 0.2)
    love.graphics.rectangle("fill", x + (self.dir > 0 and 29 or -15), y+24, 20, 4) -- gohei wand
    love.graphics.setColor(1, 1, 1)
end

return Player
