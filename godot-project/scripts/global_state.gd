## GlobalState — 全局运行时状态（Autoload）
## 保存：队伍 / 背包 / 任务 / 好感度 / 世界标志 / 当前位置
extends Node

signal party_changed
signal affection_changed(npc_id: String, new_value: int)
signal quest_updated(quest_id: String, state: String)
signal item_changed(item_id: String, delta: int)
signal gold_changed(new_total: int)
signal location_changed(new_location: String)

# ══════════════════════════════════════════════
# 主角属性（可在角色创建时设置）
# ══════════════════════════════════════════════
var protagonist: Dictionary = {
	"id": "protagonist",
	"name": "林渊",
	"nickname": "林工",
	"age_body": 18,
	"age_mind": 28,
	"level": 1,
	"exp": 0,
	"exp_to_next": 100,
	"base_stats": {"gengu":8,"neili":6,"wuxing":10,"shenfa":7,"tipo":9},
	"bonus_stats": {"gengu":0,"neili":0,"wuxing":0,"shenfa":0,"tipo":0},
	"origin": "project_manager",
	"martial_arts": ["basic_punch","jian_qi_shan"],
	"equipment": {"weapon": "", "armor": ""},
	"current_costume": "default",
	"hp": 0,
	"mp": 0,
	"is_alive": true,
}

# ══════════════════════════════════════════════
# 队伍（最多 6 人，含主角）
# ══════════════════════════════════════════════
var party: Array = []          # Array of char_id strings (首位固定是protagonist)
var max_party_size: int = 6

# ══════════════════════════════════════════════
# 背包
# ══════════════════════════════════════════════
var gold: int = 0
var inventory: Dictionary = {}   # item_id → quantity

# ══════════════════════════════════════════════
# 任务系统
# ══════════════════════════════════════════════
# quest_id → { state: "inactive"/"active"/"complete"/"failed", progress: {}, choices: {} }
var quests: Dictionary = {}

# ══════════════════════════════════════════════
# 好感度
# ══════════════════════════════════════════════
# npc_id → int (0~100)
var affection: Dictionary = {}

# ══════════════════════════════════════════════
# 世界标志（剧情开关）
# ══════════════════════════════════════════════
var world_flags: Dictionary = {}   # flag_id → bool/int

# ══════════════════════════════════════════════
# 当前位置 & 游戏时间
# ══════════════════════════════════════════════
var current_location: String = "sichuan_qingcheng"
var game_day: int = 1               # 游戏内天数
var time_of_day: float = 8.0        # 0.0-24.0 小时

# ══════════════════════════════════════════════
# 战斗结果缓存（战斗场景结束后写入）
# ══════════════════════════════════════════════
var last_battle_result: String = ""   # "win" / "lose"
var pending_battle: Dictionary = {}   # battle场景需要的参数

# ══════════════════════════════════════════════
# 初始化
# ══════════════════════════════════════════════
func _ready() -> void:
	_init_protagonist_hp()

func _init_protagonist_hp() -> void:
	var bd: Dictionary = GameData.calc_battle_stats(
		protagonist.base_stats.merged(protagonist.bonus_stats),
		protagonist.level
	)
	protagonist.hp = bd.max_hp
	protagonist.mp = bd.max_mp

# ══════════════════════════════════════════════
# 队伍管理
# ══════════════════════════════════════════════
func init_new_game(origin_id: String, bonus_points: Dictionary) -> void:
	protagonist.origin = origin_id
	protagonist.base_stats.gengu += bonus_points.get("gengu", 0)
	protagonist.base_stats.neili += bonus_points.get("neili", 0)
	protagonist.base_stats.wuxing += bonus_points.get("wuxing", 0)
	protagonist.base_stats.shenfa += bonus_points.get("shenfa", 0)
	protagonist.base_stats.tipo += bonus_points.get("tipo", 0)

	var origin_data: Dictionary = GameData.ORIGINS.get(origin_id, {})
	for stat in origin_data.get("bonus_stats", {}):
		protagonist.base_stats[stat] += origin_data.bonus_stats[stat]
	gold = origin_data.get("bonus_gold", 100)
	for item_id in origin_data.get("bonus_items", []):
		add_item(item_id, 1)
	for art_id in origin_data.get("starting_skills", []):
		if art_id not in protagonist.martial_arts:
			protagonist.martial_arts.append(art_id)

	party.clear()
	party.append("protagonist")
	_init_protagonist_hp()
	party_changed.emit()

func add_party_member(char_id: String) -> bool:
	if char_id in party or party.size() >= max_party_size:
		return false
	party.append(char_id)
	party_changed.emit()
	return true

