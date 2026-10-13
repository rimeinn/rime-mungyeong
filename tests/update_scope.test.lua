-- Run from the repository root: lua tests/update_scope.test.lua [speller.lua]
package.path = "./lua/?.lua;" .. package.path
local speller = dofile(arg[1] or "lua/mungyeong/mungyeong_hangul_speller.lua")
local config = {
    get_string = function(_, key)
        if key == "mungyeong/layout" then return "dubeolsik" end
    end,
    get_bool = function() return false end,
}
Schema = function() return {config = config} end
Component = {Translator = function() return {} end}
ReverseLookup = function() return {} end

local function check(input, caret, tag, expected_hangul)
    local callback
    local context = {
        input = input,
        caret_pos = caret,
        composition = {back = function()
            if tag then return {has_tag = function(_, name) return name == tag end} end
        end},
        update_notifier = {connect = function(_, fn)
            callback = fn
            return {disconnect = function() end}
        end},
        pop_input = function() error("must not delete foreign input") end,
        delete_input = function() error("must not delete foreign input") end,
        push_input = function() error("must not insert into foreign input") end,
    }
    local env = {engine = {context = context, schema = {config = config}}}
    speller.init(env)
    callback(context)
    assert(context.input == input and context.caret_pos == caret,
           "must not modify foreign input or its caret")
    assert(env.cur_hangul:compose() == expected_hangul)
    speller.fini(env)
end

-- Foreign BackSpace/Delete leaves incomplete UTF-8 for its owning speller.
check("ok" .. ("か"):sub(1, 2), 4, "kagiroi", "")
check("ok" .. ("か"):sub(2), 2, "kagiroi", "")
-- Moving inside another speller's character must not adjust its caret.
check("okかな", 3, "kagiroi", "")
check("okかな", 8, "kagiroi", "")
-- First insertion precedes Rime resegmentation: local Hangul state is needed.
check("ㄱ", 3, nil, "ㄱ")
check("omㄱ", 5, "mungyeong_prefix", "ㄱ")
check("", 0, nil, "")
print("7 update-scope checks passed")
