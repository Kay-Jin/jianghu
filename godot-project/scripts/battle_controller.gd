## 战斗控制器 - 六边形战棋核心
extends Node2D

signal turn_changed(new_turn: String)
signal unit_selected(unit_data: Dictionary)
signal unit_moved(unit_index: int)
signal unit_attacked(attacker_index: int, target_index: int, damage: int)
signal martial_art_used(attacker_index: int, target_index: int, art_name: String, damage: int)
signal battle_ended(winner: String)
signal message_shown(text: String)

enum State {
	INIT,
	PLAYER_TURN_SELECT,
	PLAYER_MOVE,
	PLAYER_ACTION,
	ENEMY_TURN,
	BATTLE_END
}

var current_state: State = State.INIT
var selected_unit_index: int = -1
var units: Array = []
var action_points: int = 2

var move_range_cells: Array = []
var attack_range_cells: Array = []
var battle_log: Array[String] = []
var tile_map_for_range: TileMap = null
const GRID_W := 15
const GRID_H := 11

func _ready():
	battle_log_msg("⚔️ 战斗开始！")
	_init_battle()

## 默认测试用战斗配置（GlobalState 未初始化时使用）
const _DEFAULT_PLAYER_UNITS := [
	{"id":"protagonist","name":"林渊","type":"player","hp":100,"max_hp":100,"mp":50,"max_mp":50,
	 "attack":25,"defense":8,"move_range":4,"weapon_range":2,"grid_pos":Vector2i(2,4),
	 "alive":true,"acted":false,"martial_arts":["duan_jian_jian_fa","po_jun"]},
	{"id":"shen_ren","name":"沈刃","type":"player","hp":80,"max_hp":80,"mp":40,"max_mp":40,
	 "attack":30,"defense":5,"move_range":5,"weapon_range":2,"grid_pos":Vector2i(1,5),
	 "alive":true,"acted":false,"martial_arts":["duan_jian_jian_fa"]},
]

## 敌方配置从 GlobalState.pending_battle 读取，或使用默认值
func _init_battle():
	var player_units: Array = []
	var enemy_units: Array = []

	# ── 读取 GlobalState 中的战斗参数 ─────────
	var has_global := Engine.has_singleton("GlobalState") or _global_state_exists()
	if has_global:
		var party_units := GlobalState.get_battle_units()
		if not party_units.is_empty():
			player_units = party_units
		var pending: Dictionary = GlobalState.pending_battle
		if pending.has("enemies"):
			enemy_units = pending.enemies.duplicate(true)

	# ── 回退到默认测试数据 ─────────────────────
	if player_units.is_empty():
		player_units = _DEFAULT_PLAYER_UNITS.duplicate(true)

	if enemy_units.is_empty():
		enemy_units = [
			{"id":"bandit_boss","name":"山贼头目","type":"enemy","hp":120,"max_hp":120,
			 "attack":20,"defense":10,"move_range":3,"weapon_range":1,
			 "grid_pos":Vector2i(8,4),"alive":true,"acted":false,"martial_arts":[]},
			{"id":"bandit_a","name":"山贼甲","type":"enemy","hp":50,"max_hp":50,
			 "attack":12,"defense":3,"move_range":3,"weapon_range":1,
			 "grid_pos":Vector2i(7,3),"alive":true,"acted":false,"martial_arts":[]},
			{"id":"bandit_b","name":"山贼乙","type":"enemy","hp":50,"max_hp":50,
			 "attack":12,"defense":3,"move_range":3,"weapon_range":1,
			 "grid_pos":Vector2i(9,5),"alive":true,"acted":false,"martial_arts":[]},
		]

	# ── 分配站位（己方在左，敌方在右）────────
	var player_starts := [Vector2i(1,3),Vector2i(2,4),Vector2i(1,5),Vector2i(2,6),Vector2i(0,4),Vector2i(0,6)]
	var enemy_starts  := [Vector2i(8,4),Vector2i(7,3),Vector2i(9,5),Vector2i(8,6),Vector2i(10,4),Vector2i(10,5)]
	for i in player_units.size():
		if i < player_starts.size():
			player_units[i]["grid_pos"] = player_starts[i]
	for i in enemy_units.size():
		if i < enemy_starts.size():
			enemy_units[i]["grid_pos"] = enemy_starts[i]

	for u in player_units:
		units.append(u)
	for u in enemy_units:
		units.append(u)

	var p_names: Array = []
	var e_names: Array = []
	for u in units:
		if u.type == "player": p_names.append(u.name)
		else: e_names.append(u.name)
	battle_log_msg("👤 我方：" + "、".join(p_names))
	battle_log_msg("👹 敌方：" + "、".join(e_names))

