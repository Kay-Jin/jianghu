# 🔬 技术验证报告 — Unity 6 + 3D 武侠沙盒

**日期：** 2026-04-19（v2.0，Unity 3D 切换后）
**历史版本：** v1.0（2026-04-16，Godot 4.x + 2D 六边形战棋，已废弃）
**结论：** ✅ Unity 6 LTS 完全可行，方案锁定。

---

## 0. 技术栈变更说明

| 维度 | 旧方案 (v1.0) | 新方案 (v2.0 当前) |
|------|--------------|-------------------|
| 引擎 | Godot 4.3 | **Unity 6 LTS (6000.0.x)** |
| 渲染 | 2D (Viewport) | **3D + URP** |
| 玩法核心 | 2D 六边形战棋回合制 | **3D 开放世界沙盒 + 实时战斗** |
| 语言 | GDScript | **C#** |
| 参考 | 古龙风云录 | **逸剑风云决 / 江湖十一 / 太吾绘卷（部分）** |

**变更原因（Kay 决策）：**
1. 目标体验从 **战棋叙事** 调整为 **开放世界沙盒（自由探索 + 武林游历）**。
2. 3D 相较 2D 战棋在 **沉浸感、动作手感、现代玩家接受度** 上更强。
3. Unity 在 **3D + 开放世界 + 资产生态（Asset Store / Mixamo / Addressables）** 更成熟。
4. AI 美术素材（3D 模型 / 动画 / 贴图）近两年成熟度显著高于 2D 立绘叠加战棋方案。

---

## 一、最终决策

| 项目 | 决定 | 原因 |
|------|------|------|
| **引擎** | Unity 6 LTS (6000.0.x) | 3D 开放世界首选；C# 生态成熟；跨平台 |
| **渲染管线** | URP (Universal Render Pipeline) | 性能/画面/可移植性平衡；支持 PBR 与后处理 |
| **玩法类型** | 3D 开放世界武侠沙盒（单机） | 自由度 + 武林模拟 + 主线任务 |
| **战斗** | 实时动作（锁定 + 技能键位）+ 轻 RPG | 参考逸剑风云决；非纯 ACT 也非纯回合 |
| **视角** | 第三人称越肩 | Cinemachine 驱动 |
| **脚本语言** | C# | Unity 官方；与编辑器深度整合 |
| **数据** | ScriptableObject + JSON | 武功/物品/NPC 配置用 SO；存档用 JSON |
| **AI 工作流** | Mixamo 动画 + Meshy 3D + SD/Nano-Banana 贴图 | 低成本单人可控 |

---

## 二、Unity 6 核心能力验证

### 2.1 第三人称角色控制

- `CharacterController` + 自写 `PlayerController.cs`：零依赖、手感可控。
- **Cinemachine 3.x** `CinemachineCamera` + `3rd Person Follow`：越肩视角、碰撞避让、平滑跟随开箱即用。
- 本仓库 `unity-project/Assets/Scripts/Player/ThirdPersonCamera.cs` 提供了不依赖 Cinemachine 的最小实现，便于初次跑通。

### 2.2 场景与世界

- **SceneManagement** 分场景加载大地图。
- **Addressables** 按需加载城镇 / 门派 / 支线场景，避免单场景过大。
- **NavMesh** 内置 AI 寻路；`NavMeshAgent` 驱动 NPC 漫游。
- **TimeOfDay 脚本** 驱动方向光旋转 + 天空盒 LUT 切换（本仓库已提供最小实现）。

### 2.3 战斗系统

| 特性 | Unity 实现方式 | 工作量 |
|------|---------------|--------|
| 角色移动/跳跃 | `CharacterController` 或 `Rigidbody` | ⭐ 原生 |
| 锁定敌人 | 球形检测 `Physics.OverlapSphere` + UI 指示 | ⭐⭐ |
| 动作事件 | `AnimationEvent` 触发伤害判定 | ⭐⭐⭐ |
| 命中判定 | `BoxCast` / `OverlapBox` + `Damageable` | ⭐⭐ |
| 武功（技能） | `ScriptableObject` 数据 + 组合技编排 | ⭐⭐⭐ |
| 打击感（顿帧/震屏） | `Time.timeScale` 顿帧 + Cinemachine Impulse | ⭐⭐ |
| 粒子特效 | VFX Graph / Shuriken | ⭐⭐⭐ |
| 敌人 AI | NavMesh + 行为树 / FSM | ⭐⭐⭐ |

