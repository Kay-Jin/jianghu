# 💰 江湖打工人 — 经济与物品系统详细设计

**版本：** v1.0  
**创建日期：** 2026-04-17  
**关联文档：** GAME_MECHANICS.md / WORLD_SETTING.md

---

## 一、经济系统

### 1.1 货币体系

```
货币类型：
  铜钱（基础货币）—— 日常消费
  银两（常用货币）—— 装备/武功/任务奖励
  黄金（高级货币）—— 稀有物品/大交易
  交子（宋代纸币）—— 大额贸易

换算关系：
  1000 铜钱 = 1 两银子
  10 两银子 = 1 两黄金
  100 两银子 = 1 张交子（面值 100 两）

显示规则：
  - 100 两以下：显示铜钱
  - 100~9999 两：显示银两
  - 10000 两以上：显示交子 + 银两
```

### 1.2 赚钱方式

| 方式 | 收入范围 | 说明 |
|------|----------|------|
| 任务奖励 | 500~5000 两 | 主线/支线任务 |
| 打怪掉落 | 50~500 两 | 击败敌人 |
| 经商贸易 | 100~5000 两 | 低买高卖 |
| 比武赏金 | 200~2000 两 | 地下擂台/比武大会 |
| 打造出售 | 200~3000 两 | 打造多余装备出售 |
| 情报交易 | 500~3000 两 | 听雨楼情报网络 |
| 朝廷赏赐 | 1000~10000 两 | 完成朝廷任务 |
| 偷窃 | 50~500 两 | 赵小满专属，有风险 |

### 1.3 花钱方式

| 消费 | 价格范围 | 说明 |
|------|----------|------|
| 住宿（客栈） | 50~200 两/晚 | 恢复 HP/内力 |
| 吃饭（酒楼） | 10~50 两 | 恢复 HP |
| 买药 | 20~500 两 | 丹药/解毒剂 |
| 买装备 | 100~5000 两 | 武器/防具 |
| 学武功 | 500~5000 两 | 拜师/买秘籍 |
| 打造武器 | 300~8000 两 | 定制武器 |
| 送礼 | 50~2000 两 | 提升好感度 |
| 贿赂 | 100~5000 两 | 特殊用途 |
| 贸易投资 | 1000~50000 两 | 经商系统 |

---

## 二、物品系统

### 2.1 物品分类

```
物品分类：
├── 装备类
│   ├── 武器（剑/刀/拳套/棍/暗器）
│   ├── 防具（衣服/铠甲/披风）
│   ├── 饰品（玉佩/戒指/手链）
│   └── 特殊（家传物品/信物）
├── 消耗品
│   ├── 药品（回复 HP/内力）
│   ├── 解毒剂（解毒/解迷药）
│   ├── 增益道具（临时提升属性）
│   └── 食物（恢复 HP，便宜）
├── 任务物品
│   ├── 剧情道具（推动剧情）
│   ├── 收集道具（任务需要）
│   └── 证据（揭露真相）
├── 材料
│   ├── 铸剑材料（铁/铜/特殊矿石）
│   ├── 药材（炼药/制毒）
│   └── 贸易商品（丝绸/茶叶/瓷器）
└── 特殊
    ├── 秘籍（武功书）
    ├── 信物（身份象征）
    └── 穿越物品（解锁返回现代结局）
```

### 2.2 装备品质体系

| 品质 | 颜色 | 属性加成 | 获取方式 |
|------|------|----------|----------|
| 普通（白） | 白色 | 基础属性 | 商店购买 |
| 精良（绿） | 绿色 | +10% 属性 | 打怪掉落 |
| 稀有（蓝） | 蓝色 | +20% 属性 + 1 特效 | 任务奖励/打造 |
| 史诗（紫） | 紫色 | +30% 属性 + 2 特效 | Boss 掉落/高级打造 |
| 传说（橙） | 橙色 | +50% 属性 + 3 特效 | 隐藏任务/终极打造 |
| 绝世（红） | 红色 | +80% 属性 + 特殊效果 | 唯一获取 |

### 2.3 核心装备清单

#### 武器

| 名称 | 品质 | 攻击加成 | 特效 | 来源 |
|------|------|----------|------|------|
| 断剑 | 精良 | +15% | 对「剑法」武功伤害 +10% | 断剑山庄初始 |
| 听雨剑 | 稀有 | +25% | 攻击时有 15% 概率连击 | 苏清商赠送 |
| 青囊针 | 稀有 | +20% | 攻击附加中毒效果 | 药辛夷赠送 |
| 铁血刀 | 史诗 | +35% | 破甲 20% | 铁血盟任务 |
| 降龙掌套 | 史诗 | +30% | 拳掌武功伤害 +25% | 丐帮任务 |
| 断魂剑 | 传说 | +50% | 攻击无视 30% 防御 | 「铁匠的执念」任务 |
| 山河剑 | 绝世 | +80% | 山河社稷功伤害 +50%，破甲 50% | 集齐《山河社稷功》9 层 |

