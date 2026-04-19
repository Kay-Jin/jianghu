# 🎯 你需要做的工作 — 美术 & 音频资源清单
# 江湖打工人 · 开发对接文档

**当前状态：** 代码全部完成。所有系统（战斗/存档/任务/好感度/商店/城镇/世界地图/角色创建）均已实现。
**只差：** 你提供下面的图片和音频文件，游戏即可完整运行。

---

## ✅ 代码已完成的系统

| 系统 | 文件 | 状态 |
|------|------|------|
| 六边形战棋战斗 | battle_controller.gd + battle_scene.gd | ✅ |
| 战斗UI（HP/MP/日志/技能）| battle_ui.gd | ✅ |
| 战斗视觉特效 | battle_effects.gd + martial_art_effects.gd | ✅ |
| 存档/读档（JSON）| save_system.gd | ✅ |
| 全局游戏状态 | global_state.gd | ✅ |
| 所有角色/武功/物品/地点/任务数据 | game_data.gd | ✅ |
| 角色创建界面 | character_creation.gd + .tscn | ✅ |
| 世界大地图（九宫格）| world_map.gd + .tscn | ✅ |
| 城镇场景（NPC/对话/商店/客栈）| town_base.gd + .tscn | ✅ |
| 主菜单（含续存档）| main_menu.gd + .tscn | ✅ |

---

## 📁 你需要提供的文件

### 一、角色立绘（PNG，建议 512×768 或更高）

放在：`godot-project/assets/characters/`

| 文件名 | 角色 | 优先级 | AI提示词位置 |
|--------|------|--------|-------------|
| `protagonist.png` | 主角林渊（常服） | ⭐⭐⭐ P0 | AI_ART_PROMPTS_FULL.md |
| `protagonist_scholar.png` | 主角（书生装） | ⭐⭐ | 同上 |
| `ye_hanjiang.png` | 沈刃 | ⭐⭐⭐ P0 | 同上 |
| `jiang_mingyi.png` | 顾昱明 | ⭐⭐ | 同上 |
| `yue_peng.png` | 燕铮 | ⭐⭐ | 同上 |
| `qi_lianfeng.png` | 宁奔 | ⭐ | 同上 |
| `xuan_weizi.png` | 清虚道人 | ⭐ | 同上 |
| `zhuo_buqun.png` | 罗衡 | ⭐ | 同上 |
| `cheng_ye.png` | 方烽 | ⭐ | 同上 |
| `lu_feilong.png` | 穆长风 | ⭐ | 同上 |
| `helan_duo.png` | 巴图尔 | ⭐ | 同上 |
| `su_wan.png` | 沈清鸢 | ⭐⭐⭐ P0 | 同上 |
| `yao_linger.png` | 白芷 | ⭐⭐ | 同上 |
| `pei_qingluan.png` | 卫追云 | ⭐⭐ | 同上 |
| `tang_yuruo.png` | 霍毓桐 | ⭐ | 同上 |
| `liu_qingyan.png` | 云墨烟 | ⭐⭐ | 同上 |
| `nan_xingyue.png` | 珂星月 | ⭐ | 同上 |
| `mu_rong_xue.png` | 凌离雪 | ⭐ | 同上 |
| `zhao_miner.png` | 钟灵 | ⭐ | 同上 |
| `ling_yan_hua.png` | 程烟笔 | ⭐ | 同上 |
| `qiu_shisan_niang.png` | 姜十三 | ⭐ | 同上 |
| `xuan_ming_zi.png` | 冥渊主（BOSS） | ⭐⭐ | 同上 |
| `ye_wu_hen.png` | 司空无迹 | ⭐⭐ | 同上 |
| `po_tian.png` | 破天 | ⭐⭐ | 同上 |
| `jiang_tianjian.png` | 沈天剑（义父） | ⭐⭐ | 同上 |
| `jiang_tian_ying.png` | 沈天影（反派） | ⭐⭐ | 同上 |
| `cai_jing.png` | 蔡京 | ⭐ | 同上 |
| `hua_wujiu.png` | 聂无殇 | ⭐ | 同上 |

### 二、场景背景图（PNG，1920×1080 推荐）

放在：`godot-project/assets/backgrounds/`

