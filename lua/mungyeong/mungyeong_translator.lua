-- mungyeong_translator.lua
-- main translator of mungyeong

-- license: GPLv3
-- version: 0.1.0
-- author: kuroame

local utf8 = require("utf8")
local Top = {}

function Top.init(env)
    env.layout = env.engine.schema.config:get_string("mungyeong/layout") or "dubeolsik"
    env.jamo_translator = Component.Translator(env.engine, Schema("mungyeong_"..env.layout), "translator", "script_translator")
    env.jamo2hangul = Opencc("mungyeong_jamo2hangul.json")
end

function Top.fini(env)
    env.jamo_translator = nil
    collectgarbage()
end

function Top.func(input, seg, env)
    local jamo_cand = Top.query_jamo_translator(input, seg, env)
    if jamo_cand then
        local jamo_str = jamo_cand.text
        -- Problem: ㅇㅏㅁㅣ -> 암ㅣ x 아미 ✔
        local hangul_str = env.jamo2hangul:convert(jamo_str)
        if hangul_str then
            -- TODO: Translate to hanja
            yield(Candidate("hangul", seg.start, seg._end, hangul_str, ""))
        else
            yield(Candidate("jamo", seg.start, seg._end, jamo_str, ""))
        end
    end
end

-- translate input string to jamos
function Top.query_jamo_translator(input, seg, env)
    local xlation = env.jamo_translator:query(input, seg)
    if xlation then
        local nxt, thisobj = xlation:iter()
        local cand = nxt(thisobj)
        return cand
    end
    return nil
end

return Top
