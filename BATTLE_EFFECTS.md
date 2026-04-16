# ⚡ 江湖打工人 — 战斗特效与动画设计

**版本：** v1.0  
**创建日期：** 2026-04-17  
**关联文档：** GAME_MECHANICS.md / MARTIAL_ARTS.md / GODOT_QUICKSTART.md

---

## 一、战斗特效分类

### 1.1 特效层级

```
战斗特效分三层：
├── 底层（Grid 层）
│   └── 格子高亮、移动路径、范围显示
├── 中层（角色层）
│   ├── 角色移动动画
│   ├── 攻击动画
│   ├── 受击动画
│   └── 死亡动画
└── 顶层（UI 层）
    ├── 伤害数字
    ├── 状态图标
    ├── 回合提示
    └── 战斗日志
```

### 1.2 移动效果

```
角色移动动画：
  - 从 A 格移动到 B 格，持续 0.3 秒
  - 移动轨迹：平滑曲线（tween）
  - 脚下显示移动路径（虚线高亮）
  - 移动结束时轻微"弹跳"效果

移动路径显示：
  - 选中单位后，可移动格子高亮（绿色半透明）
  - 鼠标悬停时，显示从当前位置到目标的路径
  - 路径用箭头标识方向

Godot 实现：
  func move_unit(from: Vector2, to: Vector2):
      var tween = create_tween()
      tween.tween_property(unit_sprite, "position", to, 0.3)
      tween.set_trans(Tween.TRANS_CUBIC)
      tween.set_ease(Tween.EASE_OUT)
      await tween.finished
      # 弹跳效果
      var bounce = create_tween()
      bounce.tween_property(unit_sprite, "scale", Vector2(1.1, 0.9), 0.1)
      bounce.tween_property(unit_sprite, "scale", Vector2(1, 1), 0.15)
```

### 1.3 攻击动画

#### 通用攻击动画

```
近战攻击（剑/刀/拳）：
  1. 攻击者向前移动半步（0.1 秒）
  2. 武器挥舞特效（弧形光效，0.2 秒）
  3. 命中瞬间闪光（白色覆盖 0.1 秒）
  4. 受击者后退半步（0.2 秒）
  5. 伤害数字弹出

远程攻击（暗器）：
  1. 投掷物飞行轨迹（抛物线，0.3 秒）
  2. 命中瞬间粒子效果
  3. 受击者反应
```

#### 各武功专属特效

| 武功 | 特效描述 | 颜色 |
|------|----------|------|
| 断剑剑法 | 直线剑气，从剑尖射出 | 银白 |
| 破军 | 十字形冲击波，穿透目标 | 金色 |
| 听雨剑法 | 雨滴状粒子从天而降 | 蓝色 |
| 细雨绵绵 | 连续 3 道剑气 | 蓝白 |
| 青囊剑法 | 绿色药草粒子环绕 | 绿色 |
| 回春掌 | 温暖的光波，治愈效果 | 白色 |
| 铁血刀法 | 红色火焰拖尾 | 红橙 |
| 开山劈 | 地面裂开特效 | 土黄 |
| 打狗棒法 | 棍影残像 | 棕色 |
| 亢龙有悔 | 龙形气浪向前推进 | 金黄 |
| 紫霞神功 | 紫色光罩笼罩自身 | 紫色 |
| 黄泉剑法 | 黑色雾气缠绕目标 | 黑色 |
| 幽冥散 | 绿色毒雾扩散 | 绿色 |

### 1.4 受击效果

```
普通受击：
  - 屏幕轻微震动（0.1 秒，幅度 3 像素）
  - 受击者闪烁红色（0.2 秒）
  - 伤害数字弹出（红色，向上飘 0.5 秒后消失）

暴击受击：
  - 屏幕震动更强烈（0.2 秒，幅度 6 像素）
  - 受击者闪烁橙色（0.3 秒）
  - 伤害数字更大（金色，带火焰效果）
  - 额外显示 "暴击！" 文字

破甲受击：
  - 盔甲碎裂粒子效果
  - 伤害数字带向下箭头（防御被无视）
  - 特殊音效

中毒效果：
  - 角色周围绿色光晕
  - 每回合跳一次绿色伤害数字
  - 角色表情痛苦（sprite 切换）
```

### 1.5 死亡动画