#### 防具

| 名称 | 品质 | 防御加成 | 特效 | 来源 |
|------|------|----------|------|------|
| 布衣 | 普通 | +5% | 无 | 初始 |
| 断剑服 | 精良 | +15% | 受到剑法伤害 -10% | 断剑山庄 |
| 听雨衣 | 稀有 | +25% | 闪避率 +10% | 听雨楼任务 |
| 青囊衣 | 稀有 | +20% | 中毒伤害 -30% | 青囊谷任务 |
| 金钟甲 | 史诗 | +35% | 受到暴击伤害 -50% | 少林任务 |
| 龙纹甲 | 传说 | +50% | 全属性 +10% | 隐藏任务 |

#### 饰品

| 名称 | 品质 | 效果 | 来源 |
|------|------|------|------|
| 断玉佩 | 传说 | 叶家血脉标识，解锁《山河社稷功》 | 林素心给予 |
| 听雨楼令牌 | 稀有 | 听雨楼贡献获取 +50% | 苏清商给予 |
| 药王印 | 稀有 | 治疗效果 +20% | 药王给予 |
| 丐帮打狗令 | 史诗 | 丐帮任务奖励 +30% | 丐帮长老给予 |
| 黄泉教令牌 | 史诗 | 毒术伤害 +30% | 林晚照给予 |

### 2.4 药品清单

| 名称 | 价格 | 效果 | 来源 |
|------|------|------|------|
| 金创药 | 50 两 | 恢复 30% HP | 药铺 |
| 小还丹 | 100 两 | 恢复 20% 内力 | 药铺 |
| 大还丹 | 300 两 | 恢复 50% HP + 20% 内力 | 药铺/青囊谷 |
| 九花玉露丸 | 500 两 | 恢复 80% HP | 青囊谷专属 |
| 解毒丹 | 80 两 | 解除中毒 | 药铺 |
| 续命丹 | 2000 两 | 战斗中复活（一次） | 药辛夷特制 |
| 七叶灵芝 | 稀有 | 解除奇毒，内力 +50 | 「七叶灵芝」任务 |
| 忘忧水 | 3000 两 | 清除一个负面状态 | 鬼市商人 |

---

## 三、贸易系统

### 3.1 各地物价差异

```
商品产地 vs 售价差异：

丝绸：
  产地（姑苏）：10 两/匹
  临渊城：15 两/匹
  燕山城：25 两/匹（北方缺丝绸）
  利润率：150%

茶叶：
  产地（岭南）：8 两/斤
  姑苏城：12 两/斤
  临渊城：15 两/斤
  利润率：87%

铁器：
  产地（蜀中断剑山庄）：20 两/件
  临渊城：30 两/件
  燕山城：50 两/件（北方前线需要）
  利润率：150%

药材：
  产地（岭南青囊谷）：5 两/份
  姑苏城：10 两/份
  临渊城：12 两/份
  利润率：140%
```

### 3.2 贸易玩法

```
贸易系统：
1. 低买高卖
   - 在产地买入，在远地卖出
   - 需要携带容量（背包格子）
   - 路费时间成本

2. 委托贸易
   - 委托商人代为运输
   - 需要支付佣金（10%）
   - 有风险（被劫 5% 概率）

3. 投资商铺
   - 在城镇投资商铺
   - 每日获得利润分成
   - 需要初始投资 1000~5000 两
   - 回报率：5~15%/天

4. 垄断贸易
   - 大量买入某种商品
   - 推高当地价格
   - 然后高价卖出
   - 需要大量资金
```

---

## 四、背包系统

### 4.1 背包结构

```
背包容量：
  初始：20 格
  扩展：每找到一个包袱 +5 格（最多 50 格）
  特殊物品：任务物品不占背包空间

物品堆叠：
  药品/材料/货币：可堆叠（99 个/格）
  装备：不可堆叠（1 个/格）
  特殊物品：不可堆叠（1 个/格）

背包 UI：
  4×5 网格（初始）
  拖拽整理
  点击查看详情
  右键使用/装备
```

### 4.2 Godot 4.3 背包实现

