# ⚔️ 江湖打工人 — 武功系统详细设计

**版本：** v1.0  
**创建日期：** 2026-04-17  
**关联文档：** MARTIAL_ARTS.md / GAME_MECHANICS.md / SOON_GAME_DESIGN_SPEC.md

---

## 一、武功系统核心架构

### 1.1 武功分类体系

```
武功分类：
├── 内功（被动加成）
│   ├── 基础内功（提升内力上限）
│   ├── 高级内功（附加特殊效果）
│   └── 绝世内功（质变级效果）
├── 外功（主动招式）
│   ├── 剑法（单体/群体物理攻击）
│   ├── 刀法（高伤害、慢速度）
│   ├── 拳掌（近距离、连招）
│   ├── 棍法（范围控制）
│   └── 暗器（远程、特殊效果）
├── 轻功（移动/闪避）
│   ├── 身法类（提升移动范围）
│   ├── 闪避类（提升回避率）
│   └── 突进类（瞬移/冲锋）
├── 辅助技能
│   ├── 治疗（回复 HP）
│   ├── 增益（临时提升属性）
│   └── 减益（降低敌人属性）
└── 毒术（特殊攻击）
    ├── 即时毒（战斗中毒伤害）
    ├── 延时毒（数回合后发作）
    └── 群体毒（影响多个目标）
```

### 1.2 武功数据结构

```gdscript
# Godot 4.3 — 武功数据结构
class_name MartialArt

enum Category {
    INTERNAL,    # 内功
    SWORD,       # 剑法
    BLADE,       # 刀法
    FIST,        # 拳掌
    STAFF,       # 棍法
    HIDDEN,      # 暗器
    QINGGONG,    # 轻功
    SUPPORT,     # 辅助
    POISON       # 毒术
}

enum TargetType {
    SINGLE,      # 单体
    LINE,        # 直线范围
    AOE,         # 圆形范围
    SELF,        # 自身
    ALLY,        # 友方
    ALL_ENEMY    # 全部敌人
}

enum EffectType {
    DAMAGE,      # 伤害
    HEAL,        # 治疗
    BUFF,        # 增益
    DEBUFF,      # 减益
    DOT,         # 持续伤害（中毒）
    STUN,        # 眩晕
    SILENCE      # 沉默（无法使用武功）
}

# 武功数据
var name: String                    # 武功名称
var category: Category              # 分类
var level: int                      # 武功等级（1-9）
var mp_cost: int                    # 内力消耗
var cooldown: int                   # 冷却回合
var range: int                      # 攻击范围（格子数）
var target_type: TargetType         # 目标类型
var base_damage: float              # 基础伤害倍率
var effect_type: EffectType         # 效果类型
var effect_value: float             # 效果值
var effect_duration: int            # 效果持续回合
var description: String             # 武功描述
var learn_source: String            # 学习来源（门派/秘籍/NPC）
var learn_requirement: Dictionary   # 学习条件

func calculate_damage(attacker_stats: Dictionary, defender_stats: Dictionary) -> int:
    """计算实际伤害"""
    var base = attacker_stats["attack"] * base_damage
    var defense = defender_stats["defense"]
    var actual_damage = max(1, int(base - defense))
    return actual_damage
```

---

## 二、各门派武功详细设计

### 2.1 断剑山庄

**武学特点：** 刚猛路线，高攻击、低防御

| 武功 | 等级 | 消耗 | 效果 | 来源 |
|------|------|------|------|------|
| 断剑剑法 | 基础 | 5 | 单体伤害 ×1.5 | 入门赠送 |
| 断水式 | 1 | 10 | 单体伤害 ×2.0 + 破甲 20% | 领悟 |
| 断风式 | 2 | 15 | 单体伤害 ×2.5 + 连击（可能再攻一次） | 修炼 |
| 断月式 | 4 | 20 | 直线范围伤害 ×1.8 | 修炼 |
| 断魂式 | 6 | 30 | 单体伤害 ×3.5 + 眩晕 1 回合 | 修炼 |
| 断剑十三式 | 9 | 50 | 单体伤害 ×5.0 + 破甲 50% | 义父传授 |

