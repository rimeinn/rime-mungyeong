-- mungyeong_translator.lua
-- main translator of mungyeong
-- license: GPLv3
-- version: 0.2.0
-- author: kuroame
local Top = {}

local function rebase_candidate(cand, seg)
    local rebased = Candidate(
        cand.type,
        seg.start + cand.start,
        seg.start + cand._end,
        cand.text,
        cand.comment or ""
    )
    rebased.preedit = cand.preedit
    if cand.quality then
        rebased.quality = cand.quality
    end
    return rebased
end

function Top.init(env)
    env.translator = Component.Translator(env.engine, Schema("mungyeong"), "translator", "script_translator")
    env.tag = env.engine.schema.config:get_string("mungyeong/tag") or "mungyeong"
end

function Top.fini(env)
    env.translator = nil
    collectgarbage()
end

function Top.func(input, seg, env)
    if env.tag ~= "" and not seg:has_tag(env.tag) then
        return
    end
    local start = seg.start
    local _end = seg._end
    if env.name_space == "as_addon" then
        local hangul_candidate = Candidate("hangul", start, _end, input, "")
        hangul_candidate.preedit = input
        yield(hangul_candidate)
    end
    if env.engine.context:get_option("candidates") then 
        for hanja_cand in Top.query_translator(input, env) do
            yield(rebase_candidate(hanja_cand, seg))
        end
    end
end
-- translate input string to hanja
function Top.query_translator(input, env)
    local seg = Segment(0, #input)
    seg.tags = Set({"abc"})
    local xlation = env.translator:query(input, seg)
    if xlation then
        local nxt, thisobj = xlation:iter()
        return function()
            local cand = nxt(thisobj)
            return cand
        end
    end
    return function()
        return nil
    end
end

return Top