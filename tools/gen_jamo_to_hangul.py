#!/usr/bin/env python3

def gen_jamo_to_hangul():
    cho = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
    jung = ['ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ']
    jong = [''] + ['ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']

    base = 0xAC00
    cho_base = 588
    jung_base = 28

    with open('opencc/mungyeong_jamo2hangul.txt', 'w', encoding='utf-8') as f:
        for c in cho:
            for j in jung:
                for g in jong:
                    cho_index = cho.index(c)
                    jung_index = jung.index(j)
                    jong_index = jong.index(g)
                    
                    offset = (cho_index * cho_base) + (jung_index * jung_base) + jong_index
                    hangul_char = chr(base + offset)
                    
                    jamo_str = c + j + g if g else c + j
                    
                    f.write(f"{jamo_str}\t{hangul_char}\n")

if __name__ == "__main__":
    gen_jamo_to_hangul()