**内功：**
| 武功 | 效果 |
|------|------|
| 断剑心法 | 内力上限 +30%，攻击力 +10% |

**轻功：**
| 武功 | 效果 |
|------|------|
| 断影步 | 移动范围 +1，闪避率 +10% |

---

### 2.2 听雨楼

**武学特点：** 轻灵路线，高闪避、高连击

| 武功 | 等级 | 消耗 | 效果 | 来源 |
|------|------|------|------|------|
| 听雨剑法 | 基础 | 5 | 单体伤害 ×1.3 + 闪避 +20% | 拜师获得 |
| 细雨绵绵 | 1 | 12 | 单体伤害 ×1.8，连击概率 30% | 修炼 |
| 骤雨狂风 | 3 | 20 | 直线范围伤害 ×1.5 + 沉默 1 回合 | 修炼 |
| 听雨楼秘传·雨夜听声 | 6 | 35 | 单体伤害 ×3.0 + 连击必定触发 | 苏清商专属任务 |
| 听雨双剑（连携技） | 7 | 40 | 双段伤害 ×2.0 + 破甲 30% | 苏清商好感 100 |

**内功：**
| 武功 | 效果 |
|------|------|
| 听雨心经 | 闪避率 +15%，内力恢复速度 +20% |

---

### 2.3 青囊谷

**武学特点：** 医毒双修，治疗 + 毒术

| 武功 | 等级 | 消耗 | 效果 | 来源 |
|------|------|------|------|------|
| 青囊剑法 | 基础 | 5 | 单体伤害 ×1.4 | 拜师获得 |
| 回春掌 | 1 | 15 | 单体治疗 30% HP | 修炼 |
| 七绝针 | 2 | 12 | 单体伤害 ×1.5 + 中毒（3 回合，每回合 5%） | 修炼 |
| 万毒心经 | 4 | 25 | 圆形范围伤害 ×1.2 + 群体中毒 | 修炼 |
| 青囊秘传·起死回生 | 7 | 40 | 单体复活 + 恢复 50% HP（战斗限一次） | 药辛夷专属任务 |
| 毒术·幽冥散 | 5 | 20 | 单体伤害 ×2.0 + 中毒（5 回合） | 林晚照合作 |

**内功：**
| 武功 | 效果 |
|------|------|
| 青囊心法 | 治疗效果 +20%，中毒抗性 +30% |

---

### 2.4 铁血盟

**武学特点：** 力量路线，超高伤害、低速度

| 武功 | 等级 | 消耗 | 效果 | 来源 |
|------|------|------|------|------|
| 铁血刀法 | 基础 | 5 | 单体伤害 ×1.6 | 拜师获得 |
| 开山劈 | 2 | 15 | 单体伤害 ×2.5 + 破甲 20% | 修炼 |
| 铁山靠 | 3 | 12 | 单体伤害 ×1.8 + 击退 2 格 | 修炼 |
| 铁血盟秘传·万夫莫敌 | 7 | 45 | 圆形范围伤害 ×2.0 + 自身 HP-20% | 铁山专属任务 |
| 破军斩 | 8 | 50 | 单体伤害 ×4.0 + 眩晕 2 回合 | 修炼 |

**内功：**
| 武功 | 效果 |
|------|------|
| 铁血心诀 | HP 上限 +40%，防御 +15% |

---

### 2.5 丐帮

**武学特点：** 控制路线，减速 + 群体攻击

| 武功 | 等级 | 消耗 | 效果 | 来源 |
|------|------|------|------|------|
| 打狗棒法 | 基础 | 5 | 单体伤害 ×1.3 + 减速 1 回合 | 拜师获得 |
| 亢龙有悔 | 4 | 25 | 直线范围伤害 ×2.0 + 击退 1 格 | 修炼 |
| 降龙十八掌 | 7 | 40 | 单体伤害 ×3.5 + 破甲 30% | 帮主传授 |
| 天下无狗 | 8 | 50 | 圆形范围伤害 ×2.5 + 群体减速 | 修炼 |

