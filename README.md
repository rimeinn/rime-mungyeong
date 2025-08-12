<h1 align="center">文镜 문경</h1>

## 安装
- `℞ rimeinn/rime-mungyeong`
-  [在线试用(2-set布局)](https://my-rime.vercel.app/?plum=rimeinn/rime-mungyeong:mungyeong)

## 特点
在与市面常用的韩语输入法输入体验一致的同时，更具备
- 常驻汉字(词)候选框
- 支持自然码、日语反查汉字(词)
- 同时支持2-set/罗马字两套韩语键盘布局

## 示例
| 功能  | 截图|
|--------|--------|
| 汉字选单(Control+m开启)   |![image]()|
| 释义滤镜(Control+s开启)   |![image]()|
| 自然码反查(需安装魔然方案) | ![image]()|
| 日语反查(需安装kagiroi方案)|![image]()|
| 古韩语谚文| ![image](https://github.com/user-attachments/assets/88bdacdf-3c2e-4a91-b105-f007cc2c9b9b)

## 说明
#### 布局：
- 在`mungyeong.schema.yaml`中修改配置项`mungyeong/layout`, 可选值 `dubeolsik`(2-set)、 `romaja`(韩语罗马字)，也可以参照注释添加自定义布局

#### 反查:
- 配置文件预先设置好了反查配置，解除对应的注释即可使用
- 使用反查前请确保已经安装了该反查所依赖的方案
  - moran (℞ rimeinn/rime-moran) 
    - 自然码+辅助码反查 [仓库地址](https://github.com/rimeinn/rime-moran/)
    - `C` 引导
  - kagiroi (℞ rimeinn/rime-kagiroi)
    - 日语反查 [仓库地址](https://github.com/rimeinn/rime-kagiroi/)
    - `J` 引导
- 也可以使用其他方案进行反查，参照配置添加即可

#### 古韩语字母
> 默认关闭 在`mungyeong_reverse.extended.dict.yaml`中取消掉`- mungyeong.hangul`的注释即可启用
- 与汉字候选一样，需要使用数字候选输入，不影响正常韩语输入
- 古韩语字母根据形近或音近原则归并到现代韩语字母，例如
  - ᄼ/ᄾ -> ㅅ
  - ᅀ/ᅌ -> ㅇ
  - ᅙ -> ㅎ
  - ㆍ -> ㅏ
- 复合母音/子音同样依据上面的归并进行编码，例如
  - ᅏ/ᅑ -> ㅉ
  - ᄢ -> ㅂㅅㄱ
  - ᆢ -> ㅏㅏ

具体可参考 [mungyeong.hangul.dict.yaml]()