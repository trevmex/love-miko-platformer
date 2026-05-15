package.path = "./?.lua;./?/init.lua;" .. package.path

local Coverage = require("tests.coverage")
Coverage.start()

local passed, failed = 0, 0
local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then print("PASS " .. name); passed = passed + 1 else print("FAIL " .. name .. ": " .. tostring(err)); failed = failed + 1 end
end
local function assertEq(a,b,msg) assert(a == b, (msg or "") .. " expected "..tostring(b).." got "..tostring(a)) end
local function assertTrue(v,msg) assert(v, msg or "expected true") end

local loveState = { keys = {}, joysticks = {}, quit = false }
love = {
    keyboard = { isDown = function(key) return loveState.keys[key] or false end },
    joystick = { getJoysticks = function() return loveState.joysticks end },
    window = { setMode = function(w, h, opts) loveState.mode = {w=w, h=h, opts=opts}; return true end, setTitle = function(title) loveState.title = title end },
    event = { quit = function() loveState.quit = true end },
    graphics = {},
    sound = {},
    audio = {}
}
for _, name in ipairs({"setColor","circle","rectangle","polygon","setFont","printf","clear","line","points","push","pop","translate","ellipse","arc","print","setDefaultFilter"}) do
    love.graphics[name] = function(...) loveState.lastGraphics = {name, ...} end
end
love.graphics.newFont = function(size) return {size=size} end
love.sound.newSoundData = function(samples, rate, bits, channels)
    local data = {samples=samples, rate=rate, bits=bits, channels=channels, set={}}
    function data:getSampleCount() return math.min(4, self.samples) end
    function data:setSample(i, sample) self.set[i] = sample end
    return data
end
love.audio.newSource = function(data, kind)
    local source = {data=data, kind=kind, playing=false, looping=false, stops=0, plays=0}
    function source:stop() self.stops = self.stops + 1; self.playing = false end
    function source:play() self.plays = self.plays + 1; self.playing = true end
    function source:isPlaying() return self.playing end
    function source:setLooping(v) self.looping = v end
    return source
end

local Util = require("src.util")
local Config = require("src.config")
local Input = require("src.input")
local Level1 = require("src.levels.level1")
local Enemies = require("src.enemies")
local Game = require("src.game")
local Player = require("src.player")
local World = require("src.world")
local Audio = require("src.audio")

local coverageWorld, coverageEnemy, coverageAudio

local function makeWorld()
    local level = {
        width = 1200, height = 540, start = {x=80, y=380}, goal = {x=1000,y=350,w=80,h=150},
        platforms = {{x=0,y=500,w=500,h=40},{x=200,y=430,w=100,h=20}},
        movingPlatforms = {{x=300,y=400,w=80,h=16,dx=100,dy=0,speed=50}},
        enemies = {{kind="blue", x=260, y=450},{kind="red", x=360, y=450},{kind="yellow", x=460, y=260}},
        decorations = {{kind="gate",x=10,y=10},{kind="torii",x=120,y=10},{kind="moon",x=240,y=50},{kind="antenna",x=340,y=20}}
    }
    return World.new(level)
end

local function resetInput()
    loveState.keys = {}; loveState.joysticks = {}; Input.beginFrame(); Input.axes = { triggerright = 0 }; Config.resetControls()
end

test("utility helpers cover collision, signs, clamps, and copies", function()
    assertTrue(Util.aabb({x=0,y=0,w=10,h=10},{x=9,y=9,w=10,h=10}))
    assertTrue(not Util.aabb({x=0,y=0,w=10,h=10},{x=11,y=0,w=10,h=10}))
    assertEq(Util.sign(-3), -1); assertEq(Util.sign(0), 1)
    assertEq(Util.clamp(-1, 0, 5), 0); assertEq(Util.clamp(9, 0, 5), 5); assertEq(Util.clamp(3, 0, 5), 3)
    local original = {a=1, b={c=2}}; local copy = Util.copy(original); copy.b.c = 3; assertEq(original.b.c, 2)
end)

