local Config = require("src.config")
local Util = require("src.util")
local Player = require("src.player")
local Enemies = require("src.enemies")
local Audio = require("src.audio")

local World = {}
World.__index = World

function World.new(level)
    local self = setmetatable({ level=level, cameraX=0, score=0, timer=Config.levelTimer, win=false, over=false,
        platforms={}, movingPlatforms={}, enemies={}, player=Player.new(level.start.x, level.start.y), attacks={}, enemyShots={}, audio=Audio.new(), startBanner=1.5 }, World)
    for _, p in ipairs(level.platforms) do table.insert(self.platforms, Util.copy(p)) end
    for _, p in ipairs(level.movingPlatforms) do local m=Util.copy(p); m.ox=m.x; m.oy=m.y; m.t=0; table.insert(self.movingPlatforms, m) end
    for _, e in ipairs(level.enemies) do table.insert(self.enemies, Enemies.new(e.kind, e.x, e.y)) end
    return self
end

function World:solidPlatforms()
    local all = {}
    for _, p in ipairs(self.platforms) do table.insert(all, p) end
    for _, p in ipairs(self.movingPlatforms) do table.insert(all, p) end
    return all
end

function World:moveActor(a, dt)
    a.x = a.x + (a.vx or 0) * dt
    for _, p in ipairs(self:solidPlatforms()) do
        if Util.aabb({x=a.x,y=a.y,w=a.w,h=a.h}, p) then
            if (a.vx or 0) > 0 then a.x = p.x - a.w elseif (a.vx or 0) < 0 then a.x = p.x + p.w end
            a.vx = 0
        end
    end
    a.y = a.y + (a.vy or 0) * dt
    a.onGround = false
    for _, p in ipairs(self:solidPlatforms()) do
        if Util.aabb({x=a.x,y=a.y,w=a.w,h=a.h}, p) then
            if (a.vy or 0) > 0 then a.y = p.y - a.h; a.onGround=true elseif (a.vy or 0) < 0 then a.y = p.y + p.h end
            a.vy = 0
        end
    end
end

function World:spawnMelee(player)
    table.insert(self.attacks, {type="melee", x=player.x + (player.dir>0 and player.w or -42), y=player.y+12, w=42, h=30, ttl=0.12, damage=1})
end

function World:spawnOfuda(player)
    table.insert(self.attacks, {type="ofuda", x=player.x + player.w/2, y=player.y+24, w=18, h=10, vx=520*player.dir, ttl=2.0, damage=1})
end

function World:spawnFire(x, y, dir)
    table.insert(self.enemyShots, {x=x, y=y, w=20, h=12, vx=260*dir, ttl=3})
    self.audio:play("fire")
end

function World:update(dt)
    self.audio:startMusic()
    self.startBanner = math.max(0, self.startBanner - dt)
    if self.startBanner > 0 then return end
    self.timer = self.timer - dt
    if self.timer <= 0 then self.over = true end

    for _, mp in ipairs(self.movingPlatforms) do
        mp.t = mp.t + dt * mp.speed / math.max(1, math.abs(mp.dx)+math.abs(mp.dy))
        local s = (math.sin(mp.t*math.pi*2)+1)/2
        mp.x = mp.ox + mp.dx * s; mp.y = mp.oy + mp.dy * s
    end

    self.player:update(dt, self)
    self.player.x = math.max(self.player.x, self.cameraX + 18) -- no back movement behind camera
    if not self.player.alive then self.over = true end

    for _, e in ipairs(self.enemies) do if not e.dead then e:update(dt, self) end end
    self:updateAttacks(dt)
    self:updateEnemyShots(dt)

    for _, e in ipairs(self.enemies) do
        if not e.dead and Util.aabb(self.player, e:rect()) then self.player:hurt() end
    end

    if Util.aabb(self.player, self.level.goal) then self.win=true; self.audio:play("bell") end
    local target = self.player.x - Config.window.width * 0.35
    self.cameraX = Util.clamp(math.max(self.cameraX, target), 0, self.level.width - Config.window.width)
end

function World:updateAttacks(dt)
    for i=#self.attacks,1,-1 do
        local a = self.attacks[i]
        a.ttl = a.ttl - dt
        if a.vx then a.x = a.x + a.vx * dt end
        for _, e in ipairs(self.enemies) do
            if not e.dead and Util.aabb(a, e:rect()) then e:hurt(self, a.damage); if a.type=="ofuda" then a.ttl=0 end end
        end
        if a.ttl <= 0 then table.remove(self.attacks, i) end
    end