func remove_party_member(char_id: String) -> void:
	if char_id == "protagonist":
		return
	party.erase(char_id)
	party_changed.emit()

func is_in_party(char_id: String) -> bool:
	return char_id in party

## 返回战斗用数据列表（供 battle_controller.gd 使用）
func get_battle_units() -> Array:
	var result: Array = []
	for char_id in party:
		var unit_data: Dictionary = _build_unit_data(char_id)
		if not unit_data.is_empty():
			result.append(unit_data)
	return result

func _build_unit_data(char_id: String) -> Dictionary:
	var base_char: Dictionary
	var stats: Dictionary
	if char_id == "protagonist":
		base_char = GameData.CHARACTERS.get("protagonist", {}).duplicate(true)
		base_char.base_stats = protagonist.base_stats.merged(protagonist.bonus_stats)
		stats = GameData.calc_battle_stats(base_char.base_stats, protagonist.level)
		return {
			"id": "protagonist",
			"name": protagonist.name,
			"type": "player",
			"hp": protagonist.hp, "max_hp": stats.max_hp,
			"mp": protagonist.mp, "max_mp": stats.max_mp,
			"attack": stats.attack, "defense": stats.defense,
			"move_range": stats.move_range, "weapon_range": stats.weapon_range,
			"grid_pos": Vector2i(1, 4),
			"alive": protagonist.is_alive,
			"acted": false,
			"martial_arts": protagonist.martial_arts,
			"portrait": base_char.get("portrait", ""),
		}
	else:
		var char_def: Dictionary = GameData.CHARACTERS.get(char_id, {})
		if char_def.is_empty(): return {}
		stats = GameData.calc_battle_stats(char_def.base_stats, char_def.get("level", 1))
		return {
			"id": char_id,
			"name": char_def.name,
			"type": "player",
			"hp": stats.max_hp, "max_hp": stats.max_hp,
			"mp": stats.max_mp, "max_mp": stats.max_mp,
			"attack": stats.attack, "defense": stats.defense,
			"move_range": stats.move_range, "weapon_range": stats.weapon_range,
			"grid_pos": Vector2i(0, 0),  # battle_controller 会重新设置
			"alive": true,
			"acted": false,
			"martial_arts": char_def.get("martial_arts", []),
			"portrait": char_def.get("portrait", ""),
		}

# ══════════════════════════════════════════════
# 背包操作
# ══════════════════════════════════════════════
func add_item(item_id: String, qty: int = 1) -> void:
	inventory[item_id] = inventory.get(item_id, 0) + qty
	item_changed.emit(item_id, qty)

func remove_item(item_id: String, qty: int = 1) -> bool:
	if inventory.get(item_id, 0) < qty:
		return false
	inventory[item_id] -= qty
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	item_changed.emit(item_id, -qty)
	return true

func has_item(item_id: String, qty: int = 1) -> bool:
	return inventory.get(item_id, 0) >= qty

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold < amount: return false
	gold -= amount
	gold_changed.emit(gold)
	return true

# ══════════════════════════════════════════════
# 任务系统
# ══════════════════════════════════════════════
func start_quest(quest_id: String) -> void:
	if quests.has(quest_id) and quests[quest_id].state != "inactive":
		return
	quests[quest_id] = {"state": "active", "progress": {}, "choices": {}}
	quest_updated.emit(quest_id, "active")

func complete_quest(quest_id: String) -> void:
	if not quests.has(quest_id): return
	quests[quest_id].state = "complete"
	_apply_quest_rewards(quest_id)
	quest_updated.emit(quest_id, "complete")

func fail_quest(quest_id: String) -> void:
	if not quests.has(quest_id): return
	quests[quest_id].state = "failed"
	quest_updated.emit(quest_id, "failed")

func set_quest_choice(quest_id: String, choice_key: String, value) -> void:
	if not quests.has(quest_id): return
	quests[quest_id].choices[choice_key] = value

func get_quest_choice(quest_id: String, choice_key: String):
	return quests.get(quest_id, {}).get("choices", {}).get(choice_key, null)

func get_quest_state(quest_id: String) -> String:
	return quests.get(quest_id, {}).get("state", "inactive")

func is_quest_active(quest_id: String) -> bool:
	return get_quest_state(quest_id) == "active"

func is_quest_complete(quest_id: String) -> bool:
	return get_quest_state(quest_id) == "complete"

