# 🗺️ 江湖打工人 — 大地图探索系统详细设计

**版本：** v1.0  
**创建日期：** 2026-04-17  
**关联文档：** WORLD_SETTING.md / SCRIPT_AND_CITIES.md / SONG_CITIES.md

---

## 一、大地图架构

### 1.1 地图层级

```
地图系统分三层：

📍 世界大地图（World Map）
  ├── 显示全国地理概貌
  ├── 标注城镇/门派/特殊地点
  └── 点击地点进入场景地图
  
📍 场景地图（Scene Map）
  ├── 城镇内部地图
  ├── 显示各区域入口
  └── 点击区域进入室内地图
  
📍 室内地图（Interior Map）
  ├── 具体建筑内部
  ├── NPC 互动
  └── 对话/交易/任务触发
```

### 1.2 世界大地图设计

```
大地图布局（九宫格区域）：

┌─────────┬─────────┬─────────┐
│ 西北荒漠 │ 河北燕山 │ 辽东     │
│ 龙门客栈 │ 铁血盟   │ 金国边境 │
├─────────┼─────────┼─────────┤
│ 蜀中青城 │ 临渊城   │ 东海蓬莱│
│ 断剑山庄 │ ★京城   │ 忘机渡   │
├─────────┼─────────┼─────────┤
│ 岭南十万 │ 江南姑苏 │ 江南南部│
│ 大山青囊 │ 听雨楼   │ 临安    │
└─────────┴─────────┴─────────┘

地图大小：1920×1080（适配主流分辨率）
地图风格：水墨风，宋代地图样式
```

---

## 二、探索系统

### 2.1 探索机制

```
探索属性：
  探索度：每个区域 0%~100%
  探索内容：
    - 发现隐藏地点
    - 触发随机事件
    - 收集资源（药材/矿石）
    - 遇到 NPC/敌人

探索方式：
  1. 移动到大地图地点 → 探索度 +10%
  2. 使用「探索」功能 → 消耗时间，探索度 +5~20%
  3. 完成任务/支线 → 探索度 +10~30%
  4. 特定角色带路 → 探索度 +15~25%

探索奖励：
  10%：发现一个小事件
  30%：发现一个隐藏商店/NPC
  50%：发现一个支线任务
  70%：发现一个隐藏武功线索
  90%：发现一个稀有资源点
  100%：完全探索，获得成就 + 永久加成
```

### 2.2 随机事件系统

```
探索中随机触发事件（根据区域不同）：

西北荒漠：
  - 遭遇沙贼（战斗）
  - 发现古道遗迹（隐藏武功）
  - 遇到商队（贸易机会）
  - 沙暴（负面事件，HP-10%）

河北燕山：
  - 遭遇金国巡逻队（战斗）
  - 遇到难民（道德选择）
  - 发现军事密信（剧情线索）
  - 铁血盟求援（任务）

蜀中青城：
  - 遇到采药人（药材交易）
  - 山贼拦路（战斗）
  - 发现隐秘洞穴（奇遇）
  - 断剑山庄弟子切磋（战斗，赢了有奖励）

江南姑苏：
  - 遇到文人雅集（学识提升）
  - 游船事故（救援事件）
  - 听雨楼情报（免费情报）
  - 园林寻宝（解谜）

东海蓬莱：
  - 遇到渔民求救（任务）
  - 海战海盗（战斗）
  - 发现仙山（隐藏地点）
  - 出海冒险（副本）
```

### 2.3 随机事件 — Godot 4.3 实现

