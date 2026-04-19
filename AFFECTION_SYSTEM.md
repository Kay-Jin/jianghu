# 💕 江湖打工人 — 好感度系统详细设计

**版本：** v1.0  
**创建日期：** 2026-04-17  
**关联文档：** CHARACTERS.md / SIDE_QUESTS.md

---

## 一、好感度系统核心架构

### 1.1 好感度数值范围

```
好感度范围：0 ~ 120

阶段划分：
  0-20    → 陌生人（冷淡，不会主动互动）
  21-40   → 认识（偶尔对话，不会帮忙）
  41-60   → 朋友（会帮忙，偶尔触发日常互动）
  61-80   → 好友（主动帮忙，解锁支线任务）
  81-100  → 亲密（解锁连携技，专属剧情）
  101-120 → 挚爱（仅对可攻略角色，解锁隐藏结局）

⚠️ 100 是默认上限，只有完成特定任务才能突破到 120
```

### 1.2 好感度获取方式

| 方式 | 好感变化 | 说明 |
|------|----------|------|
| 战斗中选择帮助她 | +5~10 | 战斗中用武功保护/辅助 |
| 对话选择让她开心 | +3~5 | 正确的对话选项 |
| 完成她的专属支线 | +15~25 | 重大剧情奖励 |
| 送礼物 | +5~15 | 根据喜好不同 |
| 一起探索 | +2~5 | 大地图同行 |
| 节日互动 | +5~10 | 特殊节日活动 |
| 错误对话选择 | -3~10 | 选了她讨厌的回答 |
| 战斗中让她受伤 | -5~15 | 误伤友军 |
| 长时间不理她 | -1/天 | 好感度会缓慢下降（60 以上不下降） |

---

## 二、各女主喜好设定

### 2.1 苏清商（听雨楼少主）

| 属性 | 设定 |
|------|------|
| **性格** | 冷艳、理智、外冷内热 |
| **喜欢** | 信任、尊重、能力强、不轻浮 |
| **讨厌** | 轻浮、优柔寡断、说谎 |
| **喜欢的礼物** | 诗集（+10）、古董剑（+15）、听雨楼旧物（+20） |
| **讨厌的礼物** | 胭脂（-5，她不用这些）、花（-3，觉得太俗） |

**对话偏好：**
```
场景：她问你在想什么。

A) "在想怎么保护你。"（好感 +5，但有点轻浮）
B) "在想下一步怎么做。"（好感 +3，她喜欢务实）
C) "在想……你以前经历了什么。"（好感 +8，她感动） ← 最佳

场景：她遇到危险。

A) "别怕，我来！"（好感 +5，普通）
B) "你自己能行吗？"（好感 -10，她不信任你）
C) "我们一起！"（好感 +8，她喜欢被当作平等） ← 最佳
```

**关键好感节点：**
| 好感度 | 解锁 |
|--------|------|
| 40 | 「听雨楼危机」支线 |
| 60 | 「苏清商的过去」支线 |
| 80 | 连携技「听雨双剑」 |
| 100 | 专属剧情「雨夜谈心」 |
| 120 | 隐藏结局「听雨相伴」 |

---

### 2.2 药辛夷（青囊谷传人）

| 属性 | 设定 |
|------|------|
| **性格** | 活泼、天真、善良、偶尔冒失 |
| **喜欢** | 关心她、保护她、幽默、认真 |
| **讨厌** | 冷漠、欺骗、忽视她的专业能力 |
| **喜欢的礼物** | 稀有药材（+15）、手工艺品（+10）、甜食（+8） |
| **讨厌的礼物** | 武器（-5，她不喜欢暴力）、虫子（-10，怕） |

**对话偏好：**
```
场景：她采药时遇到危险。

A) "别去那么危险的地方了！"（好感 -3，她觉得被限制了）
B) "我陪你去吧，安全第一。"（好感 +8，她喜欢被关心） ← 最佳
C) "你自己小心点。"（好感 +0，普通关心）

场景：她做出了一道新菜。

A) "……这是什么东西？"（好感 -10，大忌！）
B) "看起来很好吃！"（好感 +5，虽然可能不好吃）
C) "你做饭的手艺和医术一样好！"（好感 +10，夸到点子上了） ← 最佳
```

**关键好感节点：**
| 好感度 | 解锁 |
|--------|------|
| 30 | 「七叶灵芝」支线 |
| 60 | 「药辛夷的秘密」支线 |
| 80 | 连携技「青囊合璧」 |
| 100 | 专属剧情「辛夷花开」 |
| 120 | 隐藏结局「青囊相伴」 |

---

### 2.3 赵小满（小乞丐）

| 属性 | 设定 |
|------|------|
| **性格** | 活泼、机灵、渴望被爱、害怕被抛弃 |
| **喜欢** | 温暖、安全感、食物、陪伴 |
| **讨厌** | 被忽视、被命令、孤独 |
| **喜欢的礼物** | 好吃的（+10）、新衣服（+15）、玩具（+8） |
| **讨厌的礼物** | 书（-3，她不识字但不想被提醒）、冷兵器（-5） |

