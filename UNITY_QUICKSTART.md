# 🎮 Unity 快速上手 — 江湖打工人（3D 沙盒版）

**面向：** 项目主理人 Kay / 任何首次打开本仓库的人
**目标：** 10 分钟内在本地跑起来一个可操控的 3D 武侠漫游原型。

---

## 第 1 步：安装 Unity Hub 与 Unity 6 LTS（5-10 分钟）

1. 到 [https://unity.com/download](https://unity.com/download) 下载 **Unity Hub**（Windows/macOS 均可）。
2. 安装并打开 Unity Hub，登录 Unity 账号（个人版免费即可）。
3. 在 **Installs** 页面点 **Install Editor**，选择 **Unity 6 LTS**（`6000.0.x`）。
   - 勾选模块：**Microsoft Visual Studio Community 2022**（或已安装 VS Code + .NET SDK 也行）、**Windows Build Support (IL2CPP)**。
4. 等待安装完成（约 10-30 分钟，取决于网速）。

> 本项目针对 Unity 6 LTS 开发；用 `2022.3 LTS` 也能跑，但不保证所有脚本都兼容。

---

## 第 2 步：打开本项目（1 分钟）

1. 克隆本仓库：
   ```bash
   git clone git@github.com:Kay-Jin/jianghu.git
   ```
2. 打开 **Unity Hub → Projects → Add → Add project from disk**。
3. 选到 `jianghu/unity-project/` 文件夹（**注意是 `unity-project` 这一级**，不是仓库根目录）。
4. 在 Projects 列表中点击项目打开；**第一次打开 Unity 会自动下载依赖包并生成 Library/**，耗时 3-10 分钟。

---

## 第 3 步：跑起来 3D 漫游原型（2 分钟）

项目默认提供了一个 **自举脚本 `SceneBootstrap.cs`**，它会在运行时程序化地创建：

- 地面 Plane
- 主角胶囊体 + `PlayerController` + `PlayerStats`
- 第三人称摄像机 + `ThirdPersonCamera`
- 几个 NPC 胶囊体（不同颜色，可对话/挨打）
- 方向光 + 环境光

**首次运行步骤：**

1. 在 Unity 编辑器菜单栏 → **File → New Scene → Basic (Built-in)**，保存为 `Assets/Scenes/MainScene.unity`。
2. 在 **Hierarchy 面板** 右键 → **Create Empty**，命名为 `Bootstrap`。
3. 选中 `Bootstrap`，在 **Inspector → Add Component**，搜索并添加 `SceneBootstrap`。
4. 点顶部的 **▶️ Play**。

**预期效果：** 视角出现在主角背后，WASD 移动，鼠标右键按住拖动旋转视角，`空格` 跳，`左键` 普攻，`1/2/3` 使用武功。

---

## 第 4 步：理解项目结构

```text
unity-project/
├── Assets/
│   ├── Scenes/                    ← 场景文件（.unity）
│   ├── Scripts/
│   │   ├── Bootstrap/
│   │   │   └── SceneBootstrap.cs  ← ⭐ 一键搭出原型场景
│   │   ├── Player/
│   │   │   ├── PlayerController.cs
│   │   │   ├── PlayerStats.cs
│   │   │   └── ThirdPersonCamera.cs
│   │   ├── Combat/
│   │   │   ├── Damageable.cs
│   │   │   ├── CombatSystem.cs
│   │   │   ├── MartialArt.cs            ← ScriptableObject 武功数据
│   │   │   └── MartialArtDatabase.cs
│   │   ├── NPC/
│   │   │   ├── NPCController.cs
│   │   │   └── Dialogue.cs
│   │   ├── World/
│   │   │   ├── TimeOfDay.cs             ← 日夜循环
│   │   │   └── WorldManager.cs
│   │   ├── Save/
│   │   │   └── SaveSystem.cs
│   │   └── UI/
│   │       └── HUD.cs
│   ├── Prefabs/                   ← （后续放入角色/武器/特效 Prefab）
│   ├── Art/                       ← （后续放入模型/贴图/AI 生成素材）
│   └── Settings/                  ← URP Asset / Input Actions 等配置
├── Packages/
│   └── manifest.json              ← 依赖清单（URP / Cinemachine / Input System 等）
├── ProjectSettings/
│   └── ProjectVersion.txt         ← Unity 版本
└── .gitignore                     ← Unity 的忽略规则
```

---

## 第 5 步：当前能做的事

### ✅ 已跑通
- 第三人称漫游（WASD + 跳跃 + 鼠标看向）
- 简单普攻与一个示例武功（造成伤害 + 打击顿帧）
- NPC 对话触发（按 **E** 与 NPC 互动）
- 日夜循环（基于 `TimeOfDay` 驱动方向光）
- 存档/读档（JSON，存 `%USERPROFILE%/AppData/LocalLow/<Company>/<Product>/save.json`）

### ⏳ 需要后续迭代
- 真人模型与动画（Mixamo / Mecanim / AI 生成）
- 大地图与城镇加载（Addressables + SceneManagement）
- 技能数值与平衡（参考 `MARTIAL_ARTS.md`）
- 主线剧情与分支对话（SOON 规格 → Unity UI/Yarn Spinner/Ink）

---

## 第 6 步：学习路径（3-7 天）

| 天数 | 内容 | 资源 |
|------|------|------|
| Day 1 | Unity 编辑器界面 + GameObject/Component 模型 | [官方 Learn](https://learn.unity.com/) |
| Day 2 | C# 基础 + `MonoBehaviour` 生命周期 | 官方 Scripting 手册 |
| Day 3 | Rigidbody / CharacterController / Collider | Unity Manual Physics |
| Day 4 | URP + 光照与后处理 | URP 文档 |
| Day 5 | ScriptableObject + 数据驱动 | YouTube：UnityScriptableObject |
| Day 6 | Cinemachine + Timeline | 官方教程 |
| Day 7 | AI NavMesh + 简单敌人 AI | Unity AI 导航 |

---

## 第 7 步：常见问题（FAQ）

### Q1: 打开项目后一片红色错误？
Unity 还在 **导入包 / 编译脚本**。等 Console 的进度条走完，通常 3-10 分钟。

### Q2: 按 Play 没反应 / 角色不动？
- 确认 `Bootstrap` GameObject 上挂了 `SceneBootstrap`。
- 确认 **Project Settings → Player → Active Input Handling** 为 `Both` 或 `Input Manager (Old)`（本项目脚本使用旧输入 API，跑新输入系统也兼容）。
- 看 Console 是否有编译报错。

### Q3: 想换成自己的角色模型？
- 把 FBX/GLB 拖进 `Assets/Art/Characters/`。
- 做一个 Prefab：根节点挂 `CharacterController` + `PlayerController` + `PlayerStats`。
- 修改 `SceneBootstrap.cs` 中生成玩家的部分，改成 `Instantiate(yourPlayerPrefab, ...)`。

### Q4: 能在 macOS 上跑吗？
能。Unity Hub 和 Unity 6 LTS 都有 mac 版；脚本纯 C#，无平台相关代码。

### Q5: 和之前的 `godot-project/` 是什么关系？
`godot-project/` 是旧 2D 战棋方案的存档，不再维护；所有新开发在 `unity-project/`。世界观、剧情、武功等设计文档保持通用。

---

**跑通原型后，把看到的画面和 Console 日志告诉我，我们再逐步往上加真实美术、动画、剧情。**
