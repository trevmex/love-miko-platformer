local Audio = {}
Audio.__index = Audio

local function tone(freq, seconds, volume)
    if not love or not love.sound then return nil end
    local rate = 22050
    local data = love.sound.newSoundData(math.floor(seconds * rate), rate, 16, 1)
    for i=0,data:getSampleCount()-1 do
        local t = i / rate
        local env = math.min(1, t/0.02) * math.max(0, 1 - t/seconds)
        data:setSample(i, math.sin(2*math.pi*freq*t) * env * (volume or 0.35))
    end
    return love.audio.newSource(data, "static")
end

function Audio.new()
    local self = setmetatable({ sounds = {}, music = nil }, Audio)
    if love and love.audio then
        self.sounds.jump = tone(660, 0.12, 0.25)
        self.sounds.attack = tone(880, 0.08, 0.22)
        self.sounds.paper = tone(990, 0.12, 0.18)
        self.sounds.hit = tone(160, 0.18, 0.28)
        self.sounds.bell = tone(220, 1.6, 0.45)
        self.sounds.fire = tone(110, 0.20, 0.18)
        self:makeMusic()
    end
    return self
end

function Audio:makeMusic()
    local rate, seconds = 22050, 16
    local data = love.sound.newSoundData(rate*seconds, rate, 16, 1)
    local scale = {392, 440, 523, 587, 659, 587, 523, 440} -- pentatonic-ish shamisen/koto pulse
    for i=0,data:getSampleCount()-1 do
        local t = i/rate
        local beat = math.floor(t*2) % #scale + 1
        local f = scale[beat]
        local pluck = math.exp(-((t*2)%1)*5)
        local sample = (math.sin(2*math.pi*f*t) + 0.35*math.sin(2*math.pi*f*2*t)) * pluck * 0.08
        sample = sample + math.sin(2*math.pi*98*t) * 0.035
        data:setSample(i, sample)
    end
    self.music = love.audio.newSource(data, "static")
    self.music:setLooping(true)
end

function Audio:play(name)
    local s = self.sounds[name]
    if s then s:stop(); s:play() end
end

function Audio:startMusic()
    if self.music and not self.music:isPlaying() then self.music:play() end
end

return Audio