**对话偏好：**
```
场景：她问你会不会丢下她。

A) "不会的。"（好感 +3，但她可能不信）
B) "你是我妹妹，怎么会丢下你。"（好感 +10，她最需要的称呼） ← 最佳
C) "到时候再说吧。"（好感 -5，她最怕不确定）

场景：她偷了东西被发现。

A) "你怎么又偷东西！"（好感 -10，她觉得被骂了）
B) "下次别这样了，缺什么跟我说。"（好感 +10，她需要引导） ← 最佳
C) "算了，这次我帮你赔。"（好感 +5，但可能惯坏她）
```

**关键好感节点：**
| 好感度 | 解锁 |
|--------|------|
| 20 | 「小满的故事」支线（了解她的过去） |
| 50 | 「小满的家」支线（帮她找一个安稳的地方） |
| 80 | 连携技「小满奇袭」 |
| 100 | 专属剧情「小满的第一个家」 |
| 120 | 隐藏结局「小满归来」 |

---

### 2.4 林晚照（黄泉教圣女）

| 属性 | 设定 |
|------|------|
| **性格** | 忧郁、深沉、有故事、渴望被理解 |
| **喜欢** | 被倾听、被理解、真诚 |
| **讨厌** | 虚伪、偏见、轻率的承诺 |
| **喜欢的礼物** | 旧信（+15，她父亲留下的）、月光石（+10）、诗集（+8） |
| **讨厌的礼物** | 佛珠（-10，她不信佛）、花哨的东西（-3） |

**对话偏好：**
```
场景：她谈论她父亲。

A) "你父亲一定是个好人。"（好感 +3，但有点敷衍）
B) "你想他吗？"（好感 +8，她需要被理解） ← 最佳
C) "过去的事就让它过去吧。"（好感 -5，她最讨厌这句话）

场景：她问你是否相信她。

A) "我相信你。"（好感 +5，但不够）
B) "我相信你的为人。"（好感 +8，更深入）
C) "我不需要相信你，因为你值得信任。"（好感 +12，说到心坎了） ← 最佳
```

**关键好感节点：**
| 好感度 | 解锁 |
|--------|------|
| 40 | 「黄泉教的真相」支线 |
| 60 | 「晚照的新生」支线 |
| 80 | 连携技「毒剑合击」 |
| 100 | 专属剧情「月下故人」 |
| 120 | 隐藏结局「晚照新生」 |

---

### 2.5 云墨烟（青楼花魁）

| 属性 | 设定 |
|------|------|
| **性格** | 温柔、知性、外热内冷、有秘密 |
| **喜欢** | 尊重、真诚、懂她的人 |
| **讨厌** | 轻浮、无礼、只看外表 |
| **喜欢的礼物** | 古琴曲谱（+15）、书画（+10）、茶（+8） |
| **讨厌的礼物** | 首饰（-5，觉得太俗）、钱（-15，最讨厌） |

**关键好感节点：**
| 好感度 | 解锁 |
|--------|------|
| 30 | 「轻烟的心事」支线 |
| 60 | 「青楼暗线」支线（她其实是听雨楼卧底） |
| 80 | 解锁情报网络 |
| 100 | 专属剧情「月下琴声」 |

---

## 三、好感度系统 — Godot 4.3 实现

### 3.1 数据结构

