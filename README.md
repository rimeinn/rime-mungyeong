<h1 align="center">文镜 문경</h1>
<h4 align="center">面向初学者的韩语输入方案</h6>

## 特点
在与市面常用的韩语输入法输入体验一致的同时，更具备
- 自动弹出汉字词候选框并附带解释，使词汇掌握更容易
- 支持拼音、日语罗马字反查汉字词
- 支持2-set/工振厅罗马字两套韩语键盘布局，而且自定义布局也很容易

## 示例
| 功能  | 截图|
|--------|--------|
| 释义滤镜   |![image](https://github.com/user-attachments/assets/56923752-37dc-4275-92be-a264448111ff)|
| 拼音反查(内置魔然自然码,也可自行替换成其他码表)  | ![image](https://github.com/user-attachments/assets/3b81bcf4-abf7-45fc-8546-92cc77262a9b)|
| 日语罗马字反查|![image](https://github.com/user-attachments/assets/6d0e27e8-2917-466b-a715-47721558e664)|


## 说明
安装：
- `℞ rimeinn/rime-mungyeong`

布局：
- 在`mungyeong.schema.yaml`中修改配置项`munmungyeong/layout`, 可选值 `dubeolsik`(2-set)、 `romaja`(韩语罗马字)，也可以参照注释添加自定义布局

反查:
- 可在`mungyeong_reverse.extended.dict.yaml`自行增加、删除反查词典

作为辅助输出：
- 每个人的配置情况不同，以下仅供参考
```yaml
  # 在xxx.custom.yaml中，xxx为你的主方案
  schema/dependencies/+:
    - mungyeong
    - mungyeong_dubeolsik
  engine/segmentors/@before 5: affix_segmentor@mungyeong
  engine/translators/+:
    - lua_translator@*mungyeong/mungyeong_translator@as_addon #当带as_addon时，会将hangul作为第一个候选输出
  mungyeong:
    prefix: om
    tips: 〔文镜〕
    tag: mungyeong
    layout: dubeolsik
  recognizer/patterns/mungyeong: '(^om[a-z\-]*$)'
```
