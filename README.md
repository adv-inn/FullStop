<div align="center">

<img src="assets/icon/logo.png" width="120" alt="FullStop Logo">

# FullStop.

**Spotify Focus Someone.**

> "我们有时候听歌需要 'Focus Someone'，感情也一样。"

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Spotify](https://img.shields.io/badge/Spotify-Web%20API-1DB954?logo=spotify)
![License](https://img.shields.io/badge/License-GPLv3-blue)
![codecov](https://codecov.io/gh/0chencc/fullstop/graph/badge.svg)

中文 | [English](README_en.md) | [日本語](README_ja.md)

</div>

---

使用 Spotify 的原因是其优秀的推送机制，但是有些时候我并不需要它那么机灵。我不需要算法告诉我什么是"可能喜欢的"，我只想专注于我"已经认定的"。

**FullStop（句号）** 由此诞生。名称源于邓紫棋的《句号》，本应用也是为了循环播放邓紫棋歌单时想到的需求。

我们希望用一个完美的句号，结束那些纷乱的干扰，只留下纯粹的音乐。

---

## 你的音乐，你做主

打开 FullStop，你会看到一个简洁的主界面。没有花哨的推荐卡片，没有"猜你喜欢"，只有你即将创建的专属电台。

<div align="center">
  <img src="img/quick-start.gif" width="300" height="595" alt="FullStop Main UI">
  <img src="img/index.png" width="300" height="595" alt="index">
</div>

### 创建一场专注

我们移除了所有不必要的繁琐步骤——包括"给歌单起名字"。

点击新建，直接开始。FullStop 会自动以你选择的艺术家作为标记（例如 "G.E.M. Session"）。如果这场音乐旅程让你印象深刻，你随时可以在播放时或结束后，赋予它一个更特别的名字。

现在，不需要消耗脑细胞，只需要把耳朵叫醒。

### 选择你的歌手

搜索并选择你想专注的艺术家。可以只选一位，让整个下午都沉浸在 Taylor Swift 的世界里；也可以选择几位风格相近的歌手，让 G.E.M.、Hebe、蔡依林在你的歌单里轮番登场。

最多五位，恰到好处。太少会单调，太多会失焦。

<div align="center">
  <img src="img/artist-selection.png" width="300" alt="Artist Selection">
</div>


### 四种聆听心境

这是 FullStop 最核心的选择。我们不谈算法参数，只谈听感与心境：

<div align="center">
  <img src="img/focus-modes.png" width="300" alt="Focus Modes">
</div>

* **Hits Only (仅限金曲)**
    * **"闭眼入坑，首首都是大合唱。"**
    * 每一首都是你听过无数遍、却依然想再听一遍的歌。副歌响起，你已经不由自主地跟着哼唱。适合需要熟悉感的时刻，比如工作时的背景音乐，或者开车时的放声高歌。

* **Balanced (经典平衡)**
    * **"熟悉中偶遇惊喜，久听不累。"**
    * 大部分是你熟悉的旋律，但偶尔会冒出一首"咦，这首歌原来这么好听"的专辑非主打。就像老朋友聚会时聊起的新话题，既亲切又新鲜。这是我们最推荐的默认模式。

* **Deep Dive (深度挖掘)**
    * **"寻找那首被遗忘的宝藏 B 面。"**
    * 穿越时光，遍历每一张录音室专辑。那些被热门单曲掩盖的 B-Side，那些只有真正的歌迷才知道的宝藏，都在这里等你。适合独处时光，适合想要重新认识一位歌手的夜晚。

* **Unfiltered (原汁原味)**
    * **"重返现场，感受每一次安可。"**
    * Live 版本、Remix、Acoustic，统统收入。也许你会发现，某首歌的现场版比录音室版本更打动人心。那个略带沙哑的嗓音，那阵此起彼伏的欢呼，都是录音室里没有的温度。

---

## 看不见的工艺 (The Invisible Craft)

为了实现上述那种"恰到好处"的听感，我们在后台构建了一套复杂的音频引擎。你不需要看见它们，但你会听到区别。

### 1. 全库遍历，而非"Top 50"
大多数工具只能获取歌手最热的前 50 首歌。但这对于周杰伦、邓紫棋这样的高产歌手来说远远不够。
FullStop 内置了**深度分页循环系统**，它会像一个不知疲倦的唱片店老板，翻遍该歌手的每一张录音室专辑，扫描 200+ 首曲目，确保没有遗珠。

### 2. 动态感知的平衡算法
什么是"冷门歌"？对于宇多田光和邓紫棋，"冷门"的定义截然不同。
我们抛弃了死板的热度阈值，采用**动态中位数算法**。无论歌手是全球巨星还是小众独立音乐人，FullStop 都能精准识别属于 *他/她* 的热门与冷门，动态调配出 7:3 的黄金比例。

### 3. 尊重艺术家的主权 (Artist Sovereignty)
这是我们最引以为傲的特性。有些歌曲，对歌手而言有着特殊的意义。

Taylor Swift 花了数年时间重新录制自己的专辑，只为拿回版权。G.E.M. 在离开前东家后，以《重生》为名重新诠释了经典。
FullStop 懂得这一点。当同一首歌存在多个版本时，我们的**加权评分系统**会介入：

* ✅ **优先保留**：Taylor's Version、G.E.M. 的《重生》版本、以及艺术家的重录版。
* ❌ **自动过滤**：那些喧闹的 Club Remix、令人分心的 Sped Up 抖音版，会被安静地请出你的专注时光。

你听到的，是歌手希望你听到的样子。

### 4. 真正的随机与区域感知
我们实现了 **True Shuffle** 算法，确保同一张专辑的歌曲不会扎堆出现。同时，引擎会自动识别你的 Spotify 账号区域（Market），保证生成的每一首歌在你的地区都能播放，不会出现"灰色不可点"的尴尬。

---

## 开始使用

### 准备工作
1.  **Spotify Premium** 订阅。
2.  一个 Spotify 开发者 App 的 `Client ID` 和 `Secret`。

### 安装 (iOS)
1.  在 [Releases](你的GitHubReleases链接) 下载最新的 `.ipa` 文件。
2.  使用 **AltStore**、**Sideloadly** 或 **TrollStore** 进行自签安装。

---

## 致谢

* [Spotify Web API](https://developer.spotify.com/documentation/web-api/)
* [Flutter](https://flutter.dev)

---

### End

我希望我可以看一朵花慢慢萌芽，你看着我的意气慢慢风发。

**但是 ——**

> "太多失望让我对你的信任慢慢崩塌"
>
> —— G.E.M. 《句号》