```gdscript
# affection_system.gd
extends Node

class_name AffectionSystem

# 好感度数据
var affection_data: Dictionary = {}

# 好感度变化回调信号
signal affection_changed( character_id: String, old_value: int, new_value: int, reason: String )
signal milestone_reached( character_id: String, milestone: int )

func _ready():
    # 初始化所有角色好感度
    _init_affection()

func _init_affection():
    """初始化所有角色好感度"""
    var characters = [
        "su_qingshang",
        "yao_xinyi",
        "zhao_xiaoman",
        "lin_wanzhao",
        "liu_qingyan",
        "tie_shan",        # 伙伴也有好感度
        "iron_meng_leader", # 铁血盟盟主
    ]
    
    for char_id in characters:
        affection_data[char_id] = {
            "current": 0,
            "max": 100,
            "history": [],  # 好感度变化记录
            "milestones": [],  # 已解锁的好感度节点
        }

func change_affection(character_id: String, amount: int, reason: String = ""):
    """改变好感度"""
    if not affection_data.has(character_id):
        return
    
    var data = affection_data[character_id]
    var old_value = data["current"]
    var new_value = clamp(old_value + amount, 0, data["max"])
    
    data["current"] = new_value
    
    # 记录变化
    data["history"].append({
        "amount": amount,
        "reason": reason,
        "timestamp": Time.get_unix_time_from_system(),
    })
    
    # 检查是否突破 100
    if old_value <= 100 and new_value > 100:
        data["max"] = 120  # 突破上限！
    
    # 检查是否达到新节点
    _check_milestones(character_id, old_value, new_value)
    
    # 发出信号
    affection_changed.emit(character_id, old_value, new_value, reason)
    
    # 日志
    if amount > 0:
        print("💕 ", character_id, " 好感度 +", amount, " (", old_value, "→", new_value, ")")
    else:
        print("💔 ", character_id, " 好感度 ", amount, " (", old_value, "→", new_value, ")")

func _check_milestones(character_id: String, old_value: int, new_value: int):
    """检查是否达到好感度节点"""
    var milestones = [20, 40, 60, 80, 100, 120]
    
    for milestone in milestones:
        if old_value < milestone and new_value >= milestone:
            if not affection_data[character_id]["milestones"].has(milestone):
                affection_data[character_id]["milestones"].append(milestone)
                milestone_reached.emit(character_id, milestone)
                print("🎉 ", character_id, " 好感度达到 ", milestone, "！解锁新内容！")

func get_affection(character_id: String) -> int:
    """获取当前好感度"""
    if affection_data.has(character_id):
        return affection_data[character_id]["current"]
    return 0

func get_affection_level(character_id: String) -> String:
    """获取好感度等级描述"""
    var value = get_affection(character_id)
    if value >= 101: return "挚爱"
    if value >= 81: return "亲密"
    if value >= 61: return "好友"
    if value >= 41: return "朋友"
    if value >= 21: return "认识"
    return "陌生人"

func get_affection_color(character_id: String) -> Color:
    """获取好感度对应的颜色（UI 用）"""
    var value = get_affection(character_id)
    if value >= 101: return Color(1.0, 0.4, 0.7)  # 粉色
    if value >= 81: return Color(1.0, 0.6, 0.8)
    if value >= 61: return Color(0.6, 0.8, 1.0)
    if value >= 41: return Color(0.8, 1.0, 0.6)
    if value >= 21: return Color(1.0, 1.0, 0.6)
    return Color(0.7, 0.7, 0.7)

# ===== 存档/读档 =====
func save_affection() -> Dictionary:
    """保存好感度数据"""
    return affection_data.duplicate(true)

func load_affection(data: Dictionary):
    """加载好感度数据"""
    affection_data = data.duplicate(true)
```

### 3.2 对话中的好感度影响

```gdscript
# dialog_system.gd 中添加好感度逻辑
func _make_dialog_choice(choice_index: int):
    """玩家做出对话选择"""
    var choice = current_dialog["choices"][choice_index]
    
    # 检查是否有好感度影响
    if choice.has("affection_changes"):
        for char_id in choice["affection_changes"]:
            Affection.change_affection(
                char_id, 
                choice["affection_changes"][char_id],
                choice.get("reason", "对话选择")
            )
    
    # 检查是否解锁新对话
    _check_dialog_unlock()
```

### 3.3 战斗中的好感度影响

```gdscript
# battle_controller.gd 中添加
func protect_ally(protector_index: int, protected_index: int):
    """战斗中保护队友"""
    var protector = units[protector_index]
    var protected = units[protected_index]
    
    # 找到对应的角色 ID
    var char_id = get_character_id(protected_index)
    
    if char_id:
        # 保护成功，好感度增加
        Affection.change_affection(char_id, 5, "战斗中保护")
        print("💕 保护了 ", char_id, "，好感度 +5")
```

---

## 四、好感度 UI 设计

### 4.1 好感度显示

```
队伍面板中显示：
  [角色头像] [角色名称] 
  ❤️❤️❤️💔💔 (好感度可视化：5 颗心，每颗代表 20 点)
  Lv. 好友 (61-80)
  
点击角色可查看详细好感度：
  当前好感度：75/100
  好感等级：好友
  距离下一级：还需 5 点到 80（亲密）
  已解锁：连携技「听雨双剑」
  下一解锁：专属剧情「雨夜谈心」（100）
```

### 4.2 好感度变化通知

```
当好感度变化时，屏幕右上角弹出通知：

  💕 苏清商好感度 +8 → 83
  「你选择关心她，她感动了。」
  
  💔 药辛夷好感度 -5 → 42
  「你质疑了她的专业能力，她不高兴了。」
```

---

## 五、好感度与结局

### 5.1 结局判定

```
游戏结局受好感度影响：

终章「侠之大者」结局判定：

if su_qingshang >= 100:
    unlock_ending("听雨相伴")  # 和苏清商隐居
elif yao_xinyi >= 100:
    unlock_ending("青囊相伴")  # 和药辛夷开医馆
elif zhao_xiaoman >= 100:
    unlock_ending("小满归来")  # 赵小满成为家人
elif lin_wanzhao >= 100:
    unlock_ending("晚照新生")  # 林晚照放下仇恨
elif total_affection >= 200:  # 多角色高好感
    unlock_ending("江湖传说")  # 众人敬仰
else:
    unlock_ending("孤家寡人")  # 孤独终老
```

### 5.2 多角色好感度冲突

```
如果多个角色好感度都 >= 100：

主角需要在终章做出最终选择：
  - 选择一个角色作为最终伴侣
  - 其他角色好感度降至 80
  - 选择不可逆，影响最终结局

⚠️ 这是游戏中最艰难的选择之一
⚠️ 每个角色都有独特的反应和告别台词
```

---

**文档版本：** v1.0  
**创建日期：** 2026-04-17  
**状态：** ✅ 已完成
