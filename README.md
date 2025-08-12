<h1 align="center">文镜 문경</h1>
<h3 align="center">rime韩语输入方案</h3>

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
| 汉字选单(`Control+m`开启/关闭)   |![image](https://github.com/user-attachments/assets/6c0ca7be-5d84-4881-a888-a59cdb87f767)|
| 释义滤镜(`Control+s`开启/关闭)   |![image](https://github.com/user-attachments/assets/9d81352a-0d10-4a28-b9fd-9c86ce823c39)|
| `C`引导自然码反查(需安装魔然方案) | ![image](https://github.com/user-attachments/assets/cf9bcd34-8278-43c6-a19a-2deb1d76870b)|
| `J`日语反查(需安装 kagiroi 方案)|![image](https://github.com/user-attachments/assets/5e7966c7-12af-4419-b6f5-9aec748bd187)|
| 古韩语字母| ![image](https://github.com/user-attachments/assets/88bdacdf-3c2e-4a91-b105-f007cc2c9b9b)

## 说明
#### 布局：
- 在`mungyeong.schema.yaml`中修改配置项`mungyeong/layout`, 可选值 `dubeolsik`(2-set)、 `romaja`(韩语罗马字)，也可以参照注释添加自定义布局

#### 反查:
- 配置文件预先设置好了反查配置，解除对应的注释即可使用
- 使用反查前请确保已经安装了该反查所依赖的方案
  - moran `℞ rimeinn/rime-moran`
    - 自然码+辅助码反查 [仓库地址](https://github.com/rimeinn/rime-moran/)
    - `C` 引导
  - kagiroi `℞ rimeinn/rime-kagiroi`
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

具体可参考 [mungyeong.hangul.dict.yaml](https://github.com/rimeinn/rime-mungyeong/blob/main/mungyeong.hangul.dict.yaml)