test("level one is SMB 1-1 scale and has required set pieces", function()
    assertTrue(Level1.width >= 3300 and Level1.width <= 3800, "level width should be about SMB 1-1")
    assertTrue(#Level1.platforms >= 10, "platform variety")
    assertTrue(#Level1.movingPlatforms >= 2, "moving platforms")
    assertTrue(Level1.goal.x > 3300, "temple goal at end")
end)

test("controls and input support keyboard, gamepad, axes, remap, and reset", function()
    resetInput()
    assertTrue(Input.isMapped("jump", "keyboard", ",")); assertTrue(Input.isMapped("restart", "gamepad", "start"))
    Config.setKeyboardBinding("jump", "space"); assertTrue(Input.isMapped("jump", "keyboard", "space")); assertTrue(not Input.isMapped("jump", "keyboard", ","))
    loveState.keys.d = true; assertTrue(Input.isDown("right")); loveState.keys.d = false; assertTrue(not Input.isDown("left"))
    Input.keypressed("space"); assertTrue(Input.wasPressed("jump")); Input.beginFrame(); assertTrue(not Input.wasPressed("jump"))
    Input.gamepadpressed(nil, "a"); assertTrue(Input.wasPressed("select"))
    loveState.joysticks = {{isGamepadDown=function(_, btn) return btn == "b" end}}
    assertTrue(Input.isDown("melee")); assertTrue(not Input.isDown("up"))
    Input.gamepadaxis(nil, "triggerright", 0.8); assertTrue(Input.isDown("ranged"))
    Config.resetControls()
end)

test("config menu navigation, binding, reset, fullscreen, and back work", function()
    assertTrue(#Config.controlActions >= 7); assertEq(Config.display.fullscreen, false)
    local items = Game.configItems(); assertEq(#items, #Config.controlActions + 3); assertEq(items[1].kind, "control")
    Game.state = "select"; Game.openConfig(); assertEq(Game.state, "config"); assertEq(Game.previousState, "select")
    Game.configIndex = 1; Game.configKeypressed("up"); assertEq(Game.configIndex, #Game.configItems()); Game.configKeypressed("down"); assertEq(Game.configIndex, 1)
    Game.configKeypressed("s"); Game.configKeypressed("w"); Game.configKeypressed("space"); assertTrue(Game.waitingForKey ~= nil)
    Game.configKeypressed("j"); assertTrue(Input.isMapped("left", "keyboard", "j"))
    Game.activateConfigItem(); Game.configKeypressed("escape"); assertTrue(Input.isMapped("left", "keyboard", "j"))
    Game.configIndex = #Config.controlActions + 1; Game.configKeypressed("f"); assertEq(Config.display.fullscreen, true); Game.configKeypressed("left"); assertEq(Config.display.fullscreen, false)
    Game.configIndex = #Config.controlActions + 2; Game.activateConfigItem(); assertTrue(Input.isMapped("left", "keyboard", "a"))
    Game.configGamepadpressed("dpdown"); Game.configGamepadpressed("dpup"); Game.configGamepadpressed("a")
    Game.configIndex = #Config.controlActions + 3; Game.activateConfigItem(); assertEq(Game.state, "select")
    Game.openConfig(); Game.configGamepadpressed("b"); assertEq(Game.state, "select")
    Game.openConfig(); Game.configKeypressed("c"); assertEq(Game.state, "select")
end)

test("audio generates sounds, plays effects, and starts looping music", function()
    coverageAudio = Audio.new()
    assertTrue(coverageAudio.sounds.jump ~= nil)
    coverageAudio:play("jump"); assertEq(coverageAudio.sounds.jump.plays, 1)
    coverageAudio:play("missing")
    coverageAudio:startMusic(); assertTrue(coverageAudio.music.playing); coverageAudio:startMusic()
    local oldLove = love; love = nil; local silent = Audio.new(); assertEq(next(silent.sounds), nil); love = oldLove
end)

test("enemy behavior updates all oni types, damage, rects, and drawing", function()
    local fake = { score = 0, audio = { play = function() end }, player = {x=0,y=500}, moveActor = function(_, a) a.onGround = true end, spawnFire = function(self) self.fired = true end }
    local blue = Enemies.new("blue", 0, 0); blue.onGround = true; blue.t = 2; blue:update(0.1, fake); assertTrue(blue:rect().w == blue.w)
    local oldRandom = math.random; math.random = function() return 0 end; blue:update(0.1, fake); math.random = oldRandom
    local red = Enemies.new("red", 10, 0); red.cooldown = 0; red:update(0.1, fake); assertTrue(fake.fired)
    local yellow = Enemies.new("yellow", 10, 250); yellow:update(0.1, fake); fake.player.y = 0; yellow.y = yellow.y0 + 200; yellow:update(0.1, fake); yellow.y = yellow.y0 - 100; yellow:update(0.1, fake)
    red:hurt(fake, 1); red:hurt(fake, 1); assertEq(fake.score, 150)
    coverageEnemy = yellow; coverageEnemy:draw()
end)

test("player update handles movement, joy axis, jump, attacks, damage, and draw", function()
    resetInput()
    local p = Player.new(20, 20)
    local world = { audio = { play = function() end }, moveActor = function(_, a) a.onGround = true end, spawnMelee = function(self) self.melee = true end, spawnOfuda = function(self) self.ofuda = true end }
    loveState.keys.a = true; Input.keypressed(","); Input.keypressed("."); Input.keypressed("/"); p.onGround = true; p:update(0.1, world)
    assertTrue(world.melee and world.ofuda); assertEq(p.dir, -1)
    resetInput(); loveState.joysticks = {{isGamepad=function() return true end, getGamepadAxis=function() return 0.8 end}}; p:update(0.1, world); assertEq(p.dir, 1)
    p.y = Config.window.height + 161; p.invuln = 0; p:update(0.1, world); assertTrue(p.hp < 3)
    p.invuln = 1; assertTrue(not p:hurt()); p.invuln = 0; p.hp = 1; assertTrue(p:hurt()); assertTrue(not p.alive)
    p.invuln = 0; p:draw(); p.invuln = 1.0; p:draw()
end)

test("world runtime covers creation, movement, spawns, updates, collisions, win, over, and drawing", function()
    resetInput()
    coverageWorld = makeWorld()
    assertTrue(#coverageWorld:solidPlatforms() > #coverageWorld.platforms)
    local actor = {x=190,y=415,w=20,h=20,vx=100,vy=0}; coverageWorld:moveActor(actor, 0.2); assertEq(actor.vx, 0)
    actor = {x=310,y=415,w=20,h=20,vx=-100,vy=0}; coverageWorld:moveActor(actor, 0.2); assertEq(actor.vx, 0)
    actor = {x=210,y=390,w=20,h=20,vx=0,vy=100}; coverageWorld:moveActor(actor, 0.3); assertTrue(actor.onGround)
    actor = {x=210,y=460,w=20,h=20,vx=0,vy=-100}; coverageWorld:moveActor(actor, 0.3); assertEq(actor.vy, 0)
    coverageWorld:spawnMelee(coverageWorld.player); coverageWorld:spawnOfuda(coverageWorld.player); coverageWorld:spawnFire(100,100,1)
    coverageWorld.startBanner = 1; coverageWorld:update(0.1)
    coverageWorld.startBanner = 0; coverageWorld.player.x = coverageWorld.level.goal.x; coverageWorld.player.y = coverageWorld.level.goal.y; coverageWorld:update(0.1); assertTrue(coverageWorld.win, "goal should set win")
    coverageWorld.win = false; coverageWorld.timer = 0.01; coverageWorld:update(0.1); assertTrue(coverageWorld.over, "timer should set game over")
    coverageWorld.over = false; coverageWorld.win = false; coverageWorld.player.alive = false; coverageWorld.player.x = 80; coverageWorld.timer = 10; coverageWorld:update(0.1); assertTrue(coverageWorld.over, "dead player should set game over")
    coverageWorld:updateAttacks(3); coverageWorld:updateEnemyShots(3)
    coverageWorld:spawnMelee(coverageWorld.player); coverageWorld:spawnOfuda(coverageWorld.player); coverageWorld:spawnFire(100,100,1)
    coverageWorld:drawBackground(); coverageWorld.win = true; coverageWorld.over = true; coverageWorld.startBanner = 0.5; coverageWorld:draw()
    for _, d in ipairs(coverageWorld.level.decorations) do coverageWorld:drawDecoration(d) end
end)

test("game state callbacks cover load, update, draw, key, gamepad, and axis paths", function()
    resetInput(); Game.load(); assertEq(Game.state, "splash")
    Game.drawMikoPreview(10, 10); Game.draw()
    Game.keypressed("return"); assertEq(Game.state, "select"); Game.draw()
    Game.keypressed("return"); assertEq(Game.state, "playing")
    Game.update(0.01); Game.draw()
    Game.world.over = true; Game.keypressed("r"); assertEq(Game.state, "playing")
    Game.keypressed("c"); assertEq(Game.state, "config"); Game.draw(); Game.keypressed("escape"); Game.keypressed("escape"); assertTrue(loveState.quit)
    Game.state = "splash"; Input.beginFrame(); Game.gamepadpressed(nil, "start"); assertEq(Game.state, "select")
    Input.beginFrame(); Game.gamepadpressed(nil, "a"); assertEq(Game.state, "playing")
    Game.world.over = true; Input.beginFrame(); Game.gamepadpressed(nil, "start"); assertEq(Game.state, "playing")
    Game.gamepadpressed(nil, "back"); assertEq(Game.state, "config")
    Game.gamepadaxis(nil, "triggerright", 0.6); assertEq(Input.axes.triggerright, 0.6)
end)

test("coverage remains at 100 percent for executable source functions", function()
    local ok, err = pcall(function()
        Coverage.assertFull({Util, Config, Input, Enemies, Game, Player, World, Audio, coverageWorld, coverageEnemy, coverageAudio})
    end)
    assertTrue(ok, err)
end)

print(("Tests: %d passed, %d failed"):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