```
角色死亡：
  1. 受最后一击
  2. 向后倒地（0.5 秒）
  3. 身体变灰白（modulate 变化）
  4. 灵魂粒子向上飘散（可选，增加氛围）
  5. 显示 " defeated" 文字

Boss 死亡：
  1. 最后一击全屏闪光
  2. Boss 跪地（0.5 秒）
  3. 慢镜头：Boss 倒下（1 秒）
  4. 粒子爆发
  5. "胜利！" 文字
  6. 战利品掉落动画
```

---

## 二、战斗特效 — Godot 4.3 实现

### 2.1 伤害数字弹出

```gdscript
# damage_number.gd
extends Label

var target_position: Vector2
var damage: int
var is_critical: bool = false
var is_heal: bool = false

func _ready():
    # 设置文字
    if is_heal:
        text = "+" + str(damage)
        add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
    elif is_critical:
        text = "💥" + str(damage)
        add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
        add_theme_font_size_override("font_size", 24)
    else:
        text = "-" + str(damage)
        add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
        add_theme_font_size_override("font_size", 20)
    
    position = target_position
    modulate.a = 1.0
    
    # 向上飘动画
    var tween = create_tween()
    tween.tween_property(self, "position:y", position.y - 60, 0.8)
    tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8)
    tween.set_ease(Tween.EASE_OUT)
    
    # 动画结束后销毁
    await tween.finished
    queue_free()

# 在战斗场景中创建伤害数字
func show_damage(position: Vector2, damage: int, is_critical: bool = false, is_heal: bool = false):
    var dmg_label = preload("res://effects/damage_number.tscn").instantiate()
    dmg_label.target_position = position
    dmg_label.damage = damage
    dmg_label.is_critical = is_critical
    dmg_label.is_heal = is_heal
    add_child(dmg_label)
```

### 2.2 攻击剑气特效

```gdscript
# slash_effect.gd
extends Node2D
## 剑气特效 - 直线攻击

@export var start_pos: Vector2
@export var end_pos: Vector2
@export var color: Color = Color.WHITE
@export var duration: float = 0.3

var line: Line2D

func _ready():
    line = Line2D.new()
    line.width = 4.0
    line.default_color = color
    line.add_point(start_pos)
    line.add_point(end_pos)
    
    add_child(line)
    
    # 闪光动画
    var tween = create_tween()
    tween.tween_property(line, "modulate:a", 1.0, 0.05)
    tween.tween_property(line, "modulate:a", 0.0, duration - 0.05)
    
    await tween.finished
    queue_free()
```

### 2.3 屏幕震动效果

```gdscript
# screen_shake.gd
## 全局屏幕震动效果
extends Node

var shake_strength: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var shake_frequency: float = 15.0

func shake(strength: float, duration: float):
    """触发屏幕震动"""
    shake_strength = strength
    shake_duration = duration
    shake_timer = 0.0

func _process(delta):
    if shake_timer < shake_duration:
        shake_timer += delta
        
        # 计算震动偏移
        var offset_x = randf_range(-shake_strength, shake_strength)
        var offset_y = randf_range(-shake_strength, shake_strength)
        
        # 震动随时间衰减
        var decay = 1.0 - (shake_timer / shake_duration)
        offset_x *= decay
        offset_y *= decay
        
        get_viewport().canvas_transform = Transform2D(0, Vector2(offset_x, offset_y))
    else:
        shake_timer = 0.0
        shake_strength = 0.0
        get_viewport().canvas_transform = Transform2D()

# 使用示例：
# ScreenShake.shake(5.0, 0.2)  # 强度 5，持续 0.2 秒
```

### 2.4 粒子特效系统