end

function World:updateEnemyShots(dt)
    for i=#self.enemyShots,1,-1 do
        local f = self.enemyShots[i]
        f.ttl = f.ttl - dt; f.x = f.x + f.vx * dt
        if Util.aabb(self.player, f) then self.player:hurt(); f.ttl=0 end
        if f.ttl <= 0 then table.remove(self.enemyShots, i) end
    end
end

function World:drawBackground()
    love.graphics.clear(0.02, 0.02, 0.08)
    for i=0,60 do
        local x = (i*173 - self.cameraX*0.25) % 1000
        love.graphics.setColor(0.3,0.8,1,0.35)
        love.graphics.points(x, 35 + (i*47)%220)
    end
    love.graphics.setColor(0.08,0.12,0.22)
    for x=-100, self.level.width, 220 do love.graphics.rectangle("fill", x-self.cameraX*0.3, 300, 130, 220) end
end

function World:draw()
    self:drawBackground()
    love.graphics.push(); love.graphics.translate(-math.floor(self.cameraX), 0)
    for _, d in ipairs(self.level.decorations) do self:drawDecoration(d) end
    love.graphics.setColor(0.2,0.9,1)
    for _, p in ipairs(self.platforms) do love.graphics.rectangle("fill", p.x,p.y,p.w,p.h); love.graphics.setColor(0.04,0.08,0.12); love.graphics.rectangle("line", p.x,p.y,p.w,p.h); love.graphics.setColor(0.2,0.9,1) end
    love.graphics.setColor(1,0.1,0.8)
    for _, p in ipairs(self.movingPlatforms) do love.graphics.rectangle("fill", p.x,p.y,p.w,p.h) end
    for _, e in ipairs(self.enemies) do if not e.dead then e:draw() end end
    for _, a in ipairs(self.attacks) do
        if a.type=="ofuda" then love.graphics.setColor(1,1,0.8); love.graphics.rectangle("fill", a.x,a.y,a.w,a.h); love.graphics.setColor(1,0,0); love.graphics.print("札", a.x+2, a.y-7)
        else love.graphics.setColor(1,1,1,0.4); love.graphics.rectangle("fill", a.x,a.y,a.w,a.h) end
    end
    for _, f in ipairs(self.enemyShots) do love.graphics.setColor(1,0.25,0.02); love.graphics.ellipse("fill", f.x,f.y,12,7) end
    self.player:draw()
    love.graphics.pop()
    love.graphics.setColor(1,1,1)
    love.graphics.print("Score "..self.score, 16, 12)
    love.graphics.print("Time "..math.max(0, math.ceil(self.timer)), 430, 12)
    love.graphics.print("HP "..self.player.hp, 850, 12)
    if self.startBanner > 0 then love.graphics.setColor(1,1,0); love.graphics.printf("START", 0, 210, 960, "center") end
    if self.win then love.graphics.printf("TEMPLE BELL RINGS! LEVEL CLEAR", 0, 230, 960, "center") end
    if self.over then love.graphics.printf("GAME OVER", 0, 230, 960, "center") end
end

function World:drawDecoration(d)
    if d.kind == "gate" then
        love.graphics.setColor(0.85,0.05,0.1); love.graphics.rectangle("fill", d.x,d.y,95,18); love.graphics.rectangle("fill", d.x+10,d.y+18,15,130); love.graphics.rectangle("fill", d.x+70,d.y+18,15,130)
        love.graphics.setColor(0.2,0.9,1); love.graphics.rectangle("line", d.x-6,d.y-8,107,166)
    elseif d.kind == "torii" then
        love.graphics.setColor(0.9,0.05,0.12); love.graphics.rectangle("fill", d.x,d.y,100,15); love.graphics.rectangle("fill", d.x+14,d.y+15,12,105); love.graphics.rectangle("fill", d.x+74,d.y+15,12,105)
    elseif d.kind == "moon" then love.graphics.setColor(0.75,0.85,1,0.7); love.graphics.circle("fill", d.x,d.y,42)
    else love.graphics.setColor(0.3,1,0.9); love.graphics.rectangle("line", d.x,d.y,30,80) end
end

return World