func _global_state_exists() -> bool:
	return get_node_or_null("/root/GlobalState") != null
	
	current_state = State.PLAYER_TURN_SELECT
	battle_log_msg("操作提示：① 左键点蓝色己方单位 ② 点绿色高亮格移动 ③ 再点敌人或用底部「攻击/武功」")
	call_deferred("_emit_initial_turn")

func _emit_initial_turn() -> void:
	turn_changed.emit("我方回合 - 请选择单位")

func _range_cells(center: Vector2i, max_r: int) -> Array:
	if tile_map_for_range != null:
		return HexUtils.get_cells_in_range_tilemap(tile_map_for_range, center, max_r, GRID_W, GRID_H)
	return HexUtils.get_cells_in_range(center, max_r)

func _grid_in_range(from: Vector2i, to: Vector2i, max_r: int) -> bool:
	if tile_map_for_range != null:
		return HexUtils.is_in_range_tilemap(tile_map_for_range, from, to, max_r, GRID_W, GRID_H)
	return HexUtils.is_in_range(from, to, max_r)

func select_unit(index: int):
	if units[index]["type"] != "player" or not units[index]["alive"] or units[index]["acted"]:
		battle_log_msg("❌ 无法选择该单位")
		return
	
	selected_unit_index = index
	var unit = units[index]
	
	unit_selected.emit(unit)
	battle_log_msg("📍 选择：" + unit["name"])
	
	move_range_cells = _range_cells(unit["grid_pos"], unit["move_range"])
	attack_range_cells = []
	
	current_state = State.PLAYER_MOVE
	turn_changed.emit(unit["name"] + " - 选择移动目标格子")

func move_unit_to(target_pos: Vector2i):
	if current_state != State.PLAYER_MOVE:
		return
	
	var unit = units[selected_unit_index]
	
	if not _grid_in_range(unit["grid_pos"], target_pos, unit["move_range"]):
		battle_log_msg("❌ 超出移动范围！")
		return
	
	if not is_cell_empty(target_pos, selected_unit_index):
		battle_log_msg("❌ 该格子已被占用！")
		return
	
	unit["grid_pos"] = target_pos
	battle_log_msg("🚶 " + unit["name"] + " 移动到 (" + str(target_pos.x) + ", " + str(target_pos.y) + ")")
	
	attack_range_cells = _range_cells(target_pos, unit["weapon_range"])
	
	unit_moved.emit(selected_unit_index)
	
	current_state = State.PLAYER_ACTION
	turn_changed.emit(unit["name"] + " - 选择行动（攻击/技能/等待）")

