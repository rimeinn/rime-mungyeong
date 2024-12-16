-- mungyeong_auto_space_processor.lua
-- Commit script_text with a space(if needed) when space key is pressed

-- Why we don't use commit notifier:
-- - Commit notifier is not triggered when committing script_text
-- Why we don't modify the preedit to affect script_text:
-- - It affects the appearance of the preedit

require("utf8")
local kAccepted = 1
local kNoop = 2
local Top = {}
function Top.init(env)
    env.auto_space = env.engine.schema.config:get_bool("mungyeong/auto_space") or true
end

function Top.fini(env)
end

function Top.func(key_event, env)
    if key_event.keycode ~= 32 or key_event:release() then
        return kNoop
    end
    local script_text = env.engine.context:get_script_text()
    if script_text == "" then
        return kNoop
    end
    if env.auto_space then
        script_text = script_text .. " "
    end
    env.engine:commit_text(script_text)
    env.engine.context:clear()
    return kAccepted
end

return Top