```gdscript
# 粒子特效预设

# 1. 命中粒子（红色飞溅）
func create_hit_particles(position: Vector2):
    var particles = GPUParticles2D.new()
    particles.amount = 15
    particles.lifetime = 0.5
    particles.one_shot = true
    particles.explosiveness = 0.8
    
    var process_mat = ParticleProcessMaterial.new()
    process_mat.direction = Vector3(0, -1, 0)
    process_mat.spread = 360.0
    process_mat.initial_velocity_min = 50.0
    process_mat.initial_velocity_max = 150.0
    process_mat.gravity = Vector3(0, 200, 0)
    
    particles.process_material = process_mat
    
    # 用代码创建简单纹理
    var img = Image.create(4, 4, false, Image.FORMAT_RGBA8)
    img.fill(Color(1, 0.2, 0.2, 0.8))
    particles.texture = ImageTexture.create_from_image(img)
    
    particles.position = position
    add_child(particles)
    particles.emitting = true

# 2. 治愈粒子（绿色光点）
func create_heal_particles(position: Vector2):
    var particles = GPUParticles2D.new()
    particles.amount = 10
    particles.lifetime = 1.0
    particles.one_shot = true
    
    var process_mat = ParticleProcessMaterial.new()
    process_mat.direction = Vector3(0, 1, 0)  # 向上飘
    process_mat.spread = 30.0
    process_mat.initial_velocity_min = 20.0
    process_mat.initial_velocity_max = 50.0
    
    particles.process_material = process_mat
    
    var img = Image.create(8, 8, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.3, 1.0, 0.3, 0.6))
    particles.texture = ImageTexture.create_from_image(img)
    
    particles.position = position
    add_child(particles)
    particles.emitting = true

# 3. 毒雾粒子（绿色扩散）
func create_poison_particles(position: Vector2):
    var particles = GPUParticles2D.new()
    particles.amount = 20
    particles.lifetime = 2.0
    particles.one_shot = false  # 持续排放
    
    var process_mat = ParticleProcessMaterial.new()
    process_mat.direction = Vector3(0, 0, 0)
    process_mat.spread = 360.0
    process_mat.initial_velocity_min = 5.0
    process_mat.initial_velocity_max = 20.0
    
    particles.process_material = process_mat
    
    var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
    img.fill(Color(0.2, 0.8, 0.2, 0.3))
    particles.texture = ImageTexture.create_from_image(img)
    
    particles.position = position
    add_child(particles)
    particles.emitting = true
    return particles  # 返回引用以便后续停止
```

---

## 三、战斗动画流程图

```
完整战斗回合动画流程：

1. 回合开始
   ├── 屏幕上方显示 "我方回合"（0.5 秒淡入淡出）
   └── 可行动单位微微发光

2. 选择单位
   ├── 单位放大 1.15 倍
   ├── 可移动格子高亮（绿色）
   └── UI 显示单位信息

3. 选择移动目标
   ├── 鼠标悬停格子高亮
   ├── 显示移动路径（虚线）
   └── 确认移动

4. 移动动画
   ├── 角色平滑移动到目标（0.3 秒）
   ├── 移动路径虚线消失
   └── 落地弹跳效果

5. 选择攻击目标
   ├── 可攻击格子高亮（红色）
   └── 敌人单位显示攻击范围

6. 攻击动画
   ├── 攻击者前冲（0.1 秒）
   ├── 武器特效（剑气/火焰等）（0.2 秒）
   ├── 命中闪光（0.1 秒）
   ├── 屏幕震动（0.15 秒）
   ├── 伤害数字弹出
   ├── 受击者后退
   └── 播放音效

7. 检查击杀
   ├── 如果击杀 → 死亡动画
   └── 如果存活 → 返回单位待机

8. 结束回合
   ├── 敌方回合提示
   ├── 敌方 AI 行动（自动）
   └── 回到我方回合
```

---

## 四、音效设计

### 4.1 战斗音效

| 事件 | 音效 | 说明 |
|------|------|------|
| 选择单位 | 清脆"叮"声 | 短促 |
| 移动 | 脚步声 | 根据地面类型变化 |
| 近战攻击 | 刀剑碰撞声 | 根据武器类型 |
| 远程攻击 | 暗器飞行声 | 咻咻声 |
| 命中 | 沉闷打击声 | 根据伤害类型 |
| 暴击 | 清脆爆裂声 | 比普通命中更响亮 |
| 击杀 | 缓慢倒地声 | 配合死亡动画 |
| 胜利 | 激昂音乐 | 3 秒短音乐 |
| 失败 | 低沉音乐 | 2 秒短音乐 |
| 武功释放 | 特殊音效 | 每种武功不同 |
| 中毒 | 持续嘶嘶声 | 低音量循环 |
| 治疗 | 清脆铃声 | 温暖感觉 |

### 4.2 环境音效

| 场景 | 音效 |
|------|------|
| 断剑山庄 | 铸剑炉火声、铁锤声 |
| 听雨楼 | 雨声、古筝 |
| 青囊谷 | 鸟鸣、流水 |
| 战场 | 马蹄声、呐喊声 |
| 客栈 | 人声嘈杂 |
| 黑市 | 低沉窃窃私语 |

---

**文档版本：** v1.0  
**创建日期：** 2026-04-17  
**状态：** ✅ 已完成
