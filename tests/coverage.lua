local Coverage = { hits = {}, started = false }

local function normalize(path)
    path = tostring(path or ""):gsub("^@", ""):gsub("\\", "/")
    path = path:gsub("^%./", "")
    return path
end

local sourceLines = {}

local function inSrc(path)
    path = normalize(path)
    return path:match("^src/") ~= nil or path:match("/src/") ~= nil
end

local function lineText(src, line)
    if not sourceLines[src] then
        sourceLines[src] = {}
        local f = io.open(src, "r")
        if f then
            local n = 1
            for text in f:lines() do sourceLines[src][n] = text; n = n + 1 end
            f:close()
        end
    end
    return sourceLines[src][line] or ""
end

local function isTrackable(src, line)
    local text = lineText(src, line):match("^%s*(.-)%s*$")
    return text ~= "" and text ~= "end" and text ~= "else" and not text:match("^%-%-")
end

function Coverage.start()
    Coverage.hits = {}
    Coverage.started = true
    debug.sethook(function(_, line)
        local info = debug.getinfo(2, "S")
        local src = normalize(info and info.source)
        if inSrc(src) then
            Coverage.hits[src] = Coverage.hits[src] or {}
            Coverage.hits[src][line] = true
        end
    end, "l")
end

function Coverage.stop()
    debug.sethook()
    Coverage.started = false
end

local function addFunction(fn, required, seenFns, seenTables)
    if seenFns[fn] then return end
    seenFns[fn] = true
    local info = debug.getinfo(fn, "SL")
    local src = normalize(info and info.source)
    if inSrc(src) then
        required[src] = required[src] or {}
        if info.activelines then
            for line in pairs(info.activelines) do if isTrackable(src, line) then required[src][line] = true end end
        end
    end
    local i = 1
    while true do
        local name, value = debug.getupvalue(fn, i)
        if not name then break end
        if name ~= "_ENV" then
            if type(value) == "function" then addFunction(value, required, seenFns, seenTables)
            elseif type(value) == "table" then Coverage.collect(value, required, seenFns, seenTables) end
        end
        i = i + 1
    end
end

function Coverage.collect(value, required, seenFns, seenTables)
    required = required or {}
    seenFns = seenFns or {}
    seenTables = seenTables or {}
    local tv = type(value)
    if tv == "function" then addFunction(value, required, seenFns, seenTables); return required end
    if tv ~= "table" or seenTables[value] then return required end
    seenTables[value] = true
    local mt = getmetatable(value)
    if mt then Coverage.collect(mt, required, seenFns, seenTables) end
    for _, v in pairs(value) do
        if type(v) == "function" then addFunction(v, required, seenFns, seenTables)
        elseif type(v) == "table" then Coverage.collect(v, required, seenFns, seenTables) end
    end
    return required
end

function Coverage.assertFull(values)
    Coverage.stop()
    local required = {}
    for _, value in ipairs(values) do Coverage.collect(value, required) end
    local missing, total = {}, 0
    for src, lines in pairs(required) do
        for line in pairs(lines) do
            total = total + 1
            if not (Coverage.hits[src] and Coverage.hits[src][line]) then
                missing[#missing+1] = ("%s:%d"):format(src, line)
            end
        end
    end
    table.sort(missing)
    assert(#missing == 0, ("coverage %.1f%% (%d/%d lines), missing:\n%s"):format(
        total == 0 and 100 or ((total - #missing) * 100 / total),
        total - #missing,
        total,
        table.concat(missing, "\n")
    ))
    print(("Coverage: 100%% (%d/%d executable function lines)"):format(total, total))
end

return Coverage
