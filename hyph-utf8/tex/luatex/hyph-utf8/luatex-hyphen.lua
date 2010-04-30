-- 
--  This is file `luatex-hyphen.lua',
--  generated with the docstrip utility.
-- 
--  The original source files were:
-- 
--  luatex-hyphen.dtx  (with options: `lua')
--  
--  This is a generated file (source: luatex-hyphen.dtx).
--  
--  Copyright (C) 2010 by The LuaLaTeX development team.
--  
--  This work is under the CC0 license.
--  

luatexhyphen = {}

luatexhyphen.version = "1.3beta"

local dbname = "language.dat.lua"

local function warn (msg, ...)
    texio.write_nl('luatex-hyphen: '..string.format(msg, ...))
end

luatexhyphen.language_dat = {}
local dbfile = kpse.find_file(dbname)
if not dbfile then
    warn("file not found: "..dbname)
else
    luatexhyphen.language_dat = dofile(dbfile)
end

function luatexhyphen.lookupname(l)
    if luatexhyphen.language_dat[l] then
        return luatexhyphen.language_dat[l], l
    else
        for orig,lt in pairs(luatexhyphen.language_dat) do
            for _,syn in ipairs(lt.synonyms) do
                if syn == l then
                    return lt, orig
                end
            end
        end
    end
    return nil
end

function luatexhyphen.loadlanguage(l, id)
    local lt, orig = luatexhyphen.lookupname(l)
    if not lt then
        warn("no entry in %s for this language: %s", dbname, l)
        return
    end
    local msg = "loading%s patterns and exceptions for: %s (\\language%d)"
    if lt.special then
        if lt.special == 'null' then
            warn(msg, ' (null)', orig, id)
        elseif lt.special:find('^disabled:') then
            warn("language disabled by %s: %s (%s)", dbname, orig,
                lt.special:gsub('^disabled:', ''))
        else
            warn("bad entry in %s for language %s")
        end
        return
    end
    warn(msg, '', orig, id)
    for ext, fun in pairs({pat = lang.patterns, hyp = lang.hyphenation}) do
        local n = 'hyph-'..lt.code..'.'..ext..'.txt'
        local f = kpse.find_file(n)
        if not f then
            warn("file not found: %s", n)
            return
        end
        f = io.open(f, 'r')
        local data = f:read('*a')
        f:close()
        if not data then
            warn("file not readable: %s", f)
            return
        end
        fun(lang.new(id), data)
    end
end
-- 
--  End of File `luatex-hyphen.lua'.