func attack_target(target_pos: Vector2i):
	if current_state != State.PLAYER_ACTION:
		return
	
	var attacker = units[selected_unit_index]
	
	var target_index = -1
	for i in range(units.size()):
		if units[i]["grid_pos"] == target_pos and units[i]["alive"] and i != selected_unit_index:
			target_index = i
			break
	
	if target_index == -1:
		battle_log_msg("❌ 该位置没有可攻击目标")
		return
	
	if not _grid_in_range(attacker["grid_pos"], target_pos, attacker["weapon_range"]):
		battle_log_msg("❌ 超出武器攻击范围！")
		return
	
	var target = units[target_index]
	var damage = max(1, attacker["attack"] - target["defense"])
	target["hp"] = max(0, target["hp"] - damage)
	target["acted"] = true
	
	battle_log_msg("⚔️ " + attacker["name"] + " 攻击 " + target["name"] + "！")
	battle_log_msg("💥 造成 " + str(damage) + " 点伤害")
	battle_log_msg("❤️ " + target["name"] + " HP: " + str(target["hp"]) + "/" + str(target["max_hp"]))
	
	unit_attacked.emit(selected_unit_index, target_index, damage)
	
	if target["hp"] <= 0:
		target["alive"] = false
		battle_log_msg("💀 " + target["name"] + " 被击败了！")
	
	attacker["acted"] = true
	
	if check_battle_end():
		return
	
	if has_player_units_to_act():
		current_state = State.PLAYER_TURN_SELECT
		selected_unit_index = -1
		turn_changed.emit("我方回合 - 请选择单位")
	else:
		start_enemy_turn()

func use_martial_art(attacker_index: int, art_id: String, target_pos: Vector2i):
	if attacker_index >= units.size():
		return
	
	var attacker = units[attacker_index]

	# 优先从 GameData 读取武功数据
	var art: Dictionary = {}
	if get_node_or_null("/root/GameData") != null:
		art = GameData.MARTIAL_ARTS.get(art_id, {})
	if art.is_empty():
		# 内置回退数据
		var fallback_db := {
			"duan_jian_jian_fa": {"name": "断剑剑法", "mp_cost": 5, "range": 2, "damage_multiplier": 1.5},
			"po_jun": {"name": "破军", "mp_cost": 15, "range": 2, "damage_multiplier": 2.5, "effect": "pierce", "pierce_percent": 0.3},
		}
		art = fallback_db.get(art_id, {})
	if art.is_empty():
		battle_log_msg("❌ 未知武功：" + art_id)
		return
	
	if attacker.get("mp", 0) < art["mp_cost"]:
		battle_log_msg("❌ 内力不足！需要 " + str(art["mp_cost"]) + " 点内力")
		return
	
	if not _grid_in_range(attacker["grid_pos"], target_pos, art["range"]):
		battle_log_msg("❌ 超出武功攻击范围！")
		return
	
	var target_index = -1
	for i in range(units.size()):
		if units[i]["grid_pos"] == target_pos and units[i]["alive"] and i != attacker_index:
			target_index = i
			break
	
	if target_index == -1:
		battle_log_msg("❌ 该位置没有可攻击目标")
		return
	
	var target = units[target_index]
	
	var base_damage = attacker["attack"] * art["damage_multiplier"]
	var target_defense = target["defense"]
	
	if art.get("effect") == "pierce":
		target_defense = int(target_defense * (1.0 - art.get("pierce_percent", 0)))
	
	var damage = max(1, int(base_damage - target_defense))
	target["hp"] = max(0, target["hp"] - damage)
	
	attacker["mp"] -= art["mp_cost"]
	attacker["acted"] = true
	
	battle_log_msg("✨ " + attacker["name"] + " 使用了「" + art["name"] + "」！")
	battle_log_msg("💥 造成 " + str(damage) + " 点伤害")
	battle_log_msg("❤️ " + target["name"] + " HP: " + str(target["hp"]) + "/" + str(target["max_hp"]))
	
	martial_art_used.emit(attacker_index, target_index, art["name"], damage)
	
	if target["hp"] <= 0:
		target["alive"] = false
		battle_log_msg("💀 " + target["name"] + " 被击败了！")
	
	if check_battle_end():
		return
	
	if has_player_units_to_act():
		current_state = State.PLAYER_TURN_SELECT
		selected_unit_index = -1
		turn_changed.emit("我方回合 - 请选择单位")
	else:
		start_enemy_turn()