**内功：**
| 武功 | 效果 |
|------|------|
| 丐帮心法 | 速度 +20%，控制效果持续时间 +1 回合 |

---

### 2.6 少林

**武学特点：** 均衡路线，防御 + 治疗

| 武功 | 等级 | 消耗 | 效果 | 来源 |
|------|------|------|------|------|
| 罗汉拳 | 基础 | 5 | 单体伤害 ×1.4 | 拜师获得 |
| 易筋经 | 5 | 30 | 自身增益：防御 +50%，HP 恢复 20%，持续 3 回合 | 修炼 |
| 金钟罩 | 3 | 20 | 自身增益：免疫伤害 1 回合 | 修炼 |
| 大力金刚掌 | 6 | 35 | 单体伤害 ×3.0 + 眩晕 1 回合 | 方丈传授 |
| 如来神掌 | 9 | 60 | 圆形范围伤害 ×3.0 | 隐藏条件 |

**内功：**
| 武功 | 效果 |
|------|------|
| 少林心法 | 防御 +25%，治疗效果 +15% |

---

### 2.7 华山

**武学特点：** 技巧路线，高暴击、高连击

| 武功 | 等级 | 消耗 | 效果 | 来源 |
|------|------|------|------|------|
| 华山剑法 | 基础 | 5 | 单体伤害 ×1.5 + 暴击率 +10% | 拜师获得 |
| 独孤九剑 | 7 | 45 | 单体伤害 ×3.5 + 无视防御 | 隐藏条件 |
| 紫霞神功 | 5 | 30 | 自身增益：攻击 +50%，持续 3 回合 | 修炼 |
| 华山秘传·剑气纵横 | 8 | 50 | 直线范围伤害 ×2.5 + 暴击率 +30% | 掌门传授 |

**内功：**
| 武功 | 效果 |
|------|------|
| 紫霞心法 | 暴击率 +15%，暴击伤害 +30% |

---

### 2.8 黄泉教（敌方/林晚照）

**武学特点：** 毒术 + 诅咒，持续伤害

| 武功 | 等级 | 消耗 | 效果 | 来源 |
|------|------|------|------|------|
| 黄泉剑法 | 基础 | 5 | 单体伤害 ×1.4 + 中毒 1 回合 | 林晚照初始 |
| 幽冥散 | 3 | 18 | 单体伤害 ×1.8 + 中毒（5 回合，每回合 8%） | 修炼 |
| 黄泉引路 | 5 | 25 | 单体伤害 ×2.5 + 沉默 2 回合 | 修炼 |
| 黄泉秘传·万鬼噬心 | 8 | 50 | 圆形范围伤害 ×2.0 + 群体中毒（3 回合） | 教主传授 |

**内功：**
| 武功 | 效果 |
|------|------|
| 黄泉心经 | 毒术伤害 +30%，中毒抗性 +20% |

---

## 三、武功领悟系统

### 3.1 领悟机制

```
武功获取方式：
1. 拜师学艺 → 获得门派基础武功
2. 修炼提升 → 逐步领悟更高级武功
3. 秘籍发现 → 直接学会特定武功
4. NPC 传授 → 好感度足够时传授
5. 战斗中领悟 → 满足特定条件自动领悟
6. 连携技 → 与特定角色好感度高时解锁
```

### 3.2 修炼进度系统

```
修炼进度：
  0% - 未领悟
  1-30% - 初学乍练（效果 50%）
  31-60% - 略有小成（效果 75%）
  61-90% - 驾轻就熟（效果 90%）
  91-99% - 融会贯通（效果 100%）
  100% - 登峰造极（效果 110% + 特殊效果）

修炼方式：
  - 战斗中使用 → 每次 +2-5% 进度
  - 闭关修炼 → 消耗时间，+10-20% 进度
  - NPC 指点 → 消耗银两/好感，+15-30% 进度
  - 顿悟事件 → 特定剧情触发，直接 +30%
```

