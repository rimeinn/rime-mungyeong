#!/usr/bin/env python3

def process_hanja_file():
    with open('tools/hanja.txt', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    dict_entries = []
    meaning_entries = {}
    
    for line in lines:
        parts = line.strip().split(':')
        
        if len(parts) < 2:
            continue
            
        hangul = parts[0]  
        hanja = parts[1]   
        
        if hanja:
            dict_entries.append(f"{hanja}\t{hangul}")
        
        if len(parts) > 2 and parts[2]:
            if len(hanja) == 1:
                meanings = parts[2].split(',')
                # 用字典来按发音分组
                pronoun_meanings = {}
                
                for meaning in meanings:
                    words = meaning.split(' ')
                    pronouciation = words[-1]
                    meaning_text = '\u2002'.join(words[0:-1])
                    
                    if pronouciation in pronoun_meanings:
                        pronoun_meanings[pronouciation].append(meaning_text)
                    else:
                        pronoun_meanings[pronouciation] = [meaning_text]
                
                # 格式化输出
                formatted_meanings = ""
                for pronoun, meaning_list in pronoun_meanings.items():
                    if pronoun == hangul:
                        formatted_meanings += f"〔{pronoun}〕{','.join(meaning_list)},"
                    else:
                        formatted_meanings += f"{pronoun}\u2002{','.join(meaning_list)},"
                        
                formatted_meanings = formatted_meanings.rstrip(',')
            else:
                formatted_meanings = parts[2]
                
            if hanja in meaning_entries:
                meaning_entries[hanja] += f",{formatted_meanings}"
            else:
                meaning_entries[hanja] = formatted_meanings
    
    with open('mungyeong.hanja.dict.yaml', 'w', encoding='utf-8') as f:
        f.write("""
# Rime dictionary
# encoding: utf-8
# converted from libhangul
#    
# licensed as follows:
#
# Copyright (c) 2005,2006 Choe Hwanjin
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the author nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

---
name: mungyeong.hanja
version: "20241216"
sort: by_weight
use_preset_vocabulary: false
columns:
  - text
  - code
  - weight
...

""")
        f.write('\n'.join(dict_entries))
        
    with open('opencc/mungyeong_hanja_meaning.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join([f"{k}\t{v}" for k, v in meaning_entries.items()]))

if __name__ == '__main__':
    process_hanja_file()