func _apply_quest_rewards(quest_id: String) -> void:
	var q_data: Dictionary = GameData.QUESTS.get(quest_id, {})
	if q_data.is_empty(): return
	var reward: Dictionary = q_data.get("reward", {})
	for item_id in reward.get("items", []):
		add_item(item_id)
	var ap: int = reward.get("attribute_points", 0)
	if ap > 0:
		protagonist.bonus_stats["wuxing"] = protagonist.bonus_stats.get("wuxing", 0) + ap

# ══════════════════════════════════════════════
# 好感度系统
# ══════════════════════════════════════════════
func change_affection(npc_id: String, delta: int) -> void:
	affection[npc_id] = clampi(affection.get(npc_id, 0) + delta, 0, 100)
	affection_changed.emit(npc_id, affection[npc_id])

func get_affection(npc_id: String) -> int:
	return affection.get(npc_id, 0)

## 好感度阈值判断
func get_relationship_level(npc_id: String) -> String:
	var v: int = get_affection(npc_id)
	if v >= 90: return "soul_mate"
	if v >= 70: return "close_friend"
	if v >= 50: return "friend"
	if v >= 30: return "acquaintance"
	if v >= 10: return "known"
	return "stranger"

# ══════════════════════════════════════════════
# 世界标志
# ══════════════════════════════════════════════
func set_flag(flag_id: String, value = true) -> void:
	world_flags[flag_id] = value

func get_flag(flag_id: String):
	return world_flags.get(flag_id, false)

func has_flag(flag_id: String) -> bool:
	return world_flags.get(flag_id, false) == true

# ══════════════════════════════════════════════
# 位置 & 时间
# ══════════════════════════════════════════════
func travel_to(location_id: String) -> void:
	current_location = location_id
	advance_time(8.0)   # 旅行消耗约8小时
	location_changed.emit(location_id)

func advance_time(hours: float) -> void:
	time_of_day += hours
	while time_of_day >= 24.0:
		time_of_day -= 24.0
		game_day += 1

func get_time_of_day_label() -> String:
	var h: int = int(time_of_day)
	if h < 6: return "深夜"
	if h < 9: return "清晨"
	if h < 12: return "上午"
	if h < 14: return "午间"
	if h < 18: return "下午"
	if h < 21: return "傍晚"
	return "夜晚"

# ══════════════════════════════════════════════
# 经验值 & 升级
# ══════════════════════════════════════════════
func add_exp(amount: int) -> void:
	protagonist.exp += amount
	while protagonist.exp >= protagonist.exp_to_next:
		protagonist.exp -= protagonist.exp_to_next
		_level_up()

func _level_up() -> void:
	protagonist.level += 1
	protagonist.exp_to_next = int(protagonist.exp_to_next * 1.25)
	var bd: Dictionary = GameData.calc_battle_stats(
		protagonist.base_stats.merged(protagonist.bonus_stats), protagonist.level
	)
	protagonist.hp = bd.max_hp
	protagonist.mp = bd.max_mp
	print("[GlobalState] 主角升级到 Lv.", protagonist.level)

# ══════════════════════════════════════════════
# 战斗回调：战斗结束后更新HP/MP
# ══════════════════════════════════════════════
func on_battle_ended(winner: String, surviving_units: Array) -> void:
	last_battle_result = winner
	for unit in surviving_units:
		if unit.get("id") == "protagonist":
			protagonist.hp = unit.hp
			protagonist.mp = unit.get("mp", 0)
			protagonist.is_alive = unit.alive

# ══════════════════════════════════════════════
# 序列化（供 SaveSystem 使用）
# ══════════════════════════════════════════════
func to_dict() -> Dictionary:
	return {
		"protagonist": protagonist.duplicate(true),
		"party": party.duplicate(),
		"gold": gold,
		"inventory": inventory.duplicate(),
		"quests": quests.duplicate(true),
		"affection": affection.duplicate(),
		"world_flags": world_flags.duplicate(),
		"current_location": current_location,
		"game_day": game_day,
		"time_of_day": time_of_day,
	}

func from_dict(data: Dictionary) -> void:
	protagonist = data.get("protagonist", protagonist).duplicate(true)
	party = data.get("party", ["protagonist"]).duplicate()
	gold = data.get("gold", 0)
	inventory = data.get("inventory", {}).duplicate()
	quests = data.get("quests", {}).duplicate(true)
	affection = data.get("affection", {}).duplicate()
	world_flags = data.get("world_flags", {}).duplicate()
	current_location = data.get("current_location", "sichuan_qingcheng")
	game_day = data.get("game_day", 1)
	time_of_day = data.get("time_of_day", 8.0)
	party_changed.emit()