func wait_unit():
	if current_state != State.PLAYER_ACTION:
		return
	
	units[selected_unit_index]["acted"] = true
	battle_log_msg("⏸️ " + units[selected_unit_index]["name"] + " 选择等待")
	selected_unit_index = -1
	
	if has_player_units_to_act():
		current_state = State.PLAYER_TURN_SELECT
		turn_changed.emit("我方回合 - 请选择单位")
	else:
		start_enemy_turn()

func start_enemy_turn():
	current_state = State.ENEMY_TURN
	turn_changed.emit("敌方回合...")
	
	battle_log_msg("🔄 敌方行动中...")
	
	for i in range(units.size()):
		if units[i]["type"] == "enemy" and units[i]["alive"]:
			enemy_ai_action(i)
	
	for unit in units:
		unit["acted"] = false
	
	if check_battle_end():
		return
	
	current_state = State.PLAYER_TURN_SELECT
	turn_changed.emit("我方回合 - 请选择单位")

func enemy_ai_action(enemy_index: int):
	var enemy = units[enemy_index]
	
	var nearest_player_index = -1
	var nearest_dist = 999
	
	for i in range(units.size()):
		if units[i]["type"] == "player" and units[i]["alive"]:
			var dist = HexUtils.hex_distance(enemy["grid_pos"], units[i]["grid_pos"])
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_player_index = i
	
	if nearest_player_index == -1:
		return
	
	var target = units[nearest_player_index]
	
	if nearest_dist <= enemy["weapon_range"]:
		var damage = max(1, enemy["attack"] - target["defense"])
		target["hp"] = max(0, target["hp"] - damage)
		
		battle_log_msg("👹 " + enemy["name"] + " 攻击 " + target["name"] + "！")
		battle_log_msg("💥 造成 " + str(damage) + " 点伤害")
		battle_log_msg("❤️ " + target["name"] + " HP: " + str(target["hp"]) + "/" + str(target["max_hp"]))
		
		if target["hp"] <= 0:
			target["alive"] = false
			battle_log_msg("💀 " + target["name"] + " 被击败了！")
	else:
		var move_steps = enemy["move_range"]
		var target_pos = HexUtils.move_toward(enemy["grid_pos"], target["grid_pos"], move_steps)
		
		if is_cell_empty(target_pos, enemy_index):
			enemy["grid_pos"] = target_pos
			battle_log_msg("👹 " + enemy["name"] + " 向 " + target["name"] + " 移动")

func check_battle_end() -> bool:
	var players_alive = 0
	var enemies_alive = 0
	
	for unit in units:
		if unit["alive"]:
			if unit["type"] == "player":
				players_alive += 1
			else:
				enemies_alive += 1
	
	if players_alive == 0:
		battle_log_msg("💀 我方全灭... 战斗失败")
		_notify_global_state("enemy")
		battle_ended.emit("enemy")
		current_state = State.BATTLE_END
		return true
	
	if enemies_alive == 0:
		battle_log_msg("🎉 全歼敌人！战斗胜利！")
		_notify_global_state("player")
		battle_ended.emit("player")
		current_state = State.BATTLE_END
		return true
	
	return false

func _notify_global_state(winner: String) -> void:
	if get_node_or_null("/root/GlobalState") != null:
		var surviving: Array = []
		for u in units:
			if u.type == "player": surviving.append(u)
		GlobalState.on_battle_ended(winner, surviving)
		if winner == "player":
			GlobalState.add_exp(50 * units.size())

func has_player_units_to_act() -> bool:
	for unit in units:
		if unit["type"] == "player" and unit["alive"] and not unit["acted"]:
			return true
	return false

func is_cell_empty(pos: Vector2i, exclude_index: int) -> bool:
	for i in range(units.size()):
		if i != exclude_index and units[i]["alive"] and units[i]["grid_pos"] == pos:
			return false
	return true

func battle_log_msg(text: String):
	battle_log.append(text)
	message_shown.emit(text)
