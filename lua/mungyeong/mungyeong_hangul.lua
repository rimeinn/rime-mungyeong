-- mungyeong_hangul.lua
-- Hangul analysis helper

local utf8 = require("utf8")
local Module = {}

-- @param string utf8
-- @param i start_pos
-- @param j end_pos
function Module.utf8_sub(s, i, j)
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

function Module.utf8_char_iter(s)
    local i = 0
    local len = utf8.len(s)
    return function()
        i = i + 1
        if i <= len then
            return Module.utf8_sub(s, i, i)
        end
    end
end

local HANGUL_BASE = 0xAC00
local ONSET_BASE = 21 * 28
local VOWEL_BASE = 28
local SPACE_CODEPOINT = 0x0020

local ON_SET = {
    [0x3131] = 0, -- ㄱ
    [0x3132] = 1, -- ㄲ
    [0x3134] = 2, -- ㄴ
    [0x3137] = 3, -- ㄷ
    [0x3138] = 4, -- ㄸ
    [0x3139] = 5, -- ㄹ
    [0x3141] = 6, -- ㅁ
    [0x3142] = 7, -- ㅂ
    [0x3143] = 8, -- ㅃ
    [0x3145] = 9, -- ㅅ
    [0x3146] = 10, -- ㅆ
    [0x3147] = 11, -- ㅇ
    [0x3148] = 12, -- ㅈ
    [0x3149] = 13, -- ㅉ
    [0x314A] = 14, -- ㅊ
    [0x314B] = 15, -- ㅋ
    [0x314C] = 16, -- ㅌ
    [0x314D] = 17, -- ㅍ
    [0x314E] = 18 -- ㅎ
}

local VOWEL_SET = {
    [0x314F] = 0, -- ㅏ
    [0x3150] = 1, -- ㅐ
    [0x3151] = 2, -- ㅑ
    [0x3152] = 3, -- ㅒ
    [0x3153] = 4, -- ㅓ
    [0x3154] = 5, -- ㅔ
    [0x3155] = 6, -- ㅕ
    [0x3156] = 7, -- ㅖ
    [0x3157] = 8, -- ㅗ
    [0x3158] = 9, -- ㅘ
    [0x3159] = 10, -- ㅙ
    [0x315A] = 11, -- ㅚ
    [0x315B] = 12, -- ㅛ
    [0x315C] = 13, -- ㅜ
    [0x315D] = 14, -- ㅝ
    [0x315E] = 15, -- ㅞ
    [0x315F] = 16, -- ㅟ
    [0x3160] = 17, -- ㅠ
    [0x3161] = 18, -- ㅡ
    [0x3162] = 19, -- ㅢ
    [0x3163] = 20 -- ㅣ
}

local CODA_SET = {
    [0x0020] = 0, -- Space
    [0x3131] = 1, -- ㄱ
    [0x3132] = 2, -- ㄲ
    [0x3133] = 3, -- ㄳ
    [0x3134] = 4, -- ㄴ
    [0x3135] = 5, -- ㄵ
    [0x3136] = 6, -- ㄶ
    [0x3137] = 7, -- ㄷ
    [0x3139] = 8, -- ㄹ
    [0x313A] = 9, -- ㄺ
    [0x313B] = 10, -- ㄻ
    [0x313C] = 11, -- ㄼ
    [0x313D] = 12, -- ㄽ
    [0x313E] = 13, -- ㄾ
    [0x313F] = 14, -- ㄿ
    [0x3140] = 15, -- ㅀ
    [0x3141] = 16, -- ㅁ
    [0x3142] = 17, -- ㅂ
    [0x3144] = 18, -- ㅄ
    [0x3145] = 19, -- ㅅ
    [0x3146] = 20, -- ㅆ
    [0x3147] = 21, -- ㅇ
    [0x3148] = 22, -- ㅈ
    [0x314A] = 23, -- ㅊ
    [0x314B] = 24, -- ㅋ
    [0x314C] = 25, -- ㅌ
    [0x314D] = 26, -- ㅍ
    [0x314E] = 27 -- ㅎ
}