```gdscript
# random_events.gd
extends Node

class_name RandomEventSystem

signal event_triggered(event_data: Dictionary)

# 随机事件数据库
var event_pool: Dictionary = {}

# 当前区域的事件列表
var current_region_events: Array[Dictionary] = []

# 已触发事件（不再重复）
var triggered_events: Array[String] = []

func _ready():
    _load_event_pool()

func _load_event_pool():
    """加载所有随机事件"""
    
    event_pool["northwest_desert"] = [
        {
            "id": "sand_bandits",
            "name": "沙贼拦路",
            "type": "combat",
            "weight": 30,  # 触发权重
            "min_exploration": 0,
            "description": "一群沙贼从沙丘后冲出！",
            "reward": {"silver": 200, "exploration": 5},
        },
        {
            "id": "ancient_ruins",
            "name": "古道遗迹",
            "type": "discovery",
            "weight": 10,
            "min_exploration": 30,
            "description": "你在沙丘下发现了一处古代遗迹……",
            "reward": {"martial_art": "desert_sword", "exploration": 15},
        },
        {
            "id": "sandstorm",
            "name": "沙暴来袭",
            "type": "negative",
            "weight": 15,
            "min_exploration": 0,
            "description": "狂风大作，黄沙漫天！",
            "penalty": {"hp_percent": 10},
            "reward": {"exploration": 5},
        },
    ]
    
    event_pool["jiangsu_gusu"] = [
        {
            "id": "literati_gathering",
            "name": "文人雅集",
            "type": "social",
            "weight": 20,
            "min_exploration": 0,
            "description": "一群文人正在湖畔吟诗作对……",
            "reward": {"intelligence": 5, "silver": 100},
        },
        {
            "id": "garden_treasure",
            "name": "园林寻宝",
            "type": "puzzle",
            "weight": 15,
            "min_exploration": 20,
            "description": "园林深处似乎有什么东西……",
            "reward": {"item": "ancient_sword", "exploration": 20},
        },
    ]
    
    # ... 更多区域事件

func set_current_region(region_id: String):
    """设置当前区域"""
    if event_pool.has(region_id):
        current_region_events = event_pool[region_id].duplicate()
    else:
        current_region_events = []

func check_random_event(exploration: int) -> Dictionary:
    """检查是否触发随机事件"""
    if current_region_events.is_empty():
        return {}
    
    # 筛选可触发事件
    var available = []
    for event in current_region_events:
        if exploration >= event["min_exploration"] and not triggered_events.has(event["id"]):
            available.append(event)
    
    if available.is_empty():
        return {}
    
    # 按权重随机
    var total_weight = 0
    for event in available:
        total_weight += event["weight"]
    
    var roll = randi() % total_weight
    var cumulative = 0
    for event in available:
        cumulative += event["weight"]
        if roll < cumulative:
            triggered_events.append(event["id"])
            event_triggered.emit(event)
            return event
    
    return {}

# ===== 事件处理 =====
func resolve_event(event: Dictionary, choice: String) -> Dictionary:
    """处理玩家选择，返回结果"""
    var result = {"success": false, "message": "", "rewards": {}}
    
    match event["type"]:
        "combat":
            result = _resolve_combat_event(event, choice)
        "discovery":
            result = _resolve_discovery_event(event, choice)
        "social":
            result = _resolve_social_event(event, choice)
        "puzzle":
            result = _resolve_puzzle_event(event, choice)
        "negative":
            result = _resolve_negative_event(event, choice)
    
    return result

func _resolve_combat_event(event: Dictionary, choice: String) -> Dictionary:
    """处理战斗事件"""
    return {
        "success": true,
        "message": "你击败了敌人！",
        "rewards": event.get("reward", {}),
    }

func _resolve_discovery_event(event: Dictionary, choice: String) -> Dictionary:
    """处理发现事件"""
    return {
        "success": true,
        "message": "你发现了一个秘密！",
        "rewards": event.get("reward", {}),
    }

func _resolve_social_event(event: Dictionary, choice: String) -> Dictionary:
    """处理社交事件"""
    return {
        "success": true,
        "message": "你结交了新朋友！",
        "rewards": event.get("reward", {}),
    }

func _resolve_puzzle_event(event: Dictionary, choice: String) -> Dictionary:
    """处理解谜事件"""
    # 根据选择判断对错
    if choice == event.get("correct_choice", ""):
        return {
            "success": true,
            "message": "你解开了谜题！",
            "rewards": event.get("reward", {}),
        }
    else:
        return {
            "success": false,
            "message": "你没有找到正确答案。",
            "rewards": {},
        }

func _resolve_negative_event(event: Dictionary, choice: String) -> Dictionary:
    """处理负面事件"""
    return {
        "success": false,
        "message": "你遭遇了不幸……",
        "penalty": event.get("penalty", {}),
    }
```

---

## 三、传送系统

### 3.1 传送方式

| 方式 | 速度 | 成本 | 说明 |
|------|------|------|------|
| 步行 | 最慢 | 免费 | 探索度高时更快 |
| 骑马 | 快 | 10 两/次 | 需要马匹 |
| 马车 | 快 | 50 两/次 | 可带多人 |
| 船只 | 中等 | 30 两/次 | 水路专用 |
| 轻功赶路 | 快 | 消耗内力 | 身法 ≥ 50 |
| 听雨楼密道 | 瞬间 | 免费 | 好感 ≥ 60 |
| 丐帮密道 | 瞬间 | 免费 | 丐帮声望 ≥ 50 |

### 3.2 传送点设计

```
主要传送点：
  临渊城 ↔ 各城镇
  姑苏城 ↔ 临安城（水路）
  燕山城 ↔ 临渊城（官道）
  蓬莱城 ↔ 东海各岛（海路）
  
隐藏传送点：
  听雨楼密道网络（需好感解锁）
  丐帮密道（需声望解锁）
  黄泉教密道（林晚照剧情解锁）
```

---

## 四、大地图 — Godot 4.3 实现框架

