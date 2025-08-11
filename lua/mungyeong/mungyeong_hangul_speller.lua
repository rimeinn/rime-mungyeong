-- mungyeong_hangul_speller.lua
-- convert input to hangul
-- license: GPLv3
-- version: 0.1.0
-- author: kuroame
local kAccepted = 1
local kNoop = 2
local Top = {}
local hangul = require("mungyeong/mungyeong_hangul")
local function get_alphabet_suffix(text, alphabet)
    local suffix = ""
    for i = #text, 1, -1 do
        local ch = text:sub(i, i)
        if alphabet:find(ch, 1, true) then
            suffix = ch .. suffix
        else
            break
        end
    end
    return suffix
end

local function utf8_sub(s, i, j)
    i = i or 1
    j = j or -1
    local n = utf8.len(s)
    if not n then
        return nil
    end
    if i > n or -j > n then
        return ""
    end
    if i < 1 or j < 1 then
        if i < 0 then
            i = n + 1 + i
        end
        if j < 0 then
            j = n + 1 + j
        end
        if i < 0 then
            i = 1
        elseif i > n then
            i = n
        end
        if j < 0 then
            j = 1
        elseif j > n then
            j = n
        end
    end
    if j < i then
        return ""
    end
    i = utf8.offset(s, i)
    j = utf8.offset(s, j + 1)
    if i and j then
        return s:sub(i, j - 1)
    elseif i then
        return s:sub(i)
    else
        return ""
    end
end


function Top.init(env)
    env.prefix = env.engine.schema.config:get_string("mungyeong/prefix") or ""
    env.auto_space = env.engine.schema.config:get_bool("mungyeong/auto_space")
    env.cur_hangul = hangul:new()
    env.layout = "mungyeong_" .. env.engine.schema.config:get_string("mungyeong/layout") or "dubeolsik"
    local layout_schema = Schema(env.layout)
    env.alphabet = layout_schema.config:get_string("speller/alphabet") or
                       "zyxwvutsrqponmlkjihgfedcbaZTXWVUTSRQPONMLKJIHGFEDCBA"
    env.jamo_translator = Component.Translator(env.engine, layout_schema, "translator",
        "script_translator")
    env.jamo_reverse = ReverseLookup(env.layout)
    env.last_code = ""

    -- clean broken bytes & justify caret position
    local last_caret_pos = 0
    env.update_notifier = env.engine.context.update_notifier:connect(function(ctx)
        local input = ctx.input
        local len, error_pos = utf8.len(input)
        local caret_pos = ctx.caret_pos
        if not len then
            if caret_pos >= error_pos then
                env.cur_hangul.is_to_detach = true
                ctx:pop_input(1)
            else
                ctx:delete_input(1)
            end
        else
            local left_input = input:sub(1, caret_pos)
            if env.cur_hangul.is_to_detach then
                env.cur_hangul:detach()
                env.cur_hangul.is_to_detach = false
                local composed_hangul = env.cur_hangul:compose()
                if composed_hangul ~= "" then
                    ctx:push_input(composed_hangul)
                else
                    -- cur_hangul is empty, need to update it
                    env.cur_hangul = hangul.from_lit(utf8_sub(left_input, -1))
                end
                env.last_code = ""
                return
            end
            local _, error_pos = utf8.len(left_input)
            if error_pos then
                -- moved left
                if last_caret_pos > caret_pos then
                    ctx.caret_pos = error_pos - 1
                else -- moved right
                    local next_bound = utf8.offset(input, 2, error_pos)
                    ctx.caret_pos = next_bound and next_bound - 1 or #input
                end
            else
                last_caret_pos = ctx.caret_pos
                env.cur_hangul = hangul.from_lit(utf8_sub(left_input, -1))
                env.last_code = ""
            end
        end
    end, 0)
    env.commit_notifier = env
end

function Top.fini(env)
    env.jamo_translator = nil
    env.update_notifier:disconnect()
    collectgarbage()
end

function Top.func(key_event, env)
    if key_event:release() or key_event:ctrl() or key_event:alt() or key_event:super() then
        return kNoop
    end
    local keycode = key_event.keycode
    if keycode < 0x20 or keycode > 0x7E then
        return kNoop
    end
    local ch = string.char(keycode)
    local engine = env.engine
    local context = engine.context
    if ch == " " then
        context:clear_non_confirmed_composition()
        context:commit()
        env.cur_hangul = hangul:new()
        if env.auto_space then
            engine:commit_text(" ")
        end
        return kAccepted
    end
    -- if not in the alphabet, ignore it
    if not env.alphabet:find(ch, 1, true) then
        return kNoop
    end
    local cur_hangul_len = #env.cur_hangul:compose()
    if env.last_code ~= "" then
        env.cur_hangul:detach()
    end
    local jamos,last_code = Top.query_jamo_translator(env.last_code .. ch, env)
    env.last_code = last_code
    local str = hangul.convert_jamo_to_hangul(env.cur_hangul:to_jamo_string() .. jamos)
    if cur_hangul_len > 0 then
        context:pop_input(cur_hangul_len)
    end
    context:push_input(str)
    return kAccepted
end

function Top.query_jamo_translator(input, env)
    local pseudo_seg = Segment(0, #input)
    pseudo_seg.tags = Set {"abc"}
    local xlation = env.jamo_translator:query(input, pseudo_seg)
    if xlation then
        local nxt, thisobj = xlation:iter()
        local cand = nxt(thisobj)
        if cand == nil then
            return "", nil
        end
        
        return cand.text, cand.preedit:match("%S+$") or cand.preedit
    end
    return nil
end
return Top