### 3.3 武功熟练度与升级

```gdscript
# 武功熟练度数据结构
class MartialArtMastery:
    var art_id: String           # 武功 ID
    var proficiency: int         # 熟练度（0-1000）
    var usage_count: int         # 使用次数
    var kill_count: int          # 击杀数
    
    func get_level() -> String:
        if proficiency >= 1000: return "登峰造极"
        if proficiency >= 800: return "炉火纯青"
        if proficiency >= 600: return "融会贯通"
        if proficiency >= 400: return "驾轻就熟"
        if proficiency >= 200: return "略有小成"
        return "初学乍练"
    
    func get_effectiveness() -> float:
        # 根据熟练度计算效果倍率
        if proficiency >= 1000: return 1.1
        if proficiency >= 800: return 1.05
        if proficiency >= 600: return 1.0
        if proficiency >= 400: return 0.9
        if proficiency >= 200: return 0.75
        return 0.5
```

---

## 四、连携技系统

### 4.1 连携技触发条件

| 连携技 | 参与者 | 触发条件 | 效果 |
|--------|--------|----------|------|
| 听雨双剑 | 主角 + 苏清商 | 苏清商好感 ≥ 80 | 双段伤害 ×2.0 + 破甲 |
| 青囊合璧 | 主角 + 药辛夷 | 药辛夷好感 ≥ 80 | 治疗 + 伤害双重效果 |
| 铁血兄弟 | 主角 + 铁山 | 铁山好感 ≥ 70 | 单体伤害 ×3.0 + 击退 |
| 毒剑合击 | 主角 + 林晚照 | 林晚照好感 ≥ 60 | 伤害 + 中毒双重效果 |
| 小满奇袭 | 主角 + 赵小满 | 赵小满好感 ≥ 60 | 偷袭伤害 ×4.0 |

### 4.2 连携技战斗表现

```
触发连携技时：
1. 屏幕出现特殊动画效果
2. 两位角色的台词互动
3. 连携技伤害计算
4. 好感度额外 +5

连携技消耗：
  - 两人各消耗一半内力
  - 如果一人内力不足，效果减半
  - 每场战斗限用 2 次
```

---

## 五、武功克制关系

### 5.1 武功相克

```
克制关系：
  剑法 ←克制→ 刀法     （剑克制刀，刀克制棍）
  刀法 ←克制→ 棍法
  棍法 ←克制→ 拳掌
  拳掌 ←克制→ 暗器
  暗器 ←克制→ 剑法

被克制方受到伤害 +20%
克制方受到伤害 -10%
```

### 5.2 内功相克

```
内功属性：
  阳刚 ←克制→ 阴柔
  阴柔 ←克制→ 中和
  中和 ←克制→ 阳刚

属性克制影响：
  - 内功基础伤害倍率
  - 特殊效果触发概率
```

---

## 六、武功与角色属性

### 6.1 属性对武功的影响

```
属性影响：
  悟性 → 武功领悟速度（+5% / 每点悟性）
  根骨 → 内功修炼效率（+3% / 每点根骨）
  内力 → 武功伤害基数（+1% / 每点内力）
  身法 → 轻功效果（+2% / 每点身法）

示例计算：
  主角悟性 12 → 领悟速度 +60%（基础速度 ×1.6）
  主角根骨 8 → 内功修炼效率 +24%
  主角内力 10 → 武功伤害基数 +10%
```

### 6.2 武功推荐配置

```
主角推荐武功配置（Sprint 2 可用）：

早期（序章~第 1 章）：
  - 断剑剑法（基础）
  - 断影步（轻功）
  - 断剑心法（内功）

中期（第 2~3 章）：
  - 断风式 / 断水式
  - 根据拜师选择获得新武功
  - 开始修炼连携技

后期（第 4~8 章）：
  - 断剑十三式
  - 山河社稷功（家传绝学）
  - 多种连携技
```