local DOUBLE_CODA_MAP = {
    [0x3133] = {0x3131, 0x3145}, -- ㄳ
    [0x3135] = {0x3134, 0x3148}, -- ㄵ
    [0x3136] = {0x3134, 0x314E}, -- ㄶ
    [0x313A] = {0x3139, 0x3131}, -- ㄺ
    [0x313B] = {0x3139, 0x3141}, -- ㄻ
    [0x313C] = {0x3139, 0x3142}, -- ㄼ
    [0x313D] = {0x3139, 0x3145}, -- ㄽ
    [0x313E] = {0x3139, 0x314C}, -- ㄾ
    [0x313F] = {0x3139, 0x314D}, -- ㄿ
    [0x3140] = {0x3139, 0x314E}, -- ㅀ
    [0x3144] = {0x3142, 0x3145} -- ㅄ
}

local DOUBLE_CODA_MAP_REVERSE = {
    [0x3131] = {
        [0x3145] = 0x3133 -- ㄳ
    },
    [0x3134] = {
        [0x3148] = 0x3135, -- ㄵ
        [0x314E] = 0x3136 -- ㄶ
    },
    [0x3139] = {
        [0x3131] = 0x313A, -- ㄺ
        [0x3141] = 0x313B, -- ㄻ
        [0x3142] = 0x313C, -- ㄼ
        [0x3145] = 0x313D, -- ㄽ
        [0x314C] = 0x313E, -- ㄾ
        [0x314D] = 0x313F, -- ㄿ
        [0x314E] = 0x3140 -- ㅀ
    },
    [0x3142] = {
        [0x3145] = 0x3144 -- ㅄ
    }
}

local Hangul = {on, vowel, coda}