### 2.4 剧情与对话

- **Yarn Spinner for Unity** 或 **Ink (Inkle)**：都免费开源，支持分支与标签触发。
- UI 用 **UI Toolkit (UITK)** 或 **uGUI**；初期以 uGUI 快速推进。

### 2.5 存档/读档

- C# `System.Text.Json` 或 Newtonsoft.Json 将运行时数据序列化到 `Application.persistentDataPath/save.json`。
- 本仓库 `unity-project/Assets/Scripts/Save/SaveSystem.cs` 提供最小可用实现。

### 2.6 数值与配置

- **ScriptableObject** 存 `MartialArt`、`Item`、`NpcProfile` 等静态数据，可直接在 Inspector 编辑 + 版本控制友好。

---

## 三、风险与应对

| 风险 | 说明 | 应对 |
|------|------|------|
| 3D 美术工作量比 2D 大 | 开放世界需要模型/动画/贴图大量资产 | Mixamo（免费动画）+ Meshy/Kaedim（AI 3D）+ 购买 Asset Store 基础包 |
| 开放世界性能 | 同屏内容多时易掉帧 | URP + LOD + Occlusion + Addressables 分块加载 |
| 单人开发工时 | 3D RPG 一人开发周期长 | MVP 聚焦「1 村 1 城 1 章 + 1 套完整战斗」 |
| Unity 版权政策 | 近年定价反复 | 选择 LTS；Personal 授权下 < 20 万美元营收免授权费；EA 阶段无虞 |
| 学习曲线（C# + 3D） | 相比 GDScript 稍陡 | Unity Learn + 本仓库 `UNITY_QUICKSTART.md` 标准化入门 |

---

## 四、参考（同类型成品）

| 游戏 | 可借鉴点 |
|------|---------|
| 逸剑风云决 | 3D 武侠 + 轻动作战斗 + 江湖游历节奏 |
| 江湖十一 | 沙盒养成 + 自由度 + 人物好感 |
| 太吾绘卷 | 武林模拟 + 传记 + 功法演化（深度参考玩法，不抄美术） |
| 荒野之息 | 开放世界探索节奏（结构参考） |

---

## 五、Unity vs Godot vs Unreal（最终版）

| 维度 | Unity 6 | Godot 4.x | Unreal 5 |
|------|--------|-----------|---------|
| 3D 能力 | ✅ 强 | ⚠️ 可用但生态弱 | ✅ 顶级 |
| 开放世界 | ✅ 成熟（Addressables/LOD/NavMesh） | ⚠️ 偏弱 | ✅ 强（但体量更大） |
| 单人开发友好度 | ✅ 中等 | ✅ 最易 | ❌ 陡峭 |
| C# 生态 | ✅ 最好 | ⚠️ GDScript 优先 | ❌ 以 C++/蓝图为主 |
| AI 素材生态 | ✅ Asset Store + Mixamo | ⚠️ 较少 | ✅ Marketplace |
| 出 Steam/EA | ✅ 直接 | ✅ 直接 | ✅ 直接 |
| 授权费用 | ✅ Personal 免费（≤20 万美元营收） | ✅ MIT 完全免费 | ⚠️ 分成 5%（100 万美元以上） |
| 适合本项目 | ✅ 最佳 | ⚠️ 切换前的方案 | ❌ 过重 |

---

## 六、后续行动（v2.0 路线图）

1. ✅ **方案锁定** — Unity 6 LTS + URP + 3D 沙盒。
2. ⏳ **Unity 6 LTS 安装** — 通过 Unity Hub 安装，见 `UNITY_QUICKSTART.md`。
3. ⏳ **原型跑通** — 打开 `unity-project/`，运行 `SceneBootstrap.cs` 自动搭场景。
4. ⏳ **美术素材首批** — 主角模型 + 2 套动画 + 1 套武功特效。
5. ⏳ **小型村落 / 一条支线** — 作为 Demo v0.1 的内容核心。
6. ⏳ **更新 Sprint 计划** — 以 Unity 维度重新排期（已更新 `SPRINT_1_PLAN.md`）。

---

**这份报告是 v2.0 最终确认版。除非 Unity 出现无法克服的技术障碍，否则不再更换引擎。**