---

## 七、Godot 4.3 武功系统实现

### 7.1 武功数据文件

```gdscript
# martial_arts_data.gd — 武功数据库
extends Node

var martial_arts_db: Dictionary = {}

func _ready():
    _load_all_martial_arts()

func _load_all_martial_arts():
    """加载所有武功数据"""
    
    # 断剑山庄
    martial_arts_db["duan_jian_jian_fa"] = {
        "name": "断剑剑法",
        "category": MartialArt.Category.SWORD,
        "level": 1,
        "mp_cost": 5,
        "cooldown": 0,
        "range": 2,
        "target_type": MartialArt.TargetType.SINGLE,
        "base_damage": 1.5,
        "effect_type": MartialArt.EffectType.DAMAGE,
        "description": "断剑山庄基础剑法，刚猛有力。",
        "learn_source": "入门赠送",
    }
    
    martial_arts_db["po_jun"] = {
        "name": "破军",
        "category": MartialArt.Category.SWORD,
        "level": 3,
        "mp_cost": 15,
        "cooldown": 1,
        "range": 2,
        "target_type": MartialArt.TargetType.SINGLE,
        "base_damage": 2.5,
        "effect_type": MartialArt.EffectType.DAMAGE,
        "effect_value": 0.3,  # 破甲 30%
        "description": "山河社稷功第一式，破甲穿透。",
        "learn_source": "家传绝学",
    }
    
    # ... 更多武功数据

func get_martial_art(art_id: String) -> Dictionary:
    """获取武功数据"""
    return martial_arts_db.get(art_id, {})

func get_martial_arts_by_category(category: MartialArt.Category) -> Array:
    """获取指定分类的所有武功"""
    var result = []
    for art_id in martial_arts_db:
        if martial_arts_db[art_id]["category"] == category:
            result.append(art_id)
    return result
```

### 7.2 战斗中使用武功

```gdscript
# battle_controller.gd 中添加武功使用
func use_martial_art(attacker_index: int, art_id: String, target_pos: Vector2i):
    """在战斗中使用武功"""
    var attacker = units[attacker_index]
    var art_data = MartialArtsData.get_martial_art(art_id)
    
    # 检查内力
    if attacker["mp"] < art_data["mp_cost"]:
        log("❌ 内力不足！需要 " + str(art_data["mp_cost"]) + " 点内力")
        return
    
    # 检查冷却
    if attacker.get("cooldowns", {}).get(art_id, 0) > 0:
        log("❌ 武功冷却中，还需 " + str(attacker["cooldowns"][art_id]) + " 回合")
        return
    
    # 检查范围
    var distance = HexUtils.hex_distance(attacker["grid_pos"], target_pos)
    if distance > art_data["range"]:
        log("❌ 超出武功攻击范围！")
        return
    
    # 扣除内力
    attacker["mp"] -= art_data["mp_cost"]
    
    # 设置冷却
    if not attacker.has("cooldowns"):
        attacker["cooldowns"] = {}
    attacker["cooldowns"][art_id] = art_data["cooldown"]
    
    # 计算伤害
    match art_data["target_type"]:
        MartialArt.TargetType.SINGLE:
            _apply_single_effect(attacker, art_data, target_pos)
        MartialArt.TargetType.AOE:
            _apply_aoe_effect(attacker, art_data, target_pos)
        MartialArt.TargetType.LINE:
            _apply_line_effect(attacker, art_data, target_pos)
    
    log("✨ " + attacker["name"] + " 使用了「" + art_data["name"] + "」！")
    
    # 增加熟练度
    _increase_proficiency(attacker_index, art_id)
```

---

**文档版本：** v1.0  
**创建日期：** 2026-04-17  
**状态：** ✅ 已完成
