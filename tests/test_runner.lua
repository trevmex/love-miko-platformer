package.path = "./?.lua;./?/init.lua;" .. package.path

local passed, failed = 0, 0
local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then print("PASS " .. name); passed = passed + 1 else print("FAIL " .. name .. ": " .. tostring(err)); failed = failed + 1 end
end
local function assertEq(a,b,msg) assert(a == b, (msg or "") .. " expected "..tostring(b).." got "..tostring(a)) end
local function assertTrue(v,msg) assert(v, msg or "expected true") end

local Util = require("src.util")
local Config = require("src.config")
local Input = require("src.input")
local Level1 = require("src.levels.level1")
local Enemies = require("src.enemies")

test("AABB collision detects overlap and separation", function()
    assertTrue(Util.aabb({x=0,y=0,w=10,h=10},{x=9,y=9,w=10,h=10}))
    assertTrue(not Util.aabb({x=0,y=0,w=10,h=10},{x=11,y=0,w=10,h=10}))
end)

test("level one is SMB 1-1 scale and has required set pieces", function()
    assertTrue(Level1.width >= 3300 and Level1.width <= 3800, "level width should be about SMB 1-1")
    assertTrue(#Level1.platforms >= 10, "platform variety")
    assertTrue(#Level1.movingPlatforms >= 2, "moving platforms")
    assertTrue(Level1.goal.x > 3300, "temple goal at end")
end)

test("control defaults are programmable and match request", function()
    assertTrue(Input.isMapped("jump", "keyboard", ","))
    assertTrue(Input.isMapped("melee", "keyboard", "."))
    assertTrue(Input.isMapped("ranged", "keyboard", "/"))
    assertEq(Config.controls.gamepad.jump[1], "a")
    assertEq(Config.controls.gamepad.melee[1], "b")
    assertEq(Config.controls.gamepad.rangedAxis, "triggerright")
end)

test("enemy types award correct points", function()
    local fake = { score = 0, audio = { play = function() end } }
    local b = Enemies.new("blue", 0, 0); b:hurt(fake, 9); assertEq(fake.score, 100)
    local r = Enemies.new("red", 0, 0); r:hurt(fake, 1); assertEq(fake.score, 100); r:hurt(fake,1); assertEq(fake.score, 250)
    local y = Enemies.new("yellow", 0, 0); y:hurt(fake, 9); assertEq(fake.score, 450)
end)

test("timer default is 300 seconds", function()
    assertEq(Config.levelTimer, 300)
end)

print(("Tests: %d passed, %d failed"):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
