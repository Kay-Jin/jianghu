# 🗡️ 江湖打工人项目文档索引

**项目状态：** 进行中（技术栈切换：Godot 2D 战棋 → **Unity 3D 沙盒**）
**当前 Sprint：** Sprint 1（4/16-4/30）
**关键里程碑：** 3D 沙盒漫游原型 4/30 → Demo v0.1 5/15 → EA 上线 7/31
**技术栈：** Unity 6 (LTS) + URP + C# + 3D 开放沙盒 + AI 辅助美术

> ⚠️ **技术栈变更通知（2026-04-19）**
> 原计划使用 **Godot 4.x + 2D 六边形战棋**。现变更为 **Unity 6 + 3D 开放世界沙盒**。
> 旧的 `godot-project/` 目录作为归档保留，后续工作在 `unity-project/` 下进行。
> 详见 [技术验证报告](./TECH_VERIFICATION_REPORT.md)。

---

## 🚀 快速导航

### 📐 管理文档（必读）

| 文档 | 说明 | 优先级 |
|------|------|--------|
| [项目管理方法论](./PROJECT_MANAGEMENT_METHOD.md) | ⭐ **所有计划的编写规范** | P0 |
| [项目看板](./PROJECT_BOARD.md) | 📊 总览所有 Sprint 进度 | P0 |
| [技术验证报告](./TECH_VERIFICATION_REPORT.md) | 🔬 Unity 3D 沙盒可行性验证（**方案已锁定**） | P0 |
| [Sprint 1 计划](./SPRINT_1_PLAN.md) | 🏃 当前 Sprint 详细任务（Unity 版） | P0 |
| [Unity 快速上手](./UNITY_QUICKSTART.md) | 🎮 Unity 项目安装 / 打开 / 运行指南 | P0 |

### 📅 每日站会

- [2026-04-16](./daily/2026-04-16.md) - 今日站会（待填写）
- [查看更多](./daily/)

### 📚 设计文档（与引擎无关，沿用）

| 文档 | 说明 |
|------|------|
| [项目计划书](./PROJECT_PLAN.md) | 完整项目规划 |
| [开发计划](./DEVELOPMENT_PLAN_v1.0.md) | 按天分解的开发计划 |
| [SOON 游戏设计规格书](./SOON_GAME_DESIGN_SPEC.md) | 🎯 **游戏机制与内容规格书**（引擎无关） |
| [世界观设定](./WORLD_SETTING.md) | 北宋末年武侠世界观 |
| [角色设定](./CHARACTERS.md) | 角色设计 |
| [武功系统](./MARTIAL_ARTS.md) | 武功设计（3D 化后需补充动作/打击感细则） |
| [游戏机制](./GAME_MECHANICS.md) | 游戏机制说明 |

### 📖 剧情与任务文档

| 文档 | 说明 |
|------|------|
| [📖 剧情总索引](./STORY_INDEX.md) | 所有章节剧情 + 24 个主线任务 |
| [🗺️ 支线任务总索引](./QUEST_INDEX.md) | 130+ 个支线任务分类索引 |
| [逐章剧本 + 城镇设计](./SCRIPT_AND_CITIES.md) | 序章~终章详细剧本 + 6 大城镇 |
| [支线任务详细设计](./SIDE_QUESTS.md) | 队友/NPC/门派/奇遇/道德/节日 |
| [时代背景支线](./SIDE_QUESTS_ERA.md) | 北宋末年社会现实（花石纲/金国南下） |
| [宋朝大城镇设计](./SONG_CITIES.md) | 真实历史城镇 + 江湖元素 |

---

## 📋 当前待办（Unity 切换后）

- [ ] S1-01: Unity 6 LTS 安装 + 打开 `unity-project/`
- [ ] S1-02: 跑通 `Assets/Scripts/Bootstrap/SceneBootstrap.cs` 的 3D 漫游原型
- [ ] S1-03: 第三人称控制 / 相机 / 基础打斗手感调试
- [ ] 填写每日站会（daily/2026-04-16.md）

---

## 🎯 关键日期

| 里程碑 | 日期 | 剩余天数 |
|--------|------|----------|
| Sprint 1 结束（3D 漫游原型） | 4/30 | 11 天 |
| Demo v0.1（一村一战一剧情） | 5/15 | 26 天 |
| Sprint 3 结束 | 5/31 | 42 天 |
| EA 上线 | 7/31 | 103 天 |

---

## 📞 团队

| 角色 | 成员 | 职责 |
|------|------|------|
| 主理人/制作人 | Kay | 决策、审核、验收 |
| AI 助理/执行 | 小聋瞎 | 执行、文档、项目管理 |

---

## 🔗 外部链接

- [Unity 官网](https://unity.com/)
- [Unity 6 文档](https://docs.unity3d.com/6000.0/Documentation/Manual/index.html)
- [URP 文档](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/index.html)

---

**最后更新：** 2026-04-19（切换 Unity 3D 技术栈）
**下次更新：** 每日站会结束时