```gdscript
# world_map.gd — 大地图系统
extends Node2D

@export var regions: Dictionary = {}
@export var player_position: Vector2 = Vector2(960, 540)  # 初始位置

var current_region: String = ""
var exploration_progress: Dictionary = {}

signal region_entered(region_id: String)
signal event_triggered(event_data: Dictionary)

func _ready():
    _init_regions()

func _init_regions():
    """初始化各区域"""
    regions = {
        "duan_jian_shanzhuang": {
            "name": "断剑山庄",
            "position": Vector2(400, 600),
            "type": "sect",
            "unlocked": true,
            "exploration": 0,
            "description": "蜀中青城山下，断剑山庄所在地。",
        },
        "lin_yuan_city": {
            "name": "临渊城",
            "position": Vector2(960, 540),
            "type": "capital",
            "unlocked": true,
            "exploration": 0,
            "description": "全国政治中心，最繁华的大城镇。",
        },
        "gu_su_city": {
            "name": "姑苏城",
            "position": Vector2(1200, 700),
            "type": "city",
            "unlocked": true,
            "exploration": 0,
            "description": "江南第一大城，听雨楼总部。",
        },
        # ... 更多区域
    }
    
    # 初始化探索进度
    for region_id in regions:
        exploration_progress[region_id] = 0

func enter_region(region_id: String):
    """进入一个区域"""
    if not regions.has(region_id):
        return
    
    current_region = region_id
    var region = regions[region_id]
    
    # 增加探索度
    exploration_progress[region_id] = min(100, exploration_progress[region_id] + 10)
    
    # 检查随机事件
    if RandomEvents:
        RandomEvents.set_current_region(region_id)
        var event = RandomEvents.check_random_event(exploration_progress[region_id])
        if not event.is_empty():
            event_triggered.emit(event)
    
    region_entered.emit(region_id)

func get_region_info(region_id: String) -> Dictionary:
    """获取区域信息"""
    if regions.has(region_id):
        var info = regions[region_id].duplicate()
        info["exploration"] = exploration_progress.get(region_id, 0)
        return info
    return {}

func travel_to_region(from: String, to: String, method: String) -> Dictionary:
    """旅行到另一个区域"""
    if not regions.has(from) or not regions.has(to):
        return {"success": false, "message": "未知区域"}
    
    if not regions[to]["unlocked"]:
        return {"success": false, "message": "该区域尚未解锁"}
    
    # 根据旅行方式计算时间和成本
    var travel_data = _calculate_travel(from, to, method)
    
    if not travel_data["can_afford"]:
        return {"success": false, "message": travel_data["reason"]}
    
    # 扣除成本
    # 更新位置
    player_position = regions[to]["position"]
    current_region = to
    
    return {
        "success": true,
        "time_passed": travel_data["time"],
        "cost": travel_data["cost"],
        "message": "到达" + regions[to]["name"],
    }

func _calculate_travel(from: String, to: String, method: String) -> Dictionary:
    """计算旅行数据"""
    var distances = {
        ("duan_jian_shanzhuang", "lin_yuan_city"): 3,
        ("lin_yuan_city", "gu_su_city"): 2,
        # ... 更多距离
    }
    
    var costs = {
        "walk": {"time": 3, "silver": 0, "mp": 0},
        "horse": {"time": 1, "silver": 10, "mp": 0},
        "carriage": {"time": 1, "silver": 50, "mp": 0},
        "boat": {"time": 2, "silver": 30, "mp": 0},
        "qinggong": {"time": 1, "silver": 0, "mp": 20},
    }
    
    var travel = costs.get(method, costs["walk"])
    
    return {
        "time": travel["time"],
        "cost": travel["silver"],
        "mp_cost": travel["mp"],
        "can_afford": true,  # 需要检查玩家实际资源
        "reason": "",
    }
```

---

## 五、大地图 UI 设计

```
大地图界面：
┌─────────────────────────────────────┐
│ 🗺️ 江湖大地图                       │
│ 时间：[年/月/日] 天气：[晴/雨/雪]    │
├─────────────────────────────────────┤
│                                     │
│         🏔️ 西北荒漠                  │
│                                     │
│  🏯 断剑山庄    🏯 临渊城★    🏯 蓬莱│
│                                     │
│         🏯 姑苏城                    │
│                                     │
├─────────────────────────────────────┤
│ 📍 当前：临渊城                      │
│ 🔍 探索度：45%                      │
│ [探索] [传送] [返回]                │
└─────────────────────────────────────┘

点击地点后弹出信息：
┌─────────────────────┐
│ 🏯 姑苏城            │
│ 江南第一大城         │
│ 探索度：45%          │
│ ─────────           │
│ [前往] [探索] [关闭] │
└─────────────────────┘
```

---

**文档版本：** v1.0  
**创建日期：** 2026-04-17  
**状态：** ✅ 已完成