```gdscript
# inventory_system.gd
extends Node

class_name InventorySystem

signal inventory_changed
signal item_used(item_id: String)
signal item_equipped(item_id: String)

# 背包数据
var slots: Array[Dictionary] = []
var max_slots: int = 20

# 物品数据库引用
var item_db: Dictionary = {}

func _ready():
    _init_inventory()

func _init_inventory():
    """初始化背包"""
    for i in range(max_slots):
        slots.append({"item_id": "", "quantity": 0})

func add_item(item_id: String, quantity: int = 1) -> bool:
    """添加物品到背包"""
    var item_data = get_item_data(item_id)
    if not item_data:
        return false
    
    # 检查是否可堆叠
    if item_data.get("stackable", false):
        # 尝试合并到已有堆叠
        for slot in slots:
            if slot["item_id"] == item_id and slot["quantity"] < 99:
                var space = 99 - slot["quantity"]
                var add_qty = min(quantity, space)
                slot["quantity"] += add_qty
                quantity -= add_qty
                if quantity <= 0:
                    inventory_changed.emit()
                    return true
        
        # 需要新格子
        if quantity > 0:
            var empty_slot = _find_empty_slot()
            if empty_slot == -1:
                return false  # 背包满了
            slots[empty_slot] = {"item_id": item_id, "quantity": quantity}
            inventory_changed.emit()
            return true
    else:
        # 不可堆叠，每个占一格
        for i in range(quantity):
            var empty_slot = _find_empty_slot()
            if empty_slot == -1:
                return false
            slots[empty_slot] = {"item_id": item_id, "quantity": 1}
        
        inventory_changed.emit()
        return true
    
    return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
    """从背包移除物品"""
    var removed = 0
    for slot in slots:
        if slot["item_id"] == item_id:
            var remove_qty = min(quantity - removed, slot["quantity"])
            slot["quantity"] -= remove_qty
            removed += remove_qty
            if slot["quantity"] <= 0:
                slot["item_id"] = ""
                slot["quantity"] = 0
            if removed >= quantity:
                inventory_changed.emit()
                return true
    return false

func has_item(item_id: String, quantity: int = 1) -> bool:
    """检查是否有足够物品"""
    var total = 0
    for slot in slots:
        if slot["item_id"] == item_id:
            total += slot["quantity"]
    return total >= quantity

func use_item(item_id: String) -> bool:
    """使用物品"""
    if not has_item(item_id):
        return false
    
    var item_data = get_item_data(item_id)
    if not item_data:
        return false
    
    # 根据物品类型执行效果
    match item_data.get("type", ""):
        "potion":
            _apply_potion_effect(item_data)
        "equipment":
            _equip_item(item_id)
        "quest":
            _trigger_quest_event(item_id)
        "food":
            _apply_food_effect(item_data)
    
    # 消耗物品（如果是消耗品）
    if item_data.get("consumable", false):
        remove_item(item_id, 1)
    
    item_used.emit(item_id)
    return true

func _find_empty_slot() -> int:
    """找到第一个空槽位"""
    for i in range(slots.size()):
        if slots[i]["item_id"] == "":
            return i
    return -1

func expand_inventory(additional_slots: int):
    """扩展背包容量"""
    for i in range(additional_slots):
        slots.append({"item_id": "", "quantity": 0})
    max_slots += additional_slots
    inventory_changed.emit()

func get_inventory_ui_data() -> Array:
    """获取背包 UI 数据"""
    var result = []
    for slot in slots:
        if slot["item_id"] != "":
            var item_data = get_item_data(slot["item_id"])
            result.append({
                "item_id": slot["item_id"],
                "quantity": slot["quantity"],
                "name": item_data.get("name", ""),
                "icon": item_data.get("icon", ""),
                "type": item_data.get("type", ""),
                "quality": item_data.get("quality", "white"),
                "description": item_data.get("description", ""),
            })
        else:
            result.append(null)
    return result
```

---

## 五、商店系统

### 5.1 商店类型

| 商店类型 | 出售物品 | 特色 |
|----------|----------|------|
| 药铺 | 药品/解毒剂 | 价格随地区变化 |
| 铁匠铺 | 武器/防具 | 可打造/升级 |
| 杂货铺 | 日常用品 | 便宜但质量低 |
| 古玩店 | 稀有物品/古董 | 高价高价值 |
| 黑市 | 禁药/稀有装备 | 非法物品，高价 |
| 拍卖会 | 稀有物品竞拍 | 竞价系统 |

### 5.2 商店 UI 设计

```
商店界面：
┌─────────────────────────────┐
│ 🏪 [商店名称]               │
│ 💰 你的银两：1,234 两        │
├─────────────────────────────┤
│ [物品图标] [物品名称]       │
│              价格：50 两     │
│              库存：10        │
│              [购买]          │
│                             │
│ [物品图标] [物品名称]       │
│              价格：100 两    │
│              库存：5         │
│              [购买]          │
├─────────────────────────────┤
│ [出售模式] [购买模式]       │
│ [离开]                      │
└─────────────────────────────┘
```

---

**文档版本：** v1.0  
**创建日期：** 2026-04-17  
**状态：** ✅ 已完成
