local Util = require("src.util")
local Enemies = {}

local Base = {}
Base.__index = Base

function Base:rect() return {x=self.x, y=self.y, w=self.w, h=self.h} end
function Base:hurt(world, damage)
    self.hp = self.hp - (damage or 1)
    if self.hp <= 0 then
        self.dead = true
        world.score = world.score + self.points
        world.audio:play("hit")
    end
end

function Enemies.new(kind, x, y)
    local e = setmetatable({kind=kind, x=x, y=y, w=38, h=38, vx=0, vy=0, hp=1, points=100, t=0, dead=false, onGround=false}, Base)
    if kind == "blue" then e.color={0.1,0.35,1}; e.vx=-55; e.jump=-520; e.points=100 end
    if kind == "red" then e.color={1,0.1,0.08}; e.w=42; e.hp=2; e.points=150; e.cooldown=1.5 end
    if kind == "yellow" then e.color={1,0.85,0.05}; e.y0=y; e.hp=1; e.points=200; e.floating=true end
    return e
end

function Base:update(dt, world)
    self.t = self.t + dt
    local player = world.player
    if self.kind == "blue" then
        self.vy = self.vy + 1500 * dt
        if self.onGround and self.t > 1.2 then self.vy = self.jump; self.onGround=false; self.t=0 end
        world:moveActor(self, dt)
        if self.onGround and math.random() < 0.01 then self.vx = -self.vx end
    elseif self.kind == "red" then
        self.cooldown = self.cooldown - dt
        self.vx = 0
        if self.cooldown <= 0 and math.abs(player.x - self.x) < 520 then
            self.cooldown = 2.1
            world:spawnFire(self.x + self.w/2, self.y+16, player.x < self.x and -1 or 1)
        end
        self.vy = self.vy + 1500 * dt
        world:moveActor(self, dt)
    elseif self.kind == "yellow" then
        local dx = player.x - self.x
        if math.abs(dx) < 280 and player.y > self.y then
            self.vx = Util.sign(dx) * 120
            self.vy = 230
        else
            self.vx = math.sin(self.t*1.7)*65
            self.vy = math.sin(self.t*2.5)*45
        end
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
        if self.y > self.y0 + 180 then self.y = self.y0 + 180; self.vy = -160 end
        if self.y < self.y0 - 35 then self.y = self.y0 - 35 end
    end
end

function Base:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x+self.w/2, self.y+self.h/2, self.w/2)
    love.graphics.setColor(0.95,0.95,1)
    love.graphics.circle("fill", self.x+11, self.y+13, 5)
    love.graphics.circle("fill", self.x+self.w-11, self.y+13, 5)
    love.graphics.setColor(0.05,0.02,0.08)
    love.graphics.circle("fill", self.x+11, self.y+13, 2)
    love.graphics.circle("fill", self.x+self.w-11, self.y+13, 2)
    love.graphics.setColor(1,1,1)
    love.graphics.polygon("fill", self.x+7,self.y+2, self.x+13,self.y-12, self.x+18,self.y+3)
    love.graphics.polygon("fill", self.x+self.w-7,self.y+2, self.x+self.w-13,self.y-12, self.x+self.w-18,self.y+3)
end

return Enemies
