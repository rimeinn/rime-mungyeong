-- mungyeong_translator.lua
-- main translator of mungyeong
-- license: GPLv3
-- version: 0.1.0
-- author: kuroame
local utf8 = require("utf8")
local hangul = require("mungyeong/mungyeong_hangul")
local Top = {}

function Top.init(env)
    env.layout = env.engine.schema.config:get_string("mungyeong/layout") or "dubeolsik"
    env.jamo_translator = Component.Translator(env.engine, Schema("mungyeong_" .. env.layout), "translator",
        "script_translator")
    env.hanja_translator = Component.Translator(env.engine, Schema("mungyeong"), "translator", "table_translator")
    env.tag = env.engine.schema.config:get_string("mungyeong/tag") or ""
end

function Top.fini(env)
    env.jamo_translator = nil
    env.hanja_translator = nil
    collectgarbage()
end

function Top.func(input, seg, env)
    if env.tag ~= "" and not seg:has_tag(env.tag) then
        return
    end
    local start = seg.start
    local _end = seg._end
    local jamo_cand = Top.query_jamo_translator(input, env)
    if jamo_cand then
        local jamo_str = jamo_cand.text
        local hangul_str = hangul.convert_jamo_to_hangul(jamo_str)
        if input:sub(-1) == "'" then
            hangul_str = hangul_str .. "'"
        end
        if hangul_str then
            local has_hanja_cand = false
            local hangul_candidate = Candidate("hangul", start, _end, hangul_str, "")
            hangul_candidate.preedit = hangul_str
            if env.name_space == "as_addon" then
                yield(hangul_candidate)
            end
            for hanja_cand in Top.query_hanja_translator(hangul_str, env) do
                has_hanja_cand = true
                -- hanja_cand.preedit = hangul_str
                hanja_cand.start = start
                hanja_cand._end = _end
                local dtype = hanja_cand:get_dynamic_type()
                -- Workaround for addon configuration limitation:
                -- Since hanja_translator config is read from engine_->schema()->config(),
                -- we cannot modify it when running as an addon.
                -- Only yield candidate if dtype is "Phrase"(including user_phrase) and preedit matches hangul_str
                if dtype == "Phrase" and hanja_cand.preedit == hangul_str then
                    yield(hanja_cand)
                end
            end
            if not has_hanja_cand and env.name_space ~= "as_addon" then
                yield(hangul_candidate)
            end
        end
    end
end

-- translate input string to jamos
function Top.query_jamo_translator(input, env)
    local seg = Segment(0, utf8.len(input))
    seg.tags = Set({"abc"})
    local xlation = env.jamo_translator:query(input, seg)
    if xlation then
        local nxt, thisobj = xlation:iter()
        local cand = nxt(thisobj)
        return cand
    end
    return nil
end

-- translate input string to hanja
function Top.query_hanja_translator(input, env)
    local seg = Segment(0, utf8.len(input))
    seg.tags = Set({"abc"})
    local xlation = env.hanja_translator:query(input, seg)
    if xlation then
        local nxt, thisobj = xlation:iter()
        return function()
            local cand = nxt(thisobj)
            return cand
        end
    end
    return nil
end

return Top