function Hangul:new()
    local o = {
        on = SPACE_CODEPOINT,
        vowel = SPACE_CODEPOINT,
        coda = SPACE_CODEPOINT
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Check if the hangul has an on
function Hangul:has_on()
    return self.on ~= SPACE_CODEPOINT
end

-- Check if the hangul has a vowel
function Hangul:has_vowel()
    return self.vowel ~= SPACE_CODEPOINT
end

-- Check if the hangul has a coda
function Hangul:has_coda()
    return self.coda ~= SPACE_CODEPOINT
end

-- Check if the coda is a double coda
function Hangul:has_double_coda()
    return DOUBLE_CODA_MAP[self.coda] ~= nil
end

-- Check if the hangul is waiting for an on
function Hangul:wait_for_on()
    return not self:has_on() and not self:has_vowel() and not self:has_coda()
end

-- Check if the hangul is waiting for a vowel
function Hangul:wait_for_vowel()
    return self:has_on() and not self:has_vowel() and not self:has_coda()
end

-- Check if the hangul is waiting for a coda
function Hangul:wait_for_coda()
    return self:has_on() and self:has_vowel() and not self:has_coda()
end

-- Check if the hangul is waiting for an extra coda to form a double coda
function Hangul:wait_for_second_coda()
    return self:has_on() and self:has_vowel() and self:has_coda() and DOUBLE_CODA_MAP_REVERSE[self.coda] ~= nil
end

-- Detach the coda from the hangul and return it
-- @return detached coda
function Hangul:detach_coda()
    if not self:has_coda() == nil then
        return nil
    end
    -- If it has a double coda, decompose it
    if self:has_double_coda() then
        local coda = self.coda
        self.coda = DOUBLE_CODA_MAP[coda][1]
        return DOUBLE_CODA_MAP[coda][2]
    else
        local coda = self.coda
        self.coda = SPACE_CODEPOINT
        return coda
    end
end

-- Compose the hangul into a single character
-- @return composed hangul
function Hangul:compose()
    if not self:has_vowel() or not self:has_on() then
        return self:to_jamo_string()
    end
    return utf8.char(HANGUL_BASE + ON_SET[self.on] * ONSET_BASE + VOWEL_SET[self.vowel] * VOWEL_BASE +
                         CODA_SET[self.coda])
end

-- Convert the hangul into a jamo string
-- @return jamo string
function Hangul:to_jamo_string()
    return (utf8.char(self.on) .. utf8.char(self.vowel) .. utf8.char(self.coda)):gsub(" ", "")
end

-- Converts a string of jamo into a string of hangul syllables.
-- The function aims to maximize the formation of valid hangul syllables 
-- by combining jamo in the correct order.
-- Examples:
-- - Input: "ㅇㅏㅁ" -> Output: "암"
-- - Input: "ㅇㅏㅁㅣ" -> Output: "아미" (not "암ㅣ")
-- @param jamo_str jamo string
-- @return hangul string
function Module.convert_jamo_to_hangul(jamo_str)
    local hangul_list = {}
    local cur_hangul = Hangul:new()
    local prev_hangul = Hangul:new()

    local function push()
        table.insert(hangul_list, cur_hangul)
        prev_hangul = cur_hangul
        cur_hangul = Hangul:new()
    end

    for jamo in Module.utf8_char_iter(jamo_str) do
        local code = utf8.codepoint(jamo)

        -- vowel in
        if VOWEL_SET[code] then
            -- vowel comes after on, if cur_hangul doesn't have an on,
            -- take the previous coda as on
            if cur_hangul:wait_for_vowel() then
                cur_hangul.vowel = code
            else
                push()
                cur_hangul.on = prev_hangul:detach_coda() or SPACE_CODEPOINT
                cur_hangul.vowel = code
            end
            goto continue
        end

        -- coda in
        if CODA_SET[code] then
            if cur_hangul:wait_for_coda() then
                cur_hangul.coda = code
            elseif cur_hangul:wait_for_second_coda() then
                local coda = cur_hangul:detach_coda()
                local double_coda = DOUBLE_CODA_MAP_REVERSE[coda][code] 
                if double_coda then 
                    cur_hangul.coda = double_coda
                else
                    cur_hangul.coda = coda
                    push()
                    if ON_SET[code] ~= nil then
                        cur_hangul.on = code
                    else 
                        cur_hangul.coda = code
                    end
                end
            elseif cur_hangul:wait_for_on() and ON_SET[code] ~= nil then
                cur_hangul.on = code
            else
                push()
                -- a coda jamo may also be an on jamo, but the
                -- priority of on is higher
                if ON_SET[code] ~= nil then
                    cur_hangul.on = code
                else 
                    cur_hangul.coda = code
                end
            end
            goto continue
        end

        -- on in 
        if ON_SET[code] then
            if cur_hangul:wait_for_on() then
                cur_hangul.on = code
            else
                push()
                cur_hangul.on = code
            end
        end
        ::continue::
    end

    push()
    
    local hangul_str = ""
    for _, hangul in ipairs(hangul_list) do
        hangul_str = hangul_str .. hangul:compose()
    end
    return hangul_str
end

------------------------------------------------------------
-- Test cases
------------------------------------------------------------
-- local test_cases = {
--     {input = "ㄴㅏㅁ", expected = "남"},
--     {input = "ㅎㅏㄴ", expected = "한"},
--     {input = "ㄱㅜㄱ", expected = "국"},
    
--     {input = "ㅇㅏㄴㅈ", expected = "앉"},
--     {input = "ㄷㅏㄹㄱ", expected = "닭"},
    
--     {input = "ㅇㅏㅁㅣ", expected = "아미"},
--     {input = "ㅎㅏㄴㅡㄹ", expected = "하늘"},
    
--     {input = "ㅇㅏㄴㅎㅏ", expected = "안하"},
    
--     {input = "", expected = ""}, 
    
--     {input = "ㅎㅏㄴㄱㅜㄱㅇㅓ", expected = "한국어"},
--     {input = "ㅇㅏㄴㄴㅕㅇ", expected = "안녕"},
    
--     {input = "ㅇㅏㄹㅎㅏ", expected = "알하"},

--     {input = "ㅅㅂ", expected = "ㅅㅂ"},
-- }

-- for i, test in ipairs(test_cases) do
--     local result = Module.convert_jamo_to_hangul(test.input)
--     if result ~= test.expected then
--         print(string.format("Test case %d failed:", i))
--         print(string.format("Input: %s", test.input))
--         print(string.format("Expected: %s", test.expected))
--         print(string.format("Got: %s", result))
--         print("---")
--     else
--         print(string.format("Test case %d passed: %s -> %s", i, test.input, result))
--     end
-- end

return Module
