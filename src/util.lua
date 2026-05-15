local Util = {}

function Util.aabb(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

function Util.sign(v)
    if v < 0 then return -1 end
    return 1
end

function Util.clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

function Util.copy(t)
    local out = {}
    for k, v in pairs(t) do
        if type(v) == "table" then out[k] = Util.copy(v) else out[k] = v end
    end
    return out
end

return Util