| 文件名 | 场景 | 优先级 | AI提示词位置 |
|--------|------|--------|-------------|
| `northwest_desert.png` | 西北荒漠 | ⭐⭐ | SCENE_ART_PROMPTS.md SCENE-03 |
| `hebei_yanshan.png` | 河北燕山 | ⭐⭐ | SCENE-05 |
| `liaodong.png` | 辽东 | ⭐ | SCENE-07 |
| `sichuan_qingcheng.png` | 蜀中青城 | ⭐⭐⭐ P0 | SCENE-08 |
| `capital_city.png` | 临渊城 | ⭐⭐⭐ P0 | SCENE-13 |
| `east_sea.png` | 东海蓬莱 | ⭐⭐ | SCENE-10 |
| `southern_mountains.png` | 岭南大山 | ⭐⭐ | SCENE-12 |
| `jiangnan.png` | 江南姑苏 | ⭐⭐⭐ P0 | SCENE-09 |
| `jiangnan_south.png` | 临安 | ⭐ | SCENE-21 |
| `town_duanjian_manor.png` | 断剑山庄城镇背景 | ⭐⭐⭐ P0 | SCENE-22 |
| `town_linyan_city.png` | 临渊城街景 | ⭐⭐⭐ P0 | SCENE-14 |
| `town_gusu_city.png` | 姑苏城水乡 | ⭐⭐⭐ P0 | SCENE-16 |
| `town_yanshan_city.png` | 燕山城军镇 | ⭐⭐ | SCENE-18 |
| `town_yao_wang_valley.png` | 药王谷 | ⭐⭐ | SCENE-24 |
| `town_penglai_city.png` | 蓬莱港口 | ⭐ | SCENE-20 |
| `town_longmen_inn.png` | 龙门客栈 | ⭐ | SCENE-04 |

### 三、UI 图片

放在：`godot-project/assets/ui/`

| 文件名 | 用途 | 优先级 |
|--------|------|--------|
| `world_map_bg.png` | 大地图背景（水墨地图）| ⭐⭐⭐ P0 |
| `creation_bg.png` | 角色创建背景 | ⭐⭐ |
| `main_menu_bg.png` | 主菜单背景 | ⭐⭐⭐ P0 |

### 四、3D 模型（GLB）

放在：`godot-project/assets/models/`

你已有的模型（在 assets/characters/ 中）：
- `主角2.glb` ← 已有！重命名为 `protagonist.glb`
- `4b45eb3aeae61716119d6a9e22a452f3.glb` ← 确认是哪个角色，重命名

还需制作的模型（用 Meshy AI 生成）：

| 模型文件 | 角色 |
|----------|------|
| `ye_hanjiang.glb` | 沈刃 |
| `su_wan.glb` | 沈清鸢 |
| `yue_peng.glb` | 燕铮 |
| `yao_linger.glb` | 白芷 |
| `pei_qingluan.glb` | 卫追云 |
| `enemy_bandit.glb` | 通用山贼（可复用） |
| `enemy_soldier.glb` | 通用金国兵（可复用） |

### 五、音频

放在：`godot-project/assets/audio/`

| 文件名 | 用途 | 格式 |
|--------|------|------|
| `bgm/main_menu.ogg` | 主菜单BGM | OGG |
| `bgm/bgm_mountain.ogg` | 蜀中/断剑山庄 | OGG |
| `bgm/bgm_capital.ogg` | 临渊城 | OGG |
| `bgm/bgm_jiangnan.ogg` | 江南 | OGG |
| `bgm/bgm_war.ogg` | 燕山/战争 | OGG |
| `bgm/bgm_battle.ogg` | 通用战斗BGM | OGG |
| `bgm/bgm_desert.ogg` | 西北荒漠 | OGG |
| `bgm/bgm_sea.ogg` | 东海 | OGG |
| `sfx/sword_hit.ogg` | 剑击音效 | OGG |
| `sfx/move_step.ogg` | 移动步伐 | OGG |
| `sfx/skill_activate.ogg` | 技能发动 | OGG |
| `sfx/victory.ogg` | 战斗胜利 | OGG |
| `sfx/defeat.ogg` | 战斗失败 | OGG |
| `sfx/levelup.ogg` | 升级提示 | OGG |
| `sfx/click_ui.ogg` | UI点击 | OGG |

---

## 🎮 当前可立即运行的功能

打开 Godot 4.6，运行项目，现在已经可以：

1. **主菜单** → 新游戏 / 继续游戏
2. **角色创建** → 分配15点属性 + 选择出身 → 开始游戏
3. **世界大地图** → 9大区域导航，点击城镇进入
4. **城镇场景** → NPC对话（含队伍邀请）/ 商店购买 / 客栈存档
5. **六边形战棋战斗** → 完整战斗循环（移动/攻击/武功/AI敌人）
6. **存档/读档** → JSON存储到 user://saves/

缺少美术时，游戏用彩色方块代替角色，灰色背景代替场景图——**逻辑完全可用**。

---

## ⚡ 下一步建议顺序

1. **先做P0立绘** → 主角 + 沈刃 + 沈清鸢（用AI_ART_PROMPTS_FULL.md里的提示词）
2. **先做P0背景** → 断剑山庄 + 临渊城 + 姑苏城 + 大地图（用SCENE_ART_PROMPTS.md）
3. **3D模型** → 把已有的 主角2.glb 重命名 + 用Meshy AI补充通用士兵模型
4. **BGM** → 用AI音乐工具（Suno/Udio）生成古风BGM，导出OGG格式
5. 提交给我 → 我将立绘/背景接入代码，完成全游戏视觉集成

---

## 📁 文件命名规则

- 立绘：全部小写+下划线，如 `su_wan.png`
- 背景：`town_` 前缀用于城镇，裸名用于区域
- 模型：与 game_data.gd 中的角色ID同名
- 音频：`.ogg` 格式（Godot原生